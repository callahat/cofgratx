require 'spec_helper'
require 'cofgratx/cfg/terminal'
require 'cofgratx/cfg/repetition'

describe Repetition do

  context ".initialize" do
    it "can initialize with a string" do
       expect{ described_class.new("something") }.to_not raise_error
    end

    it "doesn not initialize with a regular expression" do
       expect{ described_class.new(/,/) }.to raise_error(ArgumentError, "expected String; got #{/,/.class.name}")
    end

    it "raises an exception on bad initial objects" do
      expect{ described_class.new(12345) }.to raise_error(ArgumentError, "expected String; got #{12345.class.name}")
    end
  end

  context ".match?" do
    context "returns false when the terminal is not found at the strings beginning" do
      it{ expect( described_class.new(",").match?("no match") ).to be_falsey }
      it{ expect( described_class.new(":").match?("one: two") ).to be_falsey }
    end

    context "returns true when the terminal is found at the start of the string" do
      it{ expect( described_class.new(",").match?(",test") ).to be_truthy }
    end
  end

  context ".extract" do
    context "returns nil and the unmodified string when the terminal is not found at the strings beginning" do
      it{ expect( described_class.new(",").extract("no match") ).to match_array( [nil, "no match"] ) }
      it{ expect( described_class.new(",").extract("no, test first") ).to match_array( [nil, "no, test first"] ) }
    end

    context "returns the terminal match and remainder of string" do
      it "does not mutate the input string" do
        input_string = ","
        expect( described_class.new(",").extract(input_string) ).to match_array( [",", ""] )
        expect( input_string ).to match ","
      end
      it{ expect( described_class.new(",").extract(",") ).to match_array( [",", ""] ) }
      it{ expect( described_class.new(",").extract(", first") ).to match_array( [",", " first"] ) }
    end
  end
end
