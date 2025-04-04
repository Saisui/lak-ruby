require 'sinatra'

def pyramid(arr)
  arr.each_with_index.map do |a,i|
    arr[...i+1]
  end
end

get '/**' do
  @path = params[:splat].join
  @path = '.' if @path.empty?
  @sort = params['sort']
  pp @path
  if File.file?(@path)
    if File.extname(@path) in /erb|rb|json|psy/
      content_type 'text'
      File.binread(@path)
    else
      send_file @path
    end
  elsif Dir.exist? @path
    @nodes = Dir[@path+'/*']#.sort_by {File.file?(_1) ? 1 : 0}
    @nodes = case @sort
    when '-name'
      @nodes.sort_by { _1 }.reverse
    when '-size'
      @nodes.sort_by { File.size _1 }.reverse
    when '-mtime'
      @nodes.sort_by { File.mtime(_1) }.reverse
    when 'ext'
      @nodes.group_by { File.extname(_1) }.values.map {|fs| fs.sort_by {|f| f } }.flatten
    when '-ext'
      @nodes.group_by { File.extname(_1) }.values.map {|fs| fs.sort_by {|f| f } }.reverse.flatten
    when 'name'
      @nodes.sort_by { _1 }
    when 'size'
      @nodes.sort_by { File.size _1 }
    when 'mtime'
      @nodes.sort_by { File.mtime(_1) }
    else @nodes
    end
    slim :toc
  else slim "h1 miss\nb: i "+@path
  end
end

__END__

@@toc
meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0"
meta charset='utf-8'
css:
  .dir { color: orange }
  .count { color: red }
  .file { color: blue }
  .size { color: green }
  .title { position: sticky; top: 0 }
  .nav span { color: blue }
title 
  = @sort
  | :
  = @path
nav.title
  h1
    | in
    a href='/' .
    - for path in pyramid(@path.split('/'))
      span = '/'
      a href=('/'+path.join('/')) = path.last
    span.count = "[#{@nodes.size}]"
  .
    .
      - for mode in %w[name mtime size ext]
        = ' / '
        span: a href=("?sort=#{mode}") = ' '+mode
    .
      - for mode in %w[-name -mtime -size -ext]
        = ' / '
        span: a href=("?sort=#{mode}") = mode
table#nodes
  tr
    td
    td: a href='/' = '/'
  tr
    td
    td: a href='../' ../
  - @nodes.each do |n|
    - if File.file? n
      - ext = File.extname n
      - sz = File.size(n)
      - b = Math.log(sz,1024)
      tr[data-size=sz data-name=n data-ext=ext
          data-mtime=File.mtime(n).to_i]
        td.ext = ext
        td: a.file href=('/'+n) = n.split('/').last
        td
          - if b < 1
            span.size #{sz} B
          - else
            span.size = (sz.to_f / 1024**b.to_i).ceil(2)
            = ' ' + %w[B KB MB GB][b.to_i]
        td.mtime = File.mtime(n).strftime '%y/%m/%d %H:%M:%S'
    - else
      tr
        td.ext Dir
        td: a.dir href=('/'+n) = n.split('/').last+'/'
        td.count = Dir[n+'/*'].size
