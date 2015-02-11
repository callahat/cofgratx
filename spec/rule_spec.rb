require 'spec_helper'
require 'cofgratx/cfg/terminal'
require 'cofgratx/cfg/repetition'
require 'cofgratx/cfg/rule_error'
require 'cofgratx/cfg/rule'

describe Rule do
  before(:all) do
  p "other stuff!"
#    @terminal_bob =     Terminal.new( "bob" )
#    @terminal_spaces =  Terminal.new( /\s+/ )
#    @terminal_thing =   Terminal.new( /t.*n/ )
#    @repetition_comma = Repetition.new( "," )
  end

  context ".set_rule" do
    before(:all) do
      p "before context .initialize"
      @terminal_a       = Terminal.new("a")
      @terminal_b       = Terminal.new(/b/)
      @repetition_comma = Repetition.new( "," )
    end

    before do
      @rule = described_class.new
    end

    it { expect{ @rule.set_rule() }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_a) }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_b) }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_a, @repetition_comma) }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_a, @terminal_b, @terminal_a, @repetition_comma) }.to_not raise_error }

    it "raises an exception on bad initial objects" do
      expect{ @rule.set_rule(12345) }.to raise_error(ArgumentError, "expected Terminal or Repetition; got #{12345.class.name}")
    end

    it "the repetition cannot be the first for the rule" do
      expect{ @rule.set_rule(@repetition_comma) }.to raise_error(RuleError, "cannot have repetition as the first part of the rule")
    end

    context "nothing can follow the repetition" do
      it {expect{
                  @rule.set_rule(@terminal_a, @repetition_comma, @terminal_a)
                }.to raise_error(RuleError, "nothing can follow the repetition") }
      it {expect{
                  @rule.set_rule(@terminal_a, @repetition_comma, @repetition_comma)
                }.to raise_error(RuleError, "nothing can follow the repetition") }
    end
  end

  context ".set_translation" do
    before(:all) do
      p "before context .initialize"
      @terminal_a       = Terminal.new("a")
      @terminal_b       = Terminal.new(/b/)
      @repetition_comma = Repetition.new( "," )
    end

    before do
      @rule = described_class.new
    end

    it { expect{ @rule.set_rule() }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_a) }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_b) }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_a, @repetition_comma) }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_a, @terminal_b, @terminal_a, @repetition_comma) }.to_not raise_error }

    it "raises an exception on bad initial objects" do
      expect{ @rule.set_rule(12345) }.to raise_error(ArgumentError, "expected Terminal or Repetition; got #{12345.class.name}")
    end

    it "the repetition cannot be the first for the rule" do
      expect{ @rule.set_rule(@repetition_comma) }.to raise_error(RuleError, "cannot have repetition as the first part of the rule")
    end

  end
=begin
  context ".initialize" do
    before(:all) do
      p "before context .initialize"
      @terminal_a       = Terminal.new( "a" )
      @terminal_b       = Terminal.new( /b+/ )
      @repetition_comma = Repetition.new( "," )
    end

    it { expect{ described_class.new() }.to_not raise_error }
    it { expect{ described_class.new(@terminal_a) }.to_not raise_error }
    it { expect{ described_class.new(@terminal_b) }.to_not raise_error }
    it { expect{ described_class.new(@terminal_a, @repetition_comma) }.to_not raise_error }
    it { expect{ described_class.new(@terminal_a, @terminal_b, @terminal_a, @repetition_comma) }.to_not raise_error }

    it "raises an exception on bad initial objects" do
      expect{ described_class.new(12345) }.to raise_error(ArgumentError, "expected Terminal or Repetition; got #{12345.class.name}")
    end

    it "the repetition cannot be the first for the rule" do
      expect{ described_class.new(@repetition_comma) }.to raise_error(RuleError, "cannot have repetition as the first part of the rule")
    end

    context "nothing can follow the repetition" do
      it {expect{
                  described_class.new(@terminal_a, @repetition_comma, @terminal_a)
                }.to raise_error(RuleError, "nothing can follow the repetition") }
      it {expect{
                  described_class.new(@terminal_a, @repetition_comma, @repetition_comma)
                }.to raise_error(RuleError, "nothing can follow the repetition") }
    end
  end
=end
=begin
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
=end
end
