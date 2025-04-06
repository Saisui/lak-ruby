# Copyright Saisui@github.io
#
# FEATURES
#
# - end with bracket
# - endless
# - orignal ruby code
# - comment linear eval code
# - comment linear replacement
# 
#
# endless_ruby(code)
#
# code is:
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
# #> @verbs = "GET|POST"
# #/ s.gsub(/^#{@verbs}$/) { "o.is(o.verb(#{}))" }
# #/ s.gsub(/^- (.*) : (.*)$/) { "o.on #{$1} do |#{$2}|"
# #/ s.gsub(/^- (.*)$/) { "o.on #{$1} do" }
def replace_short ss

  to_run = []

  begin_runs = []

  end_runs = []

  ret = ''

  ss = ss.gsub /^(\s*)#import\s+(\S*)$/ do
    File.read($2).lines.map { $1 + _1 }.join
  end

  ss.lines.each do |s|
    if s in /^\s*#BEGIN\s+(.*)$/
      begin_runs << $1
    end
  end

  s_begin = proc do
    s = ''
    begin_runs.each {
      eval _1, binding
    }
    s
  end.call
  ssl = ["\n"]+ss.lines

  @parents = []

  ret << ssl.each_with_index.map do |s, i|

    if i == 0
      @prev = "\n"
    else
      @prev = ssl[i-1]
    end

    next if s in /\A\s*$/
 
    @prev_indent = @prev.match(/\A(\s*)/)[0].size

    if i == ssl.size-1
      @post = "\n"
    else
      @post = ssl[i+1]
    end

    @post_indent = @post.match(/\A(\s*)/)[0].size

    @s_indent = s.match(/\A(\s*)/)[0].size

    if @post_indent > @s_indent
      @parents << s.dup
    end

    until @parents.empty? || @post_indent > @parents.last.match(/\A(\s*)/)[0].size
      @parents.pop
    end

    @parent = @parents.last

    @in_end   = @post_indent > @s_indent
    @in_begin = @prev_indent < @s_indent

    _, bs, sb = [*s.match(/\A(\s*)(.*)\z/)]
    
    if s in /^\s*#>\s+(.*)$/
      eval $1
      next
    end

    if s in /^\s*#BEGIN\s+/
      next
    end

    if s in /#END\s+(.*)$/
      end_runs << $1
      next
    end

    if s in /#\/\s+(.*)$/
      to_run << $1
      next
    end

    if s !~ /^\s*#/
      for p in to_run
        s = eval(p, binding) || s
      end
    end
 
    s
  end.join

  end_runs.each do |ev|
    eval ev, binding
  end
  
  s_begin + ret

end

if $0 == __FILE__
  puts endless_ruby replace_short File.read ARGV[0]
end
