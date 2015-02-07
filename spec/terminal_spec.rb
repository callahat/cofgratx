require 'spec_helper'
require 'cofgratx/cfg/terminal'

describe Terminal do
  context ".initialize" do
    it "can initialize with a string" do
       expect{ described_class.new("something") }.to_not raise_error
    end

    it "can initialize with a regular expression" do
       expect{ described_class.new(/[a-z]/) }.to_not raise_error
    end

    it "raises an exception on bad initial objects" do
      expect{ described_class.new(12345) }.to raise_error(ArgumentError, "expected Regular Expression or String; got #{12345.class.name}")
    end
  end

  context ".match?" do
    context "returns false when the terminal is not found at the strings beginning" do
      it{ expect( described_class.new("test").match?("no match") ).to be_falsey }
      it{ expect( described_class.new("test").match?("no test first") ).to be_falsey }
      it{ expect( described_class.new(/tony/).match?("get some sandwiches") ).to be_falsey }
      it{ expect( described_class.new(/burgers/).match?("bob's burgers are better") ).to be_falsey }
      it{ expect( described_class.new(/b.*s/).match?("hamburgers") ).to be_falsey }
    end

    context "returns true when the terminal is found at the start of the string" do
      it{ expect( described_class.new("test").match?("test") ).to be_truthy }
      it{ expect( described_class.new("test").match?("test first") ).to be_truthy }
      it{ expect( described_class.new(/tony/).match?("tony, get some sandwiches") ).to be_truthy }
      it{ expect( described_class.new(/burgers/).match?("burgers by bob are better") ).to be_truthy }
      it{ expect( described_class.new(/b.*s/).match?("burgers and hams") ).to be_truthy }
    end
  end

  context ".extract" do
    context "returns nil and the unmodified string when the terminal is not found at the strings beginning" do
      it{ expect( described_class.new("test").extract("no match") ).to match_array( [nil, "no match"] ) }
      it{ expect( described_class.new("test").extract("no test first") ).to match_array( [nil, "no test first"] ) }
      it{ expect( described_class.new(/tony/).extract("get some sandwiches") ).to match_array( [nil, "get some sandwiches"] ) }
      it{ expect( described_class.new(/burgers/).extract("bob's burgers are better") ).to match_array( [nil, "bob's burgers are better"] ) }
      it{ expect( described_class.new(/b.*s/).extract("hamburgers") ).to match_array( [nil, "hamburgers"] ) }
    end

    context "returns the terminal match and remainder of string" do
      it "does not mutate the input string" do
        input_string = "Don't change me!"
        expect( described_class.new("Don't change me!").extract(input_string) ).to match_array( ["Don't change me!", ""] )
        expect( input_string ).to match "Don't change me!"
      end
      it{ expect( described_class.new("test").extract("test") ).to match_array( ["test", ""] ) }
      it{ expect( described_class.new("test").extract("test first") ).to match_array( ["test", " first"] ) }
      it{ expect( described_class.new(/tony/).extract("tony, get some sandwiches") ).to match_array( ["tony", ", get some sandwiches"] ) }
      it{ expect( described_class.new(/burgers/).extract("burgers by bob are better") ).to match_array( ["burgers", " by bob are better"] ) }
      it{ expect( described_class.new(/b.*?s/).extract("burgers and hams") ).to match_array( ["burgers", " and hams"] ) }
    end
  end

end
