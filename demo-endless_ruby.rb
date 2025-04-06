#import demo-erio.d.edrb

class Erio

  enter do |o|
    #/ s.gsub(/^(\s*)\+ (.*?)$/) { $1 + "o.echo(#{$2})" }
    #/ s.gsub(/^(\s*)\+\+ (.*?)$/) { $1 + "o.echoln(#{$2})" }
    = '/'

      200
      + 'hello, world'

    - 'videos'

      200

      GET
 
        + 'GET videos'

      = Integer : num

        + "video: #{num}"

    - true

      404
      + 'Not Found'
