class TranslationRepetitionSet

  def initialize offset = 1, *translations
    @offset = set_offset( offset )
    @translations = set_translations( translations )
  end

  def set_offset offset
    if offset.class.name != "Fixnum"
      raise ArgumentError.new("expected Fixnum; got '#{offset.class.name}'")
    elsif offset <= 0
      raise ArgumentError.new("expected positive Fixnum; got '#{offset}'")
    end

    @offset = offset.to_i
  end

  def set_translations *translations
    good_parts = []
    [ translations ].flatten.each do |translation|
      if ! [Fixnum, String].include? translation.class
        raise ArgumentError.new("expected Fixnum or String; got #{translation.class.name}")
      elsif translation.class == Fixnum and translation <= 0
        raise TranslationRepetitionSetError.new("subrule number cannot be less than 1")
      end
      good_parts << translation
    end
    @translations = good_parts
  end

end
