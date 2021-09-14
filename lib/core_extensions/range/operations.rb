# frozen_string_literal: true

require_relative "checks"

module CoreExtensions
  module Range
    module Operations
      include Checks

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      # Returns a range whose end is included in the range.
      #
      # @param delta The amount which should be subtracted from the range end when converting
      #   to a closed range.
      #
      # @return [Range] self if the range is already closed, otherwise return a new range
      #   where the `begin` is the same as `self`, and the `end` is `self.end - delta`.
      #
      # @example Convert an open time range to a closed time range.
      #   (Time.new(2020)...Time.new(2021)).to_closed_range #=> 2020-01-01 00:00:00 -0800..2020-12-31 23:59:59 -0800
      #
      # @example Convert an open time range to a closed time range and specify the delta.
      #   (Time.new(2020)...Time.new(2021)).to_closed_range(delta: Float::EPSILON)
      #   #=> 2020-01-01 00:00:00 -0800..2020-12-31 23:59:59 4503599627370495/4503599627370496 -0800
      def to_closed_range(delta: 1)
        return self unless exclude_end?

        if delta.is_a?(Proc)
          (self.begin..(delta.call(self.end)))
        else
          (self.begin..self.end - delta)
        end
      end

      # Calls {ClassMethods#subtract} with `self` and `other`
      #
      # @param [Range] other The range to subtract.
      #
      # @return [Array<Range>] An array of ranges obtained from subtracting `other` from `self`.
      def -(other)
        self.class.subtract(self, other)
      end

      # Calls {ClassMethods#merge} with `self` and `*others`
      #
      # @param [Range] other The range to merge.
      #
      # @return [Array<Range>] An array of merged ranges.
      def merge(other)
        self.class.merge(self, other)
      end

      module ClassMethods
        # Merge the given ranges together.
        #
        # @param [Array<Range>] ranges The ranges objects to merge.
        #
        # @return [Array<Range>] An array of potentially merged ranges.
        #
        # @example Merge two ranges.
        #   Range.merge(1..5, 2..6) #=> [1..6]
        #
        # @example Merge an endless range with a non-endless range.
        #   Range.merge(1..5, 2..) #=> [1..]
        #
        # @example Merge two endless ranges.
        #   Range.merge(1.., 2..) #=> [1..]
        #
        # @example Can't merge an open range with a range whose start is the same as the open range's end.
        #   Range.merge(1...3, 3..5) #=> [1...3, 3..5]
        def merge(*ranges)
          ranges.sort_by!(&:begin).inject([]) do |merged, range|
            if merged.empty? || !range.overlaps?(merged.last)
              merged.append(range)
            else
              last_range = merged.pop

              merged.append(merge_ranges(last_range, range))
            end
          end
        end

        # Subtract an array of ranges from the given original range.
        #
        # @param [Range] original_range The range to subtract from.
        #
        # @param [Array<Range>] subtracted_ranges The ranges to subtract from `original_range`
        #
        # @param delta The amount which should be added to the begin of a resulting subrange in
        #   the event that the previous subrange end was open.
        #
        # @example Subtraction of closed, finite ranges.
        #   Range.subtract(1..20, 2..3, 4..6, 7..12) #=> [1...2, 13..20]
        #
        # @example Subtraction of a mixture of closed and open finite ranges.
        #   Range.subtract(1..20, 2..3, 4...6, 7..12) #=> [1...2, 6...7, 13..20]
        #
        # @example Subtraction of finite ranges from an endless range
        #   Range.subtract(1.., 2..3, 4...6, 7..12) #=> [1...2, 4...7, 13..]
        #
        # @example Subtraction of two endless ranges
        #   Range.subtract(1.., 10..) #=> [1...10]
        #   Range.subtract(10.., 1..) #=> []
        def subtract(original_range, *subtracted_ranges, delta: 1)
          subtracted_ranges.sort_by!(&:begin).inject([original_range]) do |result, subtracted_range|
            if result.last&.overlaps?(subtracted_range)
              result.append(*subtract_overlapping_range(result.pop, subtracted_range, delta: delta))
            else
              result
            end
          end
        end

        private

        def merge_ranges(a, b)
          exclude_end = should_merged_exclude_end?(a, b)
          ::Range.new(a.begin, merged_range_end(a, b), exclude_end)
        end

        def should_merged_exclude_end?(a, b)
          return true if a.exclude_end? && b.exclude_end?

          # Deal with endless ranges
          if a.endless? || b.endless?
            # If `a.end` is `nil` and `a.exclude_end?` is `true`, then `b.exclude_end?` can't
            # be `true`, so it suffices to check if `b.end` is not `nil`. If `b.end` is not `nil`,
            # then the result is an endless range that excludes the end. If `b.end` *is* `nil`,
            # then the result is an endless range that does *not* exclude the end (because
            # we know from above that `b.exclude_end?` cannot be `true`.
            #
            # The same holds for the inverse statement (i.e. the RHS of the `||` below).
            #
            # The goal is to maintain logical consistency for for `exclude_end` even in
            # the event that the result is an endless range.
            (a.exclude_end? && a.endless? && !b.endless?) ||
              (b.exclude_end? && b.endless? && !a.endless?)
          else
            (a.exclude_end? && b.end < a.end) || (b.exclude_end? && a.end < b.end)
          end
        end

        def merged_range_end(a, b)
          if a.endless? || b.endless?
            nil
          else
            a.end > b.end ? a.end : b.end
          end
        end

        # Subtract range `b` from range `a` and return the resulting range(s)
        def subtract_overlapping_range(a, b, delta: 1)
          return [] if a == b

          result = []

          result << (a.begin...b.begin) if a.begin < b.begin

          # If `b` is endless then the entire rest of `a` will be gone.
          return result if b.endless?

          other_begin = if b.exclude_end?
                          b.end
                        else
                          delta.is_a?(Proc) ? delta.call(b.end) : b.end + delta
                        end

          result << ::Range.new(other_begin, a.end, a.exclude_end?) if a.endless? || other_begin < a.end

          result
        end
      end
    end
  end
end
