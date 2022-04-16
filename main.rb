require "csv"
require "json"

require "benchmark"

CSV_FILEPATH = "./db.csv"

def search(key, q)
  rst = []

  CSV.foreach(CSV_FILEPATH, headers: true) do |row|
    rst << row.to_h if row[key] && row[key].downcase.include?(q)
  end
  rst
end

class Index
  attr_accessor :row, :key, :line_number

  def initialize(row, key, ln)
    @row = row
    @key = key
    @line_number = ln
  end
end

def index(key)
  rst = []

  line_num = 0
  indexes = {}
  CSV.foreach(CSV_FILEPATH, headers: true) do |row|
    data = row.to_h
    ngrams = data[key].each_char
      .each_cons(3)
      .map { |chars| chars.join.downcase }
    ngrams.each do |w|
      indexes[w] = [] unless indexes[w]
      indexes[w] << line_num
    end

    line_num += 1
  end
  File.write("./indexes/#{key}.json", indexes.to_json)
end

def index_search(k, q, index_json)
  ngrams = q.each_char
    .each_cons(3)
    .map { |chars| chars.join.downcase }
  line_nums = ngrams
    .filter { |w| index_json[w] }
    .map { |w| index_json[w] }
    .flatten
    .uniq
    .sort
  max = line_nums[-1]

  line_num = 0
  rst = []
  CSV.foreach(CSV_FILEPATH, headers: true) do |row|
    if line_nums[0] == line_num
      rst << row.to_h
      line_nums = line_nums.drop(1)
    end
    break if line_nums.size.zero? || line_num >= max
    line_num += 1
  end
  rst
end

def search_center(key, q, indexes)
  if indexes[key]
    rst = index_search key, q, indexes[key]
  else
    rst = search key, q
  end
  # rst.each_with_index do |x, i|
  #   return if i > 9
  #   puts x["name"]
  # end
  rst
end

loop {
  indexes = {}
  Dir.glob("./indexes/*.json").each do |fp|
    k = File.basename(fp).split(".")[0]
    index_json = JSON.parse(File.read("./indexes/#{k}.json"))
    indexes[k] = index_json
  end
  print "command[search, index, quit]: "
  cmd = gets.chomp
  if cmd === "quit"
    puts "quit."
    exit
  end

  if cmd === "search"
    print "key: "
    key = gets.chomp

    print "query: "
    q = gets.chomp

    Benchmark.bm 10 do |r|
      r.report "search" do
        search_center key, q, {}
      end
      r.report "index search" do
        search_center key, q, indexes
      end
    end

    puts "success."
  elsif cmd === "index"
    print "key: "
    key = gets.chomp

    index key
    puts "success."
  end
}
