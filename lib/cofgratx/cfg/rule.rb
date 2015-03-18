class Rule
  attr_reader :rule, :translation, :translation_error_message

  def initialize subrules = [], translations = []
    @translation_error_message = nil
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
          @translation_error_message = "rule does not contain repetition"
          return false
        elsif part.translations.select{|tx| tx.class == Fixnum and tx > @rule.size}.count > 0
          @translation_error_message = "rule contains fewer parts than the TranslationRepetitionSet has for a translation: #{part.translations.inspect}"
          return false
        end
      elsif part.class == Fixnum
        @translation_error_message = "rule contains fewer parts than translation number: #{part.inspect}"
        return false if part > @rule.size
      end
    end
    true
  end

  def match? candidate
    extract(candidate).first[0] != nil
  end

  def extract candidate, translate_non_terminals = false
    working_matches = [ ["",candidate.dup,[[]]] ]

    @rule.each do |subrule|
      surviving_matches = []
      working_matches.each do |current_match, working_candidate, current_set|

        if subrule.class == Repetition
          surviving_matches.concat extract_repetition_character subrule, current_match.dup, deep_clone_a_set(current_set), working_candidate.dup, translate_non_terminals
        elsif subrule.class == Terminal
          match, working_candidate = subrule.extract working_candidate
          if match
            current_set.first << match
            surviving_matches << [ current_match + match, working_candidate.dup, deep_clone_a_set(current_set) ]
          end
        elsif subrule.class == NonTerminal
          matches = if translate_non_terminals
                      translations = subrule.translate(working_candidate).select{|tx| tx[0]}
                      translations.map{|tx| tx[2] = deep_clone_a_set(current_set); tx[2].first << tx[0].dup; tx }
                      translations
                    else
                      subrule.extract(working_candidate)
                    end

          if matches.size > 0 and matches.first[0]
            surviving_matches.concat matches
          end
        else
          raise "Rule is corrupt, found a bad subrule:#{subrule} with class:#{subrule.class}"
        end
      end
      working_matches = surviving_matches.dup
    end
    return [ [nil,candidate,[[]]] ] if working_matches.size == 0

    working_matches
  end

  def translate candidate
    matches = extract candidate, true
    translations = matches.inject([]) do |txs, match|
      current_match, working_candidate, current_set = match
      next txs << [nil, candidate] unless current_match
      next txs << [current_set.join(""), working_candidate.dup] unless @translation.size > 0
      current_translation = ""
      @translation.each do |sub_translation|
        if sub_translation.class == TranslationRepetitionSet
          current_set[(sub_translation.offset-1)..-1].to_a.each do |current|
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
    return [ [nil, candidate] ] unless translations.size > 0
    translations
  end

  protected
    def translation_helper current_set, translation
      if translation.class == Fixnum
        current_set[translation-1].to_s
      else
        translation
      end
    end

    def extract_repetition_character subrule, current_match, current_set, working_candidate, translate_non_terminals
      match, temp_working_candidate = subrule.extract(working_candidate)
      additional_productions = []
      if match
        matches = self.extract(temp_working_candidate,translate_non_terminals)
        matches.each do |more_match, repetition_working_candidate, repetition_current_set|
          if more_match
            first_current_set = current_set.first.dup

            first_current_set << match

            repetition_current_set.unshift first_current_set

            working_candidate = repetition_working_candidate
            additional_productions << [ current_match + match + more_match,
                                         repetition_working_candidate.dup,
                                         deep_clone_a_set(repetition_current_set) ]
          end
        end
      end
      return [ [current_match, working_candidate, deep_clone_a_set(current_set)] ] if additional_productions.size == 0
      additional_productions
    end

    def deep_clone_a_set set
      set.inject([]){ |s, subset|
        s << subset.inject([]){ |ss, string|
          ss << string.dup
        }
      }
    end
end
