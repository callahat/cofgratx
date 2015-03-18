# Cofgratx

This is a context free grammar translation gem. Define a grammar (with or without some translations),
feed it a string with a starting rule, and it returns a array of possible translations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cofgratx'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cofgratx

## Usage

The Grammar class is the main entry point. This class is where rules/productions are defined.

### Adding rules and translations

Rules are made up of Terminals, Repetitions (a special kind of terminal), and other rules.

Terminals can be defined as a string, or regular expression.

    Terminal.new "a"
    Terminal.new /a/

Repetitions can only be defined as a string. These will be the last part of a rule and indicate that the rule may repeat when this is found.

    Repetition.new ","

Translations are made up of Translation Repetition Sets (if the rule has a repetition), integers and strings. The Translation Repetition Set (TRS) is also made up of an offset (which repeated set to begin with), followed by integers and strings. The strings are straight up substitution, and the integers represent a smaller part of the rule.

For example, given:

    abc = Terminal.new /a|b|c/
    comma = Repetition.new ","

    trs = TranslationRepetitionSet.new(2, " third:", 3)

    g = Grammar.new
    g.add_rules :S, [ [ abc, abc, abc, comma ], [4,3,2,1,":",trs] ]

    g.translate "abc,cba,bac,acb", :S

     => [[",cba: third:a third:c third:b", ""]]

The TRS adds to the translated string by starting with the second repeated match ("cba,") and prints the string "third:" followed by the third character from the match set.


## Contributing

1. Fork it ( https://github.com/callahat/cofgratx/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
