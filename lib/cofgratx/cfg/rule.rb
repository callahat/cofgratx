class Rule

  def initialize subrules = [], translations = []
    @rule = set_rule subrules
    @translation = set_translation translations
  end

  def set_rule *rule
    good_parts = []
    rule.flatten(2).each do |part|
      if ! [Repetition, Terminal, NonTerminal].include? part.class
        raise ArgumentError.new("expected Terminal, NonTerminal or Repetition; got #{part.class.name}")
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
    extract(candidate).first[0] != nil
  end

  def extract candidate
    working_matches = [ ["",candidate.dup,[[]]] ]
    @rule.each do |subrule|
      surviving_matches = []
      working_matches.each do |current_match, working_candidate, current_set|

        if subrule.class == Repetition
          surviving_matches.concat extract_repetition_character( subrule, current_match.dup, current_set.dup, working_candidate.dup )
        elsif subrule.class == Terminal
          match, working_candidate = subrule.extract working_candidate
          if match
            current_set.first << match
            surviving_matches << [ current_match + match, working_candidate.dup, current_set.dup ]
          end
        elsif subrule.class == NonTerminal
          matches = subrule.extract working_candidate
          if matches.first[0]
            matches.each do |match, working_candidate, set|
              surviving_matches << [ current_match + match, working_candidate.dup, current_set << [ set ] ]
            end
          end
        else
          raise "Rule is corrupt, found a bad subrule:#{subrule} with class:#{subrule.class}"
        end
      end
      working_matches = surviving_matches.dup
    end
    return [ [nil,candidate,nil] ] if working_matches.size == 0

     p "Working candidate"
     p working_matches
    
    working_matches.map{|match|
      current_set = match[2]
      current_translation = ""
      @translation.each do |sub_translation|
      p "sub trans"
      p sub_translation
      p current_set
        if sub_translation.class == TranslationRepetitionSet
        p "yup, here"
        p (sub_translation.offset-1)*@rule.size
        p current_set
        p @rule.size
          (((sub_translation.offset-1)*@rule.size)..current_set.size).step(@rule.size).each do |index|
          p "ined"
           p index
           p sub_translation
            #current_set[(sub_translation.offset-1)..-1].each do |current|
            sub_translation.translations.each do |translation|
              current_translation += translation_helper current_set, index, translation
            end
          end
        else
          current_translation += translation_helper current_set.first, 0, sub_translation
        end
        p "noew translation is:"
            p current_translation
      end
      if @translation.size == 0
        #no translation happening
        match[2] = match[0].dup
      else
        match[2] = current_translation
      end
      match
    }
    
    working_matches
  end
=begin
  def translate candidate
    matches = extract candidate
    p matches
    matches.inject([]) do |txs, match|
      current_match, working_candidate, current_set = match
      return [nil, candidate] unless current_match
      p match
      current_translation = ""
      @translation.each do |sub_translation|
      p current_translation
        if sub_translation.class == TranslationRepetitionSet
          current_set[(sub_translation.offset*@rule.size-1)..-1].each do |current|
            sub_translation.translations.each do |translation|
              current_translation += translation_helper current, translation
            end
          end
        else
          current_translation += translation_helper current_set.first, sub_translation
        end
      end
      txs << [current_translation, working_candidate]
    end
  end
=end
  protected
    def translation_helper current_set, index, translation
      if translation.class == Fixnum
        current_set[index + translation - 1].to_s
      else
        translation
      end
    end

    def extract_repetition_character subrule, current_match, current_set, working_candidate
      match, temp_working_candidate = subrule.extract(working_candidate)
      additional_productions = []
      if match
        matches = self.extract(temp_working_candidate)
        matches.each do |more_match, repetition_working_candidate, repetition_current_set|
          if more_match
            current_set << [ match ]

            current_set.concat [repetition_current_set]

            working_candidate = repetition_working_candidate
            additional_productions << [ current_match + match + more_match,
                                         repetition_working_candidate.dup,
                                         current_set.dup ]
          end
        end
      end
      return [ [current_match, working_candidate, current_set] ] if additional_productions.size == 0
      additional_productions
    end

    def copy_set set
      set.inject([]){|cloned_set, element|
        cloned_set << element
      }
    end
end
