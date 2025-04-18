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
  alias to_jsonl to_jsonlines

  def select **key_conds, &blk
    if key_conds.empty?
      require 'ostruct'
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
    auto.call(j,self) if @auto
    @jsons << j
    self
  end

  def to_jsonlines
    @jsons.map{_1.to_json}.join("\n")+"\n"
  end

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

end
