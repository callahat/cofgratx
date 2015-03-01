require 'spec_helper'
require 'cofgratx/cfg/rule'
require 'cofgratx/cfg/non_terminal'

describe NonTerminal do
  context ".initialize" do
    before do
      @rule = Rule.new
      @rule2 = Rule.new
    end

    it "can initialize with nothing" do
      expect{ described_class.new() }.to_not raise_error
    end

    it "can initialize with a rule" do
      expect{ described_class.new(@rule) }.to_not raise_error
    end

    it "can initialize with a set of rules" do
      expect{ described_class.new(@rule, @rule2) }.to_not raise_error
    end

    it "raises an exception on bad initial objects" do
      expect{ described_class.new(@rule, 12345) }.to raise_error(ArgumentError, "expected a list of Rules; found bad items: " +
                               [12345].map{|bad_arg| "#{bad_arg.class.name} #{bad_arg}"}.join("\n"))
    end
  end

  context ".match?" do
    before do
      @rule = Rule.new
      @rule2 = Rule.new
    end

    context "returns false when the non terminal has no matching rules at the strings beginning" do
      before do
        allow(@rule).to receive(:match?){ false }
        allow(@rule2).to receive(:match?){ false }
      end
      it{ expect( described_class.new().match?("no match") ).to be_falsey }
      it{ expect( described_class.new(@rule).match?("still no match") ).to be_falsey }
      it{ expect( described_class.new(@rule,@rule2).match?("stubbed so no match") ).to be_falsey }
    end

    context "returns true when the  non terminal has a matching rule at the start of the string" do
      before do
        allow(@rule).to receive(:match?){ false }
        allow(@rule2).to receive(:match?){ true }
      end
      it{ expect( described_class.new(@rule2).match?("test") ).to be_truthy }
      it{ expect( described_class.new(@rule,@rule2).match?("test first") ).to be_truthy }
      it{ expect( described_class.new(@rule2,@rule2).match?("tony, get some sandwiches") ).to be_truthy }
    end
  end

  context ".extract" do
    before do
      @rule = Rule.new
      @rule2 = Rule.new
      @rule3 = Rule.new
    end

    context "returns nil and the unmodified string when the terminal is not found at the strings beginning" do
      before do
        allow(@rule).to receive(:extract){ |param| [nil, param, [[]]] }
        allow(@rule2).to receive(:extract){ |param| [nil, param, [[]]] }
      end
      it{ expect( described_class.new().extract("no match") ).to match_array( [ [nil,"no match",[[]]] ] ) }
      it{ expect( described_class.new(@rule).extract("still no match") ).to match_array( [ [nil,"still no match",[[]]] ] ) }
      it{ expect( described_class.new(@rule,@rule2).extract("stubbed so no match") ).to match_array( [ [nil,"stubbed so no match",[[]]] ] ) }
    end

    context "returns the terminal match and remainder of string" do
      before do
        allow(@rule).to receive(:extract){ |param| [nil, param, [[]]] }
        allow(@rule2).to receive(:extract){ |param| ["D", param[1..-1], [["D"]] ] }
        allow(@rule3).to receive(:extract){ |param| ["Don", param[3..-1], [["Don"]] ] }
      end
      it "does not mutate the input string" do
        input_string = "Don't change me!"
        expect( described_class.new(@rule2,@rule,@rule3).extract(input_string) ).to match_array( [ ["D","on't change me!",[["D"]]], ["Don","'t change me!", [["Don"]]] ] )
        expect( input_string ).to match "Don't change me!"
      end
      it{ expect( described_class.new(@rule,@rule3).extract("Donald") ).to match_array( [ ["Don","ald",[["Don"]]] ] ) }
      it{ expect( described_class.new(@rule,@rule3,@rule2).extract("Donald") ).to match_array( [ ["D","onald",[["D"]]], ["Don","ald",[["Don"]]] ] ) }
      it{ expect( described_class.new(@rule2).extract("Donald") ).to match_array( [ ["D","onald",[["D"]]] ] ) }
    end
  end

  context ".translate" do
    before do
      @rule = Rule.new
      @rule2 = Rule.new
      @rule3 = Rule.new

      allow(@rule).to receive(:translate){ |param| [nil, param] }
      allow(@rule2).to receive(:translate){ |param| ["ba", param[2..-1] ] }
      allow(@rule3).to receive(:translate){ |param| ["bba", param[3..-1] ] }
    end

    it "does not mutate the input string" do
      input_string = "abb"
      expect( described_class.new(@rule2,@rule,@rule3).translate(input_string) ).to match_array( [ ["ba","b"], ["bba",""] ] )
      expect( input_string ).to match "abb"
    end

    it{ expect( described_class.new(@rule).translate("ab") ).to match_array( [ [nil, "ab"] ] ) }
    it{ expect( described_class.new(@rule,@rule2).translate("abba") ).to match_array( [ ["ba", "ba"] ] ) }
    it{ expect( described_class.new(@rule,@rule2).translate("abba") ).to match_array( [ ["ba", "ba"] ] ) }
    it{ expect( described_class.new(@rule,@rule2,@rule3).translate("abbadabab") ).to match_array( [ ["ba", "badabab"], ["bba", "adabab"] ] ) }
  end
end
