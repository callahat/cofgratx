class Grammar
  attr_reader :rules

  def initialize
    @rules = { }
  end

  def add_rules non_terminal_symbol, *rules
    @rules[non_terminal_symbol.to_sym] ||= NonTerminal.new
    good_rules = []

    rules.each do |rule, translation|
      0.upto(rule.size) do |index|
        if rule[index].class == Symbol
          rule[index] = (@rules[rule[index]] ||= NonTerminal.new)
        end
      end
      good_rules << Rule.new( rule, translation )
    end

    @rules[non_terminal_symbol.to_sym].add_rules *good_rules
  end

  def clear_rule non_terminal_symbol
    @rules[non_terminal_symbol.to_sym] = NonTerminal.new
  end

  def match? string, starting_non_terminal
    #the grammar only matches if the string has no remainder
    raise "Unknown initial non terminal: '#{starting_non_terminal}'" unless @rules[starting_non_terminal.to_sym]
    candidate_matches = @rules[starting_non_terminal.to_sym].extract(string)
    candidate_matches.select{|m| m[1] == "" and m[0] != nil}.size > 0
  end

  def translate string, starting_non_terminal
    raise "Unknown initial non terminal: '#{starting_non_terminal}'" unless @rules[starting_non_terminal.to_sym]
    candidate_matches = @rules[starting_non_terminal.to_sym].translate(string)
    candidate_matches.select{|m| m[1] == "" and m[0] != nil}
  end

end
