class Terminal

  def initialize param
    unless %w{Regexp String}.include? param.class.name
      raise ArgumentError.new("expected Regular Expression or String; got #{param.class.name}")
    end
    param = param.class == String ?
              param = Regexp.escape(param) :
              param.source

    @terminal = Regexp.compile "^(" + param +")"
  end

  def match? string
    (@terminal =~ string) == 0
  end

  def extract string
    return [nil, string] unless @terminal =~ string
    terminal_match = $1
    [ $1, string[terminal_match.length..-1] ]
  end

end
