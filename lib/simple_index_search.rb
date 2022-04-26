# coding: utf-8
require "csv"
require "json"

# インデックスからデータを取得し、インデックス最大値まで読み取る
module SimpleIndexSearch
  # csv_filepath
  # index_path
  # インデックスファイルがない場合は通常検索を行うため
  include LinerSearch

  def index(key)
    line_num = 0
    indexes = {}
    CSV.foreach(self.csv_filepath, headers: true) do |row|
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
    File.write("#{self.index_path}/#{key}.json", indexes.to_json)
  end

  # インデックスを読み取ってくれる
  def read_index_search(k, q)
    index_json = JSON.parse(File.read("#{self.index_path}/#{k}.json"))
    self.index_search(k, q, index_json)
  end

  # インデックスデータを渡す
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
    CSV.foreach(self.csv_filepath, headers: true) do |row|
      if line_nums[0] == line_num
        rst << row.to_h
        line_nums = line_nums.drop(1)
      end
      break if line_nums.size.zero? || line_num >= max
      line_num += 1
    end
    rst
  end
end
