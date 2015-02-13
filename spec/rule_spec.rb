require 'spec_helper'
require 'cofgratx/cfg/terminal'
require 'cofgratx/cfg/repetition'
require 'cofgratx/cfg/translation_repetition_set_error'
require 'cofgratx/cfg/translation_repetition_set'
require 'cofgratx/cfg/rule_error'
require 'cofgratx/cfg/rule'


describe Rule do
  before(:all) do
#    @terminal_bob =     Terminal.new( "bob" )
#    @terminal_spaces =  Terminal.new( /\s+/ )
#    @terminal_thing =   Terminal.new( /t.*n/ )
#    @repetition_comma = Repetition.new( "," )
  end

  context ".set_rule" do
    before(:all) do
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
      @tx_rep_set = TranslationRepetitionSet.new(1, 2, 4)
    end

    before do
      @rule = described_class.new
    end

    it { expect{ @rule.set_translation() }.to_not raise_error }
    it { expect{ @rule.set_translation(1) }.to_not raise_error }
    it { expect{ @rule.set_translation(1,2,3) }.to_not raise_error }
    it { expect{ @rule.set_translation([1,"foo","bar"]) }.to_not raise_error }
    it { expect{ @rule.set_translation(1, @tx_rep_set) }.to_not raise_error }

    context "bad input" do
      def message_helper obj
        "expected Fixnum, String or TranslationRepetitionSet; got #{obj.class.name}"
      end

      it { expect{ @rule.set_translation(1.32) }.to raise_error(ArgumentError, message_helper(1.32)) }
      it { expect{ @rule.set_translation(1, {1=>2}) }.to raise_error(ArgumentError, message_helper({1=>2})) }
      it { expect{ @rule.set_translation(/asd/) }.to raise_error(ArgumentError, message_helper(/asd/)) }
    end
  end


  context ".initialize" do
    before(:all) do
      @terminal_a       = Terminal.new("a")
      @terminal_b       = Terminal.new(/b/)
      @repetition_comma = Repetition.new( "," )

      @tx_rep_set = TranslationRepetitionSet.new(1, 2, 4)

      @rule = [@terminal_a, @terminal_b]
      @translation = [1, 2, @tx_rep_set]
    end

    it "sets the subrules and translations by calling the appropriate methods" do
      expect_any_instance_of(described_class).to receive(:set_rule).with(@rule).and_call_original
      expect_any_instance_of(described_class).to receive(:set_translation).with(@translation).and_call_original

      described_class.new(@rule, @translation)
    end

    it "sets the subrules and translations when no translation is given" do
      expect_any_instance_of(described_class).to receive(:set_rule).with(@rule).and_call_original
      expect_any_instance_of(described_class).to receive(:set_translation).with([]).and_call_original

      described_class.new(@rule)
    end

    it "sets the subrules and translations when no input" do
      expect_any_instance_of(described_class).to receive(:set_rule).with([]).and_call_original
      expect_any_instance_of(described_class).to receive(:set_translation).with([]).and_call_original

      described_class.new()
    end
  end

  context ".valid_translation?" do
    before(:all) do
      @terminal_a       = Terminal.new("a")
      @terminal_b       = Terminal.new(/b/)
      @repetition_comma = Repetition.new( "," )

      @tx_rep_set = TranslationRepetitionSet.new(2, 1)
      @repeat_rule = [@terminal_a, @repetition_comma]
    end

    it { expect(described_class.new().valid_translation?).to be_truthy }
    it { expect(described_class.new(@terminal_a).valid_translation?).to be_truthy }
    it { expect(described_class.new(@repeat_rule).valid_translation?).to be_truthy }
    it { expect(described_class.new(@repeat_rule, [2,1,@tx_rep_set]).valid_translation?).to be_truthy }

    it "is not valid if a translation number is larger than the number of sub rules" do
      expect(described_class.new(@repeat_rule, [3]).valid_translation?).to be_falsy
    end

    it "is not valid if a translation number is larger than the number of sub rules" do
      expect(described_class.new(@repeat_rule, TranslationRepetitionSet.new(2, 4)).valid_translation?).to be_falsy
    end

    it "offset can be any positive number" do
      expect(described_class.new(@repeat_rule, TranslationRepetitionSet.new(999, 2)).valid_translation?).to be_truthy
    end
  end

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
