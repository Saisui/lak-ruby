# Copyright Saisui@github.io
#
# - end with bracket
# - endless
# - orignal ruby code
#
#
# endless_ruby(code)
#
#   ruby:
#     ss = <<~SLIM
#       body
#         ul
#           - 3.times do |i|
#             li = i
#     SLIM
#
#   def hello(
#       name,
#       age,
#     )
#
#     if name == 'madoka'
#       puts 'hello, kamisama!'
#     else
#       puts "hello, #{name}!"
#
#     {
#       character: name,
#       charsize: name.size
#       age:,
#     }
#
def endless_ruby ss
  lines = []

  ss,data = ss.split(/^(__END__.*)\z/m)

  ss.lines.each do |s|
     if lines.last in /[^\\]\\$/
       lines.last << s.lstrip
     elsif s in /^\s*$/
       lines.last << s
     else lines << s
     end
  end

  nls = lines.map do |s|
    s =~ /\A( *)(.*)\z/m
    [$1.size, $2]
  end

  lacks = []

  ret = ''

  is_ruby = false

  ruby_ind = 0

  nls.each_with_index do |(ind, s), i|
 
    if s in /^ruby:$/
      is_ruby = true
      ruby_ind = ind
      next
    end

    if ind <= ruby_ind and is_ruby
      is_ruby = false
    end
 
    if is_ruby
      ret << (' '*ind+s)
      next
    end
 
    if i == 0
      ret << s
      next
    end

    if ind > nls[i-1][0]
      lacks << nls[i-1][0]
    end

    if nls[i-1][0] > ind
      until (lacks.last < ind rescue true)
        ret << (' ' * lacks.pop+"end\n\n")
      end
      ret << ' '*ind+s
    else
      ret << ' '*ind+s
    end

  end

  ret << "\n"

  until lacks.empty?
    ret << ' '*lacks.pop+"end\n"
  end

  ret.gsub(/^\s*end\s*\r?\n(?=\s*(?:when|else|elsif|rescue|ensure|[\}\]\)]+))/,'') + (data||'')
  
end

# example
# #/ s.gsub(/^- (.*) : (.*)$/) { "o.on #{$1} do |#{$2}|"
# #/ s.gsub(/^- (.*)$/) { "o.on #{$1} do" }
def replace_short ss

  to_run = []

  ss.lines.map do |s|
    if s in /#\/(.*)$/
      to_run << $1
    end
    for p in to_run
      s = eval(p, binding) || s
    end
    s
  end.join

end

if $0 == __FILE__
  puts replace_short endless_ruby File.read ARGV[0]
end
