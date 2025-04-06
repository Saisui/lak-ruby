# lak-ruby
Ruby Utils

## Endless Ruby

input

```ruby
ruby:
  b = proc { hello
  }

def mine(
    name,
    age,
  )
  if a
    b
  else
    {
       t: Time.now.to_i,
       rand: rand,
    }
```

output:

```ruby
b = proc { hello
}

def mine(name, age)
  if a
    b
  else
    {
      t: Time.now.to_i,
      rand: rand,
    }
  end
end
```

- endless
- ruby code
- bracket end
- replace
- eval
- begin & end

## COMPLEX EXAMPLE

Rack App Template

```ruby
#import erio.d.edrb
#import erio.d.edrb

= '/'

  200
  'hello, world'

- 'videos'

  200

  GET

    'GET videos'

  = Integer : num

    "video: #{num}"

- true

  404
  'Not Found'
```

its imported config

```ruby

#BEGIN s << "require 'erio'\n"
#BEGIN s << "\nclass Erio\n"
#BEGIN s << "\n  enter do |o|\n"

#> @verbs = "GET|POST|DELETE|UPDATE|HEAD|PUT|CONNECT|OPTIONS|TRACE|PATH"
#/ s.gsub(/^(\s*)enter$/) { $1 + 'enter do' }
#/ s.gsub(/^(\s*)enter : (\w+)$/) { $1 + 'enter do |#{$2}|' }
#/ s.gsub(/^(\s*)(#{@verbs})$/) { $1 + + "o.is o.verb(#{$2.downcase.inspect}) do" }
#/ s.gsub(/^(\s*)(#{@verbs}) (.*): (.+?)$/) { $1 + "o.is(o.verb(#{$2.downcase.inspect}), #{$3}) do |_, #{$4}|" }
#/ s.gsub(/^(\s*)(#{@verbs})(.*)$/) { $1 + "o.is(o.verb(#{$2.downcase.inspect}), #{$3}) do" }
#/ s.gsub(/^(\s*)- (.*?) : (.+?)$/) { $1 + "o.on #{$2} do |#{$3}|" }
#/ s.gsub(/^(\s*)=(.*?) : (.+?)$/) { $1 + "o.is #{$2} do |#{$3}|" }
#/ s.gsub(/^(\s*)- (.*?)$/) { $1 + "o.on #{$2} do" }
#/ s.gsub(/^(\s*)=(.*?)$/) { $1 + "o.is #{$2} do" }
#/ s.gsub(/^(\s*)(\d+)$/) { $1 + "o.status #{$2}" }
#/ s.gsub(/^(\s*)\+ (.*?)$/) { $1 + "o.echo(#{$2})" }
#/ s.gsub(/^(\s*)\+\+ (.*?)$/) { $1 + "o.echoln(#{$2})" }
#/ if @parent in /^\s*=($|[^=]+)/ and sb =~ /^(['"].+)$/; bs + "o.echoln(#{$1})"; else s; end

#END ret = ret.lines.map { '    ' + _1 }.join
#END ret << "\nrun Erio"

```

Finally, Let's run
```
ruby endless_ruby.rb config.ru.edrb > config.ru
```

its output:

```ruby





require 'erio'

class Erio

  enter do |o|
    o.is  '/' do

      o.status 200
      o.echo('hello, world')

    end

    o.on 'videos' do

      o.status 200

      o.is o.verb("get") do
 
        o.echo('GET videos')

      end

      o.is  Integer do |num|

        o.echo("video: #{num}")

      end

    end

    o.on true do

      o.status 404
      o.echo('Not Found')

    end
  end
end

run Erio
```
