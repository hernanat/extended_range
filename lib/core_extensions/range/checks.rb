# frozen_string_literal: true

module CoreExtensions
  module Range
    module Checks
      # Checks whether or not `other` overlaps with `self`.
      #
      # @param [Range] other The range to check for overlap with `self`.
      #
      # @return [Boolean]
      #
      # @example Overlapping range
      #   (1..4).overlaps?(2..6) #=> true
      #
      # @example Non-overlapping range
      #   (1..4).overlaps?(5..7) #=> false
      def overlaps?(other)
        return true if self == other

        if endless? || other.endless?
          endless_range_overlaps?(other)
        elsif self.end == other.begin || other.end == self.begin
          # If `a.end` is the same as `b.begin`, but `a.exclude_end?` is true,
          # then the ranges do not overlap. Similar in the other direction.
          (self.end == other.begin && !exclude_end?) ||
            (other.end == self.begin && !other.exclude_end?)
        else
          self.begin <= other.end && other.begin <= self.end
        end
      end

      # Returns `true` if `self` is endless, `false` otherwise.
      def endless?
        self.end.nil?
      end

      # Returns `true` if `self` is beginless, `false` otherwise.
      def beginless?
        self.begin.nil?
      end

      private

      # `other` is not necessarily endless, neither is `self`.
      def endless_range_overlaps?(other)
        # two endless ranges necessarily overlap.
        if endless? && other.endless?
          true
        elsif endless?
          # self or other is endless, check to see if they overlap by checking if the
          # endless range's begin falls before the non-endless range's end. We also
          # include a constraint to prevent open ranges whose end is the same as the
          # second range's beginning from being considered as overlapping.
          self.begin <= other.end && !other.exclude_end?
        else
          other.begin <= self.end && !exclude_end?
        end
      end
    end
  end
end
