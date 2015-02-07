class Repetition < Terminal
  def initialize param
    unless %w{String}.include? param.class.name
      raise ArgumentError.new("expected String; got #{param.class.name}")
    end

    @terminal = Regexp.compile "^(" + Regexp.escape(param) +")"
  end
end
