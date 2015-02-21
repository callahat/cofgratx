class Rule

  def initialize subrules = [], translations = []
    @rule = set_rule subrules
    @translation = set_translation translations
  end

  def set_rule *rule
    good_parts = []
    rule.flatten(2).each do |part|
      if ! [Repetition, Terminal].include? part.class
        raise ArgumentError.new("expected Terminal or Repetition; got #{part.class.name}")
      elsif part.class == Repetition and good_parts.size == 0
        raise RuleError.new("cannot have repetition as the first part of the rule")
      elsif good_parts.last.class == Repetition
        raise RuleError.new("nothing can follow the repetition")
      end
      good_parts << part
    end
    @rule = good_parts
  end

  def set_translation *translation
    good_parts = []
    translation.flatten.each do |part|
      if ! [Fixnum, String, TranslationRepetitionSet].include? part.class
        raise ArgumentError.new("expected Fixnum, String or TranslationRepetitionSet; got #{part.class.name}")
      end
      good_parts << part
    end
    @translation = good_parts
  end

  def valid_translation?
    @translation.each do |part|
      if part.class == TranslationRepetitionSet
        if @rule.last.class != Repetition
          return false
        elsif part.translations.select{|tx| tx.class == Fixnum and tx > @rule.size}.count > 0
          return false
        end
      else
        return false if part > @rule.size
      end
    end
    true
  end

  def match? candidate
    extract(candidate)[0] != nil
  end

  def extract candidate
    working_candidate = candidate.dup
    current_match = ""
    @rule.each do |subrule|
      if subrule.class == Repetition
        match, temp_working_candidate = subrule.extract(working_candidate)
        if match
          more_match, repetition_working_candidate = self.extract temp_working_candidate
          if more_match
            current_match += match + more_match
            working_candidate = repetition_working_candidate
          end
        end
      else #terminal
        match, working_candidate = subrule.extract(working_candidate)
        return [nil, candidate] unless match
        current_match += match
      end
    end
    [current_match, working_candidate]
  end

end
