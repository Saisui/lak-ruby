require 'json'

class Array
  
  def pyramid
    each_with_index.map do |a,i|
      arr[...i+1]
    end
  end

  def % n
    each_with_index.group_by do |a,i|
      i / n
    end.values
  end

  def / n
    each_with_index.group_by do |a,i|
      i / (size / n)
    end.values
  end

  def split_when &blk
    ret = [[]]
    each_with_index do |a,i|
      if yield(a,i)
        ret.last << a
      else
        ret << [a]
      end
    end
  end

  def fill_to n, obj = nil
    self + ([obj]*(n-size) rescue [])
  end

  def aa2ha
    th = self[0]
    ths = th.size
    trs = self[1..].map { _1.fill_to ths, nil }
    trs.map { th.zip(_1) }.to_h
  end

  def ha2aa
    ths = map(&:keys).flatten.uniq
    [ths] + map { _1.slice(ths) }
  end

  def to_tsv jsonify = false
    map { _1.map {|s| (s.to_s in /^"|\n|\t/) ? s.to_s.to_json : s.to_s }.join("\t") }.join("\n")
  end
end

class String
  
  def split_many(*pats)
    
    def split_arr(arr,*pats)
      if pats==[]
        arr.dup
      else
        arr.map { _1.split_many(*pats) }
      end
    end
    
    split_arr(split(pats[0]), *pats[1..])
  end

  def tsv2aa
    split_many("\n","\t").map { _1.map {|s| (s in /^"/) ? JSON(s) : s } }
  end
  
  def tsv2ha
    tsv2aa.aa2ha
  end
end
