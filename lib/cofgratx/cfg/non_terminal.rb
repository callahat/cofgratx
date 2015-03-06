class NonTerminal

  def initialize *rules
    validate_list_of_rules *rules
    @rules = rules.to_a
  end

  def add_rules *rules
    validate_list_of_rules *rules
    @rules.push *rules
  end

  def match? string
    @rules.each do |rule|
      return true if rule.match? string
    end
    false
  end

  def extract string
    matches = @rules.inject([]) do |matches, rule|
      rule_matches = rule.extract string
      matches.concat rule_matches if rule_matches.first[0]
      matches
    end

    return [ [nil, string, [[]]] ] if matches.length == 0
    matches
  end

  def translate string
    translations = @rules.inject([]) do |translations, rule|
      translation, remainder = rule.translate string
      translations << [translation, remainder] if translation
      translations
    end

    return [ [nil, string] ] if translations.length == 0
    translations
  end

  protected
  def validate_list_of_rules *params
    bad_args = params.inject([]){|bad_args, param| bad_args << param unless param.class == Rule; bad_args}
    if bad_args.to_a.size > 0
      raise ArgumentError.new("expected a list of Rules; found bad items: " +
                               bad_args.map{|bad_arg| "#{bad_arg.class.name} #{bad_arg}"}.join("\n") )
    end
  end

end
