# 做了个 Ruby JSONLines 的库

rubygems 上的 jsonl 库太简陋了，简直尸位素餐。

## 用法

```ruby
js = JSONLines.new('test.jsonl') do |json, db|
  json['id'] = db.size + 1
  json['create_time'] = Time.now.to_i
  json['pro'] ||= false
  db.uniq :name
  db.must { age >= 21 }
  
end

js.insert name: 'hi', age: 33

js.update type: 'otonari' do
  age > 20
end

puts js.select { age > 20 }

js.save
```

单进程使用，不考虑读写性能，基本代替 SQL

不用复杂依赖。

源码只有100行


## 单文件 schema


在 .jsonl 文件顶部写 schema，schema 和 jsonl 本体用 `---` 隔开。

```ruby
json['id'] = db.size + 1
json['create_time'] = Time.now.to_i
json['pro'] ||= false
db.uniq :name
db.must { age >= 21 }
---
{"name":"reimu","id":1,"pro":false,"create_time":1145141919}
{"name":"nene","id":2,"pro":true,"create_time":11407210721}
{"name":"komeiji_koishi","id":3,"pro":true,"create_time":514514514}

```

加载和保存只需…
```ruby
people = JSONLines.new("people.jsonl")
people.insert(name: "marisa", age: 114)
people.save
people.reload
```
