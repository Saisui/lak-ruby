require 'ostruct'

class JSONLines

  #
  # USAGE:
  # 
  #  SCHEME
  #
  #    js = JSONLines.new('test.jsonl') do |json,db|
  #      json['id'] = db.size+1
  #      json['creat_time'] = Time.now.to_i
  #    end
  #
  #    js = JSONLines.new('test.jsonl') do |json, db|
  #      eval File.read('test.schema.rb'), binding
  #    end
  #
  #  UNIQUE
  #
  #    js.insert(name:) if js.select(name:).empty?
  #
  #    # schema.rb
  #
  #    unless db.select(name: json['name']).empty?
  #      raise 'SameName'
  #    end
  #
  #    raise 'same name' if db.has?(name: json['name'])
  #
  #    db.uniq :name
  #
  #  CONSTRICT
  #
  #    db.must { age > 20 }
  #    db.must age: -> { _1 > 21 }
  #    db.deny { age < 21 }
  #
  #  INCREASING
  #
  #    json[:id] = db.size + 1
  #    json[:creat_time] = Time.now.to_i
  #
  #  LIMIT
  #
  #    raise 'under age' if json['age'] ? json['age'] < 21 : true
  #
  #  INSERT
  #
  #    js.insert name: 'mine'
  #
  #  DELETE
  #
  #    js.select(name: 'mine').each(&:clear)
  #
  #  CHECK
  #
  #    js.select(age: -> { _1 < 21 })
  #
  #    js.select { age < 21 }
  #
  #  UPDATE
  #
  #    # UPDATE (sex) VALUES ('loli') WHERE (name = 'mine')
  #    js.select name: 'mine' do |j|
  #      j['sex'] = 'loli'
  #    end
  #
  #    js.select name: 'me' do |j|
  #      j['score'] += 15
  #    end
  #
  #    js.update grade: 'adult' do
  #      age > 20 && type == 'human'
  #    end
  #
  #  SAVE & RELOAD
  #
  #    js.save
  #    js.reload
  #
  def initialize filename, auto: nil, &auto_trig
    @jsons = File.read(filename).lines.map { JSON(_1) }
    @file = filename
    @auto = auto ? proc{|json,db| eval File.read(auto), binding } : auto_trig
  end

  attr :file, :jsons
  attr_accessor :auto

  alias all jsons

  def select **key_conds, &blk
    if key_conds.empty?
      all.select {
        OpenStruct.new(_1).instance_eval(&blk)
      }
    else
      js = @jsons.select do |j|
        key_conds.map { |k, cond|
          cond === j[k.to_s]
        }.all?
      end

      if blk
        js.map(&blk)
      else js
      end
    end
  end

  def size
    @jsons.size
  end

  def insert **kws

    j = JSON(kws.to_json)
    @json = j

    auto.call(j,self) if @auto
    @jsons << j

    self
  end

  def to_jsonlines
    @jsons.map{_1.to_json}.join("\n")+"\n"
  end
  
  alias to_jsonl to_jsonlines

  def save
    File.write(@file, to_jsonline)
    self
  end

  def reload
    @jsons = File.read(@file).lines.map { JSON(_1) }
    self
  end

  def has? **kws
    !select(**kws).empty?
  end

  def uniq key
    raise "KEY [#{key}] VALUE already exist!" if has? key => @json[key.to_s]
  end

  def must key=nil, **kws, &blk
    if key
      raise "CONDITION [#{key}] not assume!" unless blk.call(@json[key.to_s])
    elsif blk
      raise "CONDITION not assume!" unless OpenStruct.new(@json).instance_eval(&blk)
    elsif !kws.empty?
      kws.each_pair do |k, c|
        raise "CONDITION [#{k}] not assume!" unless c  === @json[k.to_s]
      end
    end
  end

  def deny key=nil, **kws, &blk
    if key
      raise "DENY CONDITION [#{key}] is assume!" if blk.call(@json[key.to_s])
    elsif blk
      raise "DENY CONDITION is assume!" if OpenStruct.new(@json).instance_eval(&blk)
    elsif !kws.empty?
      kws.each_pair do |k, c|
        raise "DENY CONDITION [#{k}] is assume!" if c  === @json[k.to_s]
      end
    end
  end

  def update **kws, &blk
    select(&blk).each {|j|
      j.merge!(kws.map {|k, v|
        if v in Proc
          [k.to_s, v.call(j[k.to_s])]
        else [k.to_s, v]
        end
      }.to_h)
    }
    self
  end

  def to_table
    keys = @jsons.map(&:keys).flatten.uniq.map(&:to_s).uniq
    [keys] + @jsons.map { _1.values_at(*keys) }
  end

end
