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

  context ".extract - without translation" do
    before do
      @rule = Rule.new
      @rule2 = Rule.new
      @rule3 = Rule.new
    end

    context "returns nil and the unmodified string when the terminal is not found at the strings beginning" do
      before do
        allow(@rule).to receive(:extract){ |param| [ [nil,param,nil] ] }
        allow(@rule2).to receive(:extract){ |param| [ [nil,param,nil] ] }
      end
      it{ expect( described_class.new().extract("no match") ).to match_array( [ [nil,"no match",nil] ] ) }
      it{ expect( described_class.new(@rule).extract("still no match") ).to match_array( [ [nil,"still no match",nil] ] ) }
      it{ expect( described_class.new(@rule,@rule2).extract("stubbed so no match") ).to match_array( [ [nil,"stubbed so no match",nil] ] ) }
    end

    context "returns the terminal match and remainder of string" do
      before do
        allow(@rule).to receive(:extract){ |param| [ [nil,param,nil] ] }
        allow(@rule2).to receive(:extract){ |param| [ ["D",param[1..-1],"D"] ] }
        allow(@rule3).to receive(:extract){ |param| [ ["Don",param[3..-1],"Don"] ] }
      end
      it "does not mutate the input string" do
        input_string = "Don't change me!"
        expect( described_class.new(@rule2,@rule,@rule3).extract(input_string) ).to match_array( [ ["D","on't change me!","D"], ["Don","'t change me!", "Don"] ] )
        expect( input_string ).to match "Don't change me!"
      end
      it{ expect( described_class.new(@rule,@rule3).extract("Donald") ).to match_array( [ ["Don","ald","Don"] ] ) }
      it{ expect( described_class.new(@rule,@rule3,@rule2).extract("Donald") ).to match_array( [ ["D","onald","D"], ["Don","ald","Don"] ] ) }
      it{ expect( described_class.new(@rule2).extract("Donald") ).to match_array( [ ["D","onald","D"] ] ) }
    end
  end

  context ".extract - with translation" do
    before do
      @rule = Rule.new
      @rule2 = Rule.new
      @rule3 = Rule.new

      allow(@rule).to receive(:extract){ |param| [ [nil, param, nil] ] }
      allow(@rule2).to receive(:extract){ |param| [ ["ab", param[2..-1], "ba" ] ] }
      allow(@rule3).to receive(:extract){ |param| [ ["abb", param[3..-1], "bba" ] ] }
    end

    it "does not mutate the input string" do
      input_string = "abb"
      expect( described_class.new(@rule2,@rule,@rule3).extract(input_string) ).to match_array( [ ["ab","b","ba"], ["abb","","bba"] ] )
      expect( input_string ).to match "abb"
    end

    it{ expect( described_class.new(@rule).extract("ab") ).to match_array( [ [nil, "ab", nil] ] ) }
    it{ expect( described_class.new(@rule,@rule2).extract("abba") ).to match_array( [ ["ab", "ba", "ba"] ] ) }
    it{ expect( described_class.new(@rule,@rule2).extract("abba") ).to match_array( [ ["ab", "ba", "ba"] ] ) }
    it{ expect( described_class.new(@rule,@rule2,@rule3).extract("abbadabab") ).to match_array( [ ["ab", "badabab", "ba"], ["abb", "adabab", "bba"] ] ) }
  end
end
