require 'spec_helper'
require 'cofgratx/cfg/terminal'
require 'cofgratx/cfg/repetition'
require 'cofgratx/cfg/translation_repetition_set_error'
require 'cofgratx/cfg/translation_repetition_set'
require 'cofgratx/cfg/rule_error'
require 'cofgratx/cfg/rule'
require 'cofgratx/cfg/non_terminal'
require 'cofgratx/cfg/grammar'

describe Grammar do
  context ".initialize" do
    it { expect{ described_class.new }.to_not raise_error }
  end

  context ".add_rules" do
    before do
      @grammar = described_class.new
    end

    it "allows rule symbols to be given without rules" do
      expect_any_instance_of(NonTerminal).to receive(:add_rules).with(no_args).and_call_original

      expect( @grammar.rules.keys.size ).to equal 0
      @grammar.add_rules :one
      expect( @grammar.rules.keys.size ).to equal 1
      expect( @grammar.rules.values.first.class ).to equal NonTerminal
    end

    it "allows non terminal names to be given as strings or symbols" do
      expect( @grammar.rules.keys.size ).to equal 0
      @grammar.add_rules :one, [ [Terminal.new(/a/)] ,[] ]
      expect( @grammar.rules.keys.size ).to equal 1

      @grammar.add_rules "one", [ [Terminal.new(/b/)] ,[] ]
      expect( @grammar.rules.keys.size ).to equal 1
    end

    it "converts symbols in the subrule arrays to nonterminals" do
      expect( @grammar.rules.keys.size ).to equal 0
      @grammar.add_rules :one, [ [:S] ,[] ]
      expect( @grammar.rules.keys ).to match_array [ :one, :S ]
      expect( @grammar.rules[:one].rules.map(&:rule) ).to match_array [ [@grammar.rules[:S]] ]
    end

    it "adds a rule with translation" do
      expect( @grammar.rules.keys.size ).to equal 0
      expect{
        @grammar.add_rules :one,
          [ [Terminal.new(/a/), Terminal.new("b"), :two, Repetition.new(",")],
            [1,2,TranslationRepetitionSet.new(1,3,2,1,"STOP")]
          ]
        }.to_not raise_error
      expect( @grammar.rules.keys.size ).to equal 2
    end

    it "add several rules some with translations" do
      expect( @grammar.rules.keys.size ).to equal 0
      expect{
        @grammar.add_rules :one,
          [ [Terminal.new(/a/), Terminal.new("b"), :two, Repetition.new(",")],
            [1,2,TranslationRepetitionSet.new(1,3,2,1,"STOP")]
          ],
          [ [:one, :three, :one],
            [1,":",2]
          ]
        }.to_not raise_error
      expect( @grammar.rules.keys.size ).to equal 3
    end

    context "bad rules and translations" do
      it "does not add bad rules" do
        expect( @grammar.rules.keys.size ).to equal 0
        expect{
          @grammar.add_rules :one,
            [ ["BAD", :two, Repetition.new(",")],
              [1,2,TranslationRepetitionSet.new(1,3,2,1,"STOP")]
            ]
          }.to raise_error
        expect( @grammar.rules.keys.size ).to equal 2
        expect( @grammar.rules[:one].rules.map(&:rule) ).to match_array [ ]
        expect( @grammar.rules[:two].rules.map(&:rule) ).to match_array [ ]
      end

      it "does not rules when a bad rule is also given" do
        expect( @grammar.rules.keys.size ).to equal 0
        expect{
          @grammar.add_rules :one,
            [ [Terminal.new("GOOD")], [] ],
            [ ["BAD", :two, Repetition.new(",")],
              [1,2,TranslationRepetitionSet.new(1,3,2,1,"STOP")]
            ]
          }.to raise_error ArgumentError, "expected Terminal, NonTerminal or Repetition; got String"
        expect( @grammar.rules.keys.size ).to equal 2
        expect( @grammar.rules[:one].rules.map(&:rule) ).to match_array [ ]
        expect( @grammar.rules[:two].rules.map(&:rule) ).to match_array [ ]
      end

      it "does not remove good rules already added" do
        @terminal_a = Terminal.new("a")
        expect{ @grammar.add_rules :one, [ [@terminal_a, :two], [] ] }.to_not raise_error
        expect( @grammar.rules.keys.size ).to equal 2
        expect( @grammar.rules[:one].rules.map(&:rule) ).to match_array [ [@terminal_a, @grammar.rules[:two]] ]
        expect{
          @grammar.add_rules :one,
            [ ["BAD", Repetition.new(",")],
              [1,2,TranslationRepetitionSet.new(1,2,1,"STOP")]
            ]
          }.to raise_error
        expect( @grammar.rules.keys.size ).to equal 2
        expect( @grammar.rules[:one].rules.map(&:rule) ).to match_array [ [@terminal_a, @grammar.rules[:two]] ]
      end

      it "does not add rules with bad translations" do
        expect( @grammar.rules.keys.size ).to equal 0
        expect{
          @grammar.add_rules :one,
            [ [Terminal.new("BAD")],
              [1,2,3.14159]
            ]
          }.to raise_error
        expect( @grammar.rules.keys.size ).to equal 1
        expect( @grammar.rules[:one].rules.map(&:rule) ).to match_array [ ]
        expect( @grammar.rules[:one].rules.map(&:translation) ).to match_array [ ]
      end

      it "does not add any rules when bad translations are also given" do
        expect( @grammar.rules.keys.size ).to equal 0
        expect{
          @grammar.add_rules :one,
            [ [Terminal.new("GOOD")], ["DONT LET ME IN"] ],
            [ [Terminal.new("BAD")],
              [1,2,6.011]
            ]
          }.to raise_error
        expect( @grammar.rules.keys.size ).to equal 1
        expect( @grammar.rules[:one].rules.map(&:rule) ).to match_array [ ]
        expect( @grammar.rules[:one].rules.map(&:translation) ).to match_array [ ]
      end

      it "does not remove good rules and translations already added" do
        @terminal_a = Terminal.new("a")
        expect{ @grammar.add_rules :one, [ [@terminal_a, :two], [1,2] ] }.to_not raise_error
        expect( @grammar.rules.keys.size ).to equal 2
        expect( @grammar.rules[:one].rules.map(&:rule) ).to match_array [ [@terminal_a, @grammar.rules[:two]] ]
        expect( @grammar.rules[:one].rules.map(&:translation) ).to match_array [ [1,2] ]
        expect{
          @grammar.add_rules :one,
            [ [Terminal.new("BAD"), Repetition.new(",")],
              [1,2,2.718]
            ]
          }.to raise_error
        expect( @grammar.rules.keys.size ).to equal 2
        expect( @grammar.rules[:one].rules.map(&:rule) ).to match_array [ [@terminal_a, @grammar.rules[:two]] ]
        expect( @grammar.rules[:one].rules.map(&:translation) ).to match_array [ [1,2] ]
      end
    end
  end

  context ".clear_rule" do
    it "wipes out the productions for a given nonterminal" do
      @grammar = described_class.new
      @terminal_a = Terminal.new("a")
      expect{ @grammar.add_rules :one, [ [@terminal_a], [1,2] ] }.to_not raise_error
      expect( @grammar.rules[:one].rules.map(&:rule) ).to match_array [ [@terminal_a] ]
      expect( @grammar.rules[:one].rules.map(&:translation) ).to match_array [ [1,2] ]
      expect{ @grammar.clear_rule :one }.to_not raise_error
      expect( @grammar.rules[:one].rules.map(&:rule) ).to match_array []
      expect( @grammar.rules[:one].rules.map(&:translation) ).to match_array []
    end
  end

  context ".match?" do
    before(:all) do
      @terminal_a = Terminal.new("a")
      @terminal_b = Terminal.new("b")
      @repetition = Repetition.new(" and ")
    end

    context "simple grammar" do
      before(:all) do
        @simple_grammar = described_class.new
        @simple_grammar.add_rules :one, [ [@terminal_a, :one], [] ]
        @simple_grammar.add_rules :one, [ [@terminal_a], [] ]

        @empty_grammar = described_class.new
        @empty_grammar.add_rules :Z, [ [], [] ]
      end

      it{ expect( @simple_grammar.match?("a", "one") ).to be_truthy }
      it{ expect( @simple_grammar.match?("a", :one) ).to be_truthy }
      it{ expect( @simple_grammar.match?("aa", :one) ).to be_truthy }
      it{ expect( @simple_grammar.match?("aaaa", :one) ).to be_truthy }
      it{ expect( @simple_grammar.match?("aaaaaa", :one) ).to be_truthy }

      it{ expect( @simple_grammar.match?("", "one") ).to be_falsey }
      it{ expect( @simple_grammar.match?("ab", :one) ).to be_falsey }
      it{ expect( @simple_grammar.match?(" a ", :one) ).to be_falsey }
      it{ expect( @simple_grammar.match?("NO", :one) ).to be_falsey }

      it{ expect( @empty_grammar.match?("", :Z) ).to be_truthy }
      it{ expect( @empty_grammar.match?("NO", :Z) ).to be_falsey }
      it{ expect( @empty_grammar.match?("   ", :Z) ).to be_falsey }
    end

    context "comlpex grammar" do
      before(:all) do
        @terminal_a = Terminal.new("a")
        @terminal_b = Terminal.new("b")
        @repetition = Repetition.new(" and ")
        @complex_grammar = described_class.new
        @grammar_with_self_referential_rule = described_class.new

        @complex_grammar.add_rules :S, [ [@terminal_a, :A, @terminal_a, @repetition], [] ], [ [@terminal_a], [] ]
        @complex_grammar.add_rules :A, [ [@terminal_b, :S, @terminal_b], [] ], [ [], [] ]

        #the problem with the rule below, the nonterminal keeps going down forever, maybe add something that stops it, or start
        #unwinding the stack once it goes too deep. Either way, not all legal grammars will be able to be processed.
        #Or maybe make it illegal to have a nonterminal as the first (which should still be a legal production, but makes
        #creating a solution easier)
        @grammar_with_self_referential_rule.add_rules :S, [ [@terminal_a, :S, @terminal_a], [] ], [ [@terminal_a], [] ] , [ [:S, @repetition], []  ]
        #@complex_grammar2.add_rules :A, [ [@terminal_b, :S, @terminal_b], [] ], [ [], [] ]
      end

      it{ expect( @complex_grammar.match?("a", :S) ).to be_truthy }
      it{ expect( @complex_grammar.match?("aa", :S) ).to be_truthy }
      it{ expect( @complex_grammar.match?("ababa", :S) ).to be_truthy }
      it{ expect( @complex_grammar.match?("ababaababa", :S) ).to be_truthy }
      it{ expect( @complex_grammar.match?("aa and ababababa", :S) ).to be_truthy }
      it{ expect( @complex_grammar.match?("aa and aa", :S) ).to be_truthy }
      it{ expect( @complex_grammar.match?("ababa", :S) ).to be_truthy }

      #Bug
      it{ expect{ @grammar_with_self_referential_rule.match?("a", :S) }.to raise_error(SystemStackError) }
      #it{ expect( @grammar_with_self_referential_rule.match?("aa", :S) ).to be_truthy }
      #it{ expect( @grammar_with_self_referential_rule.match?("ababa", :S) ).to be_truthy }
      #it{ expect( @grammar_with_self_referential_rule.match?("ababaababa", :S) ).to be_truthy }
      #it{ expect( @grammar_with_self_referential_rule.match?("aa and ababababa", :S) ).to be_truthy }
      #it{ expect( @grammar_with_self_referential_rule.match?("aa and a", :S) ).to be_truthy }
      #it{ expect( @grammar_with_self_referential_rule.match?("ababa", :S) ).to be_truthy }

      it{ expect( @complex_grammar.match?("", :S) ).to be_falsey }
      it{ expect( @complex_grammar.match?("a but also stuff that isn't in the grammar", :S) ).to be_falsey }
      it{ expect( @complex_grammar.match?("   ababa", :S) ).to be_falsey }
    end
  end

  context ".translate" do
    before(:all) do
      @terminal_a = Terminal.new("a")
      @terminal_b = Terminal.new("b")
      @repetition = Repetition.new(" and ")
    end

    context "simple grammar - no actual translations" do
      before(:all) do
        @simple_grammar = described_class.new
        @simple_grammar.add_rules :one, [ [@terminal_a, :one], [] ]
        @simple_grammar.add_rules :one, [ [@terminal_a], [] ]

        @empty_grammar = described_class.new
        @empty_grammar.add_rules :Z, [ [], [] ]
      end

      it{ expect( @simple_grammar.translate("a", "one") ).to match_array [ ["a", ""] ] }
      it{ expect( @simple_grammar.translate("a", :one) ).to match_array [ ["a", ""] ] }
      it{ expect( @simple_grammar.translate("aa", :one) ).to match_array [ ["aa", ""] ] }
      it{ expect( @simple_grammar.translate("aaaa", :one) ).to match_array [ ["aaaa", ""] ] }
      it{ expect( @simple_grammar.translate("aaaaaa", :one) ).to match_array [ ["aaaaaa", ""] ] }

      it{ expect( @simple_grammar.translate("", "one") ).to match_array [ ] }
      it{ expect( @simple_grammar.translate("ab", :one) ).to match_array [ ] }
      it{ expect( @simple_grammar.translate(" a ", :one) ).to match_array [ ] }
      it{ expect( @simple_grammar.translate("NO", :one) ).to match_array [ ] }

      it{ expect( @empty_grammar.translate("", :Z) ).to match_array [ ["",""] ] }
      it{ expect( @empty_grammar.translate("NO", :Z) ).to match_array [ ] }
      it{ expect( @empty_grammar.translate("   ", :Z) ).to match_array [ ] }
    end

    context "comlpex grammar - no actual translations" do
      before(:all) do
        @terminal_a = Terminal.new("a")
        @terminal_b = Terminal.new("b")
        @repetition = Repetition.new(" and ")
        @complex_grammar = described_class.new
        @grammar_with_self_referential_rule = described_class.new

        @complex_grammar.add_rules :S, [ [@terminal_a, :A, @terminal_a, @repetition], [] ], [ [@terminal_a], [] ]
        @complex_grammar.add_rules :A, [ [@terminal_b, :S, @terminal_b], [] ], [ [], [] ]

        #the problem with the rule below, the nonterminal keeps going down forever, maybe add something that stops it, or start
        #unwinding the stack once it goes too deep. Either way, not all legal grammars will be able to be processed.
        #Or maybe make it illegal to have a nonterminal as the first (which should still be a legal production, but makes
        #creating a solution easier)
        @grammar_with_self_referential_rule.add_rules :S, [ [@terminal_a, :S, @terminal_a], [] ], [ [@terminal_a], [] ] , [ [:S, @repetition], []  ]
        #@complex_grammar2.add_rules :A, [ [@terminal_b, :S, @terminal_b], [] ], [ [], [] ]
      end

      it{ expect( @complex_grammar.translate("a", :S) ).to match_array [ ["a",""] ] }
      it{ expect( @complex_grammar.translate("aa", :S) ).to match_array [ ["aa",""] ] }
      it{ expect( @complex_grammar.translate("ababa", :S) ).to match_array [ ["ababa",""] ] }
      it{ expect( @complex_grammar.translate("ababaababa", :S) ).to match_array [ ["ababaababa",""] ] }
      it{ expect( @complex_grammar.translate("aa and ababababa", :S) ).to match_array [ ["aa and ababababa",""] ] }
      it{ expect( @complex_grammar.translate("aa and aa", :S) ).to match_array [ ["aa and aa",""] ] }

      #Bug
      it{ expect{ @grammar_with_self_referential_rule.translate("a", :S) }.to raise_error(SystemStackError) }

      it{ expect( @complex_grammar.translate("", :S) ).to match_array [] }
      it{ expect( @complex_grammar.translate("a but also stuff that isn't in the grammar", :S) ).to match_array [] }
      it{ expect( @complex_grammar.translate("   ababa", :S) ).to match_array [] }
    end

    context "simple grammar - translations" do
      before(:all) do
        #@tx_rep_set = TranslationRepetitionSet.new(1, ":", 2, 1, ";")

        @simple_grammar = described_class.new
        @simple_grammar.add_rules :one, [ [@terminal_a, :one], [2,1] ]
        @simple_grammar.add_rules :one, [ [@terminal_a], ["IWasTheLastA"] ]

        @empty_grammar = described_class.new
        @empty_grammar.add_rules :Z, [ [], ["Translate nothing"] ]
      end

      it{ expect( @simple_grammar.translate("a", "one") ).to match_array [ ["IWasTheLastA", ""] ] }
      it{ expect( @simple_grammar.translate("a", :one) ).to match_array [ ["IWasTheLastA", ""] ] }
      it{ expect( @simple_grammar.translate("aa", :one) ).to match_array [ ["IWasTheLastAa", ""] ] }
      it{ expect( @simple_grammar.translate("aaaa", :one) ).to match_array [ ["IWasTheLastAaaa", ""] ] }
      it{ expect( @simple_grammar.translate("aaaaaa", :one) ).to match_array [ ["IWasTheLastAaaaaa", ""] ] }

      it{ expect( @simple_grammar.translate("", "one") ).to match_array [ ] }
      it{ expect( @simple_grammar.translate("ab", :one) ).to match_array [ ] }
      it{ expect( @simple_grammar.translate(" a ", :one) ).to match_array [ ] }
      it{ expect( @simple_grammar.translate("NO", :one) ).to match_array [ ] }

      it{ expect( @empty_grammar.translate("", :Z) ).to match_array [ ["Translate nothing",""] ] }
      it{ expect( @empty_grammar.translate("NO", :Z) ).to match_array [ ] }
      it{ expect( @empty_grammar.translate("   ", :Z) ).to match_array [ ] }
    end

    context "comlpex grammar - translations" do
      before(:all) do
        @tx_rep_set = TranslationRepetitionSet.new(3, "[", 4,"&",3,1,"&",2, "]")

        @terminal_a = Terminal.new("a")
        @terminal_b = Terminal.new("b")
        @repetition = Repetition.new(" and ")
        @complex_grammar = described_class.new
        @grammar_with_self_referential_rule = described_class.new

        @complex_grammar.add_rules :S, [ [@terminal_a, :A, @terminal_a, @repetition], [1,3,4," ",2,":",@tx_rep_set] ], [ [@terminal_a], ["IWasALoneA"] ]
        @complex_grammar.add_rules :A, [ [@terminal_b, :S, @terminal_b], ["<",2,">"] ], [ [], ["-IWasNothing-"] ]

        #Add self referential grammar and grammar with rules having nonterminals as the first thing in a production
        #When that bug is fixed
        @grammar_with_self_referential_rule.add_rules :S, [ [@terminal_a, :S, @terminal_a], [2] ], [ [@terminal_a], ["JustAnA"] ] , [ [:S, @repetition], [1,2]  ]
      end

      it{ expect( @complex_grammar.translate("a", :S) ).to match_array [ ["IWasALoneA",""] ] }
      it{ expect( @complex_grammar.translate("aa", :S) ).to match_array [ ["aa -IWasNothing-:",""] ] }
      it{ expect( @complex_grammar.translate("ababa", :S) ).to match_array [ ["aa <IWasALoneA>:",""] ] }
      it{ expect( @complex_grammar.translate("ababaababa", :S) ).to match_array [ ["aa <aa <aa -IWasNothing-:>:>:", ""] ] }
      it{ expect( @complex_grammar.translate("aa and ababababa", :S) ).to match_array [ ["aa and  -IWasNothing-:", ""] ] }
      it{ expect( @complex_grammar.translate("aa and aa and ababa and aa and ababa and ababaababa", :S) ).to match_array [
          ["aa and  -IWasNothing-:[ and &aa&<IWasALoneA>][ and &aa&-IWasNothing-][ and &aa&<IWasALoneA>][&aa&<aa <aa -IWasNothing-:>:>]", ""]
        ] }

      #Bug
      it{ expect{ @grammar_with_self_referential_rule.translate("a", :S) }.to raise_error(SystemStackError) }

      it{ expect( @complex_grammar.translate("", :S) ).to match_array [] }
      it{ expect( @complex_grammar.translate("a but also stuff that isn't in the grammar", :S) ).to match_array [] }
      it{ expect( @complex_grammar.translate("   ababa", :S) ).to match_array [] }
    end
  end

end
