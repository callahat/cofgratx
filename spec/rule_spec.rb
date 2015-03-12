require 'spec_helper'
require 'cofgratx/cfg/terminal'
require 'cofgratx/cfg/repetition'
require 'cofgratx/cfg/translation_repetition_set_error'
require 'cofgratx/cfg/translation_repetition_set'
require 'cofgratx/cfg/rule_error'
require 'cofgratx/cfg/rule'
require 'cofgratx/cfg/non_terminal'


describe Rule do
  before(:all) do
    @rule             = Rule.new
    @terminal_a       = Terminal.new("a")
    @terminal_b       = Terminal.new(/b/)
    @repetition_comma = Repetition.new( "," )
    @nonterminal      = NonTerminal.new(@rule)
  end

  context ".set_rule" do
    before do
      @rule = described_class.new
    end

    it { expect{ @rule.set_rule() }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_a) }.to_not raise_error }
    it { expect{ @rule.set_rule(@nonterminal) }.to_not raise_error }
    it { expect{ @rule.set_rule(@nonterminal, @terminal_b) }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_b) }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_a, @repetition_comma) }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_a, @terminal_b, @terminal_a, @repetition_comma) }.to_not raise_error }
    it { expect{ @rule.set_rule(@terminal_a, @nonterminal, @terminal_b, @repetition_comma) }.to_not raise_error }

    it "raises an exception on bad initial objects" do
      expect{ @rule.set_rule(12345) }.to raise_error(ArgumentError, "expected Terminal, NonTerminal or Repetition; got #{12345.class.name}")
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


  context ".match?" do
    before(:all) do
      @term_rule = described_class.new [@terminal_a, @terminal_b]
      @repeat_rule = described_class.new [@terminal_a, @repetition_comma]
      @nonterminal_rule = NonTerminal.new(@term_rule)
      @mix_rule = described_class.new [@terminal_a, @nonterminal_rule]
    end

    context "returns false when the rule does not match a substring starting at the strings beginning" do
      it{ expect( @term_rule.match?("aab") ).to be_falsey }
      it{ expect( @term_rule.match?("b") ).to be_falsey }
      it{ expect( @term_rule.match?("here ababab") ).to be_falsey }
      it{ expect( @term_rule.match?("") ).to be_falsey }
      it{ expect( @repeat_rule.match?(",a") ).to be_falsey }
      it{ expect( @repeat_rule.match?("b,a") ).to be_falsey }
      it{ expect( @repeat_rule.match?("") ).to be_falsey }
      it{ expect( @repeat_rule.match?("no match") ).to be_falsey }
      it{ expect( @mix_rule.match?("abb") ).to be_falsey }
      it{ expect( @mix_rule.match?("b") ).to be_falsey }
      it{ expect( @mix_rule.match?("daab") ).to be_falsey }
      it{ expect( @mix_rule.match?("") ).to be_falsey }
    end

    context "returns true when the rule matches a substring starting at the strings beginning" do
      it{ expect( @term_rule.match?("ab") ).to be_truthy }
      it{ expect( @term_rule.match?("ab something else") ).to be_truthy }
      it{ expect( @repeat_rule.match?("a,") ).to be_truthy }
      it{ expect( @repeat_rule.match?("a,a") ).to be_truthy }
      it{ expect( @repeat_rule.match?("anothing") ).to be_truthy }
      it{ expect( @repeat_rule.match?("a,nothing else") ).to be_truthy }
      it{ expect( @mix_rule.match?("aabb more stuff") ).to be_truthy }
      it{ expect( @mix_rule.match?("aabbb") ).to be_truthy }
      it{ expect( @mix_rule.match?("aab") ).to be_truthy }
    end
  end

  context ".extract" do
    before(:all) do
      @term_rule = described_class.new [@terminal_a, @terminal_b]
      @repeat_rule = described_class.new [@terminal_a, @repetition_comma]
      @nonterminal_rule = NonTerminal.new(@term_rule)
      @mix_rule = described_class.new [@terminal_a, @nonterminal_rule]
    end

    context "returns nil and the unmodified string when the rule is not matched at the strings beginning" do
      it{ expect( @term_rule.extract("aab") ).to match_array( [ [nil,"aab",[[]]] ] ) }
      it{ expect( @term_rule.extract("b") ).to match_array( [ [nil,"b",[[]]] ] ) }
      it{ expect( @term_rule.extract("here ababab") ).to match_array( [ [nil,"here ababab",[[]]] ] ) }
      it{ expect( @term_rule.extract("") ).to match_array( [ [nil,"",[[]]] ] ) }
      it{ expect( @repeat_rule.extract(",a") ).to match_array( [ [nil,",a",[[]]] ] ) }
      it{ expect( @repeat_rule.extract("b,a") ).to match_array( [ [nil,"b,a",[[]]] ] ) }
      it{ expect( @repeat_rule.extract("") ).to match_array( [ [nil,"",[[]]] ] ) }
      it{ expect( @repeat_rule.extract("no match") ).to match_array( [ [nil,"no match",[[]]] ] ) }
      it{ expect( @mix_rule.extract("abb") ).to match_array( [ [nil,"abb",[[]]] ] ) }
      it{ expect( @mix_rule.extract("b") ).to match_array( [ [nil,"b",[[]]] ] ) }
      it{ expect( @mix_rule.extract("daab") ).to match_array( [ [nil,"daab",[[]]] ] ) }
      it{ expect( @mix_rule.extract("") ).to match_array( [ [nil,"",[[]]] ] ) }
    end

    context "returns the rule match and remainder of string" do
      it "does not mutate the input string" do
        input_string = "Don't change me!"
        expect( described_class.new(Terminal.new("Don't change me!")).extract(input_string) ).to match_array( [ ["Don't change me!","",[["Don't change me!"]]] ] )
        expect( input_string ).to match "Don't change me!"
      end

      it{ expect( @term_rule.extract("ab") ).to match_array( [ ["ab","",[["a","b"]]] ] ) }
      it{ expect( @term_rule.extract("ab something else") ).to match_array( [ ["ab"," something else",[["a","b"]]] ] ) }
      it{ expect( @repeat_rule.extract("a,") ).to match_array( [ ["a",",",[["a"]]] ] ) }
      it{ expect( @repeat_rule.extract("a,a") ).to match_array( [ ["a,a","",[["a",","],["a"]]] ] ) }
      it{ expect( @repeat_rule.extract("anothing") ).to match_array( [ ["a","nothing",[["a"]]] ] ) }
      it{ expect( @repeat_rule.extract("a,nothing else") ).to match_array( [ ["a",",nothing else",[["a"]]] ] ) }
      it{ expect( @repeat_rule.extract("a,a,anothing else") ).to match_array( [ ["a,a,a","nothing else",[["a",","],["a",","],["a"]]] ] ) }
      it{ expect( @repeat_rule.extract("a,a,a,nothing else") ).to match_array( [ ["a,a,a",",nothing else",[["a",","],["a",","],["a"]]] ] ) }
    end
  end

  context ".translate" do
    before(:all) do
      @terminal_c = Terminal.new("c")
      @tx_rep_set = TranslationRepetitionSet.new(2, " repeats:", 2, 1, 3)
      @simple_rule = described_class.new [@terminal_a, @terminal_b], [2,1]
      @simple_rule2 = described_class.new [@terminal_a, @terminal_b], [2,1,2,"moo"]
      @repeat_rule = described_class.new [@terminal_a, @terminal_b, @repetition_comma], [3,2,1,@tx_rep_set]
      @nonterminal_rule = NonTerminal.new(@simple_rule)
      @mix_rule = described_class.new [Terminal.new("c"), @nonterminal_rule], [2,1]
      @mix_rule_repeat = described_class.new [@terminal_c, @nonterminal_rule, @repetition_comma], [3,2,1,@tx_rep_set]
    end

    it "does not modify the original parameter" do
      original_string = "ab"
      expect( @simple_rule.translate original_string ).to match_array( [ ["ba",""] ] )
      expect( original_string ).to match "ab"
    end

    it { expect( @simple_rule.translate "abab" ).to match_array( [ ["ba","ab"] ] ) }
    it { expect( @simple_rule.translate "ab and nothing else" ).to match_array( [ ["ba"," and nothing else"] ] ) }
    it { expect( @simple_rule2.translate "abab" ).to match_array( [ ["babmoo","ab"] ] ) }
    it { expect( @simple_rule2.translate "ab and nothing else" ).to match_array( [ ["babmoo"," and nothing else"] ] ) }

    it { expect( @repeat_rule.translate "ab," ).to match_array( [ ["ba",","] ] ) }
    it { expect( @repeat_rule.translate "ab,ab" ).to match_array( [ [",ba repeats:ba",""] ] ) }
    it { expect( @repeat_rule.translate "ab,ab,ab" ).to match_array( [ [",ba repeats:ba, repeats:ba",""] ] ) }
    it { expect( @repeat_rule.translate "ab,ab,ab," ).to match_array( [ [",ba repeats:ba, repeats:ba",","] ] ) }

    it { expect( @mix_rule.translate "cab" ).to match_array( [ ["bac",""] ] ) }
    it { expect( @mix_rule.translate "cab," ).to match_array( [ ["bac",","] ] ) }
    it { expect( @mix_rule.translate "cab,cab" ).to match_array( [ ["bac",",cab"] ] ) }
    it { expect( @mix_rule_repeat.translate "cab," ).to match_array( [ ["bac",","] ] ) }
    it { expect( @mix_rule_repeat.translate "cab,cab" ).to match_array( [ [",bac repeats:bac",""] ] ) }
    it { expect( @mix_rule_repeat.translate "cab,cab,cab" ).to match_array( [ [",bac repeats:bac, repeats:bac",""] ] ) }

  end

  context "===" do
    before(:all) do
      @tx_rep_set = TranslationRepetitionSet.new(1, 2, 4)

      @rule = [@terminal_a, @terminal_b]
      @translation = [1, 2, @tx_rep_set]

      @rule_a = described_class.new(@rule)
      @rule_b = described_class.new(@rule)
    end

    it { expect( @rule_a == @rule_b ).to be_falsy }
    it { expect( @rule_a === @rule_b ).to be_truthy }

    it { expect( @rule_a == @rule_a ).to be_truthy }
    it { expect( @rule_a === @rule_a ).to be_truthy }
  end
end
