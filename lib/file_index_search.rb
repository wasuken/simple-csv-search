# coding: utf-8
require "csv"
require "json"

# インデックスからデータを取得し、インデックス最大値まで読み取る
module FileIndexSearch
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
        wtoh = w.chars.map(&:downcase).map(&:ord).map { |x| x.to_s(16) }.join()
        indexes[wtoh] = [] unless indexes[wtoh]
        indexes[wtoh] << line_num
      end

      line_num += 1
    end
    indexes.keys.each do |k|
      ipath = "#{self.index_path}/#{wtoh}.index"
      i_list_s = indexes[k].join(",")
      File.open(ipath, "w") do |f|
        f.write(i_list_s)
      end
    end
  end

  def parse_index(w)
    v = w.chars.map(&:downcase).map(&:ord).map { |x| x.to_s(16) }.join()
    return [] unless File.exist?("#{self.index_path}/#{v}.index")
    File.read("#{self.index_path}/#{v}.index").split(",").map(&:to_i)
  end

  # インデックスデータを渡す
  def index_search(k, q)
    ngrams = q.each_char
      .each_cons(3)
      .map { |chars| chars.join.downcase }
    line_nums = ngrams
      .map { |x| parse_index(x) }
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
