class TranslationRepetitionSet

  attr_accessor :offset, :translations

  def initialize offset = 1, *translations
    self.offset = offset
    self.translations = translations
  end

  def offset= offset
    if offset.class.name != "Fixnum"
      raise ArgumentError.new("expected Fixnum; got '#{offset.class.name}'")
    elsif offset <= 0
      raise ArgumentError.new("expected positive Fixnum; got '#{offset}'")
    end

    @offset = offset.to_i
  end

  def translations= *translations
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
