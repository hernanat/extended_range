# frozen_string_literal: true

RSpec.describe CoreExtensions::Range::Operations do
  describe ".merge" do
    it "returns the given ranges when there are no overlaps" do
      ranges = [(10..12), (13...20), (20..25), (26..)]

      expect(Range.merge(*ranges)).to eq(ranges)
    end

    it "does not merge an open range with an endless range whose start is the same as the range's end" do
      expect(Range.merge(1...3, 3..)).to eq([1...3, 3..])
    end

    it "merges the given ranges together" do
      # Should respect ranges that exclude their ends or not, and respect endless ranges.
      ranges = [(10...14), (13...20), (20..25), (26..), (28...)]

      expect(Range.merge(*ranges)).to eq([10...20, 20..25, 26..])
    end
  end

  describe ".subtract" do
    it "it subtracts closed finite ranges from the base range" do
      expect(Range.subtract(1..20, 2..3, 4..6, 7..12)).to eq([1...2, 13..20])
    end

    it "subtracts both closed and open finite ranges from the base range" do
      expect(Range.subtract(1..20, 2..3, 4...6, 7..12)).to eq([1...2, 6...7, 13..20])
    end

    it "subtracts finite ranges from the base endless range" do
      expect(Range.subtract(1.., 2..3, 4...6, 7..12)).to eq([1...2, 4...7, 13..])
    end

    it "subtracts an endless range from another endless range" do
      expect(Range.subtract(1.., 10..)).to eq([1...10])
      expect(Range.subtract(10.., 1..)).to eq([])
    end

    context "when given a proc for `delta`" do
      it "modifies the beginning of the second subrange using the proc" do
        base_range = Time.new(2021)..Time.new(2021, 1, 10, 11, 59, 59)
        subtracting_range = Time.new(2021, 1, 5)..Time.new(2021, 1, 8)

        result = Range.subtract(base_range, subtracting_range, delta: ->(t) { t + 2 })

        expect(result).to eq(
          [
            Time.new(2021)...Time.new(2021, 1, 5),
            Time.new(2021, 1, 8, 0, 0, 2)..Time.new(2021, 1, 10, 11, 59, 59)
          ]
        )
      end
    end
  end

  describe "#to_closed_range" do
    it "returns the range itself if it is already closed" do
      expect((1..2).to_closed_range).to eq(1..2)
    end

    it "returns a new, closed range whose end is the original range end minus some delta" do
      expect((1...2).to_closed_range(delta: 0.1)).to eq(1..1.9)
    end

    context "when given a proc for `delta`" do
      it "modifies the end of the range using the proc" do
        range = Time.new(2021)...Time.new(2021, 1, 10, 11, 59, 58)

        expect(range.to_closed_range(delta: ->(t) { t + 2 }))
          .to eq(Time.new(2021)..Time.new(2021, 1, 10, 12))
      end
    end
  end
end
