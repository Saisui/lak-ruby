require 'erio'

class Erio

  enter do |o|

    #/ s.gsub(/^(\s*)- (.*?) : (.+?)$/) { $1 + "o.on #{$2} do |#{$3}|" }
    #/ s.gsub(/^(\s*)=(.*?) : (.+?)$/) { $1 + "o.is #{$2} do |#{$3}|" }
    #/ s.gsub(/^(\s*)- (.*?)$/) { $1 + "o.on #{$2} do" }
    #/ s.gsub(/^(\s*)=(.*?)$/) { $1 + "o.is #{$2} do" }

    = '/'

      o.status 200
      o.echo 'hello, world'

    - 'video'

      =

        o.echo 'videos'

      = Integer : num

        o.echo "video: #{num}"

    - true

      o.status 404
      o.echo 'Not Found'

run Erio
