# frozen_string_literal: true

RSpec.describe CoreExtensions::Range::Checks do
  describe "#overlaps?" do
    it "returns `true` when the two ranges are equal" do
      expect((1..2).overlaps?(1..2)).to be(true)
    end

    it "returns `true` when there is overlap" do
      expect((1..4).overlaps?(2..3)).to be(true)
    end

    it "returns `false` when there is no overlap" do
      expect((1..4).overlaps?(5..8)).to be(false)
    end

    context "when there are endless ranges" do
      context "when one range is endless" do
        it "returns true when the endless range begin is before the non-endless range end" do
          expect((1..).overlaps?(2..3)).to be(true)
          expect((2..3).overlaps?(1..)).to be(true)
        end
      end

      context "when both ranges are endless" do
        it "returns true" do
          expect((1..).overlaps?(2..)).to be(true)
          expect((2..).overlaps?(1..)).to be(true)
        end
      end
    end

    context "when range `a` ends where range `b` begins" do
      context "when `a.exclude_end?` is `true`" do
        it "returns `false`" do
          expect((1...3).overlaps?(3..5)).to be(false)
          expect((3..5).overlaps?(1...3)).to be(false)
        end
      end

      context "when `a.exclude_end?` is `false`" do
        it "returns `true`" do
          expect((1..3).overlaps?(3..5)).to be(true)
          expect((3..5).overlaps?(1..3)).to be(true)
        end
      end

      context "when `b` is endless" do
        it "returns `false`" do
          expect((1...3).overlaps?(3..)).to be(false)
          expect((3..).overlaps?(1...3)).to be(false)

          expect((1...3).overlaps?(3...)).to be(false)
          expect((3...).overlaps?(1...3)).to be(false)
        end
      end
    end
  end

  describe "#endless?" do
    it "returns `true` when the range's `end` is `nil`" do
      expect((1..)).to be_endless
    end

    it "returns `false` when the range's `end` is not `nil`" do
      expect((1..3)).not_to be_endless
    end
  end

  describe "#beginless?" do
    it "returns `true` when the range's `begin` is `nil`" do
      expect((..3)).to be_beginless
    end

    it "returns `false` when the range's `begin` is not `nil`" do
      expect((1..3)).not_to be_beginless
    end
  end
end
