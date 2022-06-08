# coding: utf-8
require "csv"
require "json"

# インデックスからデータを取得し、インデックス最大値まで読み取る
class FileIndexSearch < LinerSearch
  def index(key)
    line_num = 0
    indexes = {}
    CSV.foreach(@csv_filepath, headers: true) do |row|
      data = row.to_h
      ngrams = data[key].each_char
                 .each_cons(3)
                 .map { |chars| chars.join.downcase }
      ngrams.each do |w|
        wtoh = w.chars.map(&:downcase).map(&:ord).map { |x| x.to_s(16) }.join()
        indexes[wtoh] = [] unless indexes[wtoh]
        indexes[wtoh] << row.to_csv
      end

      line_num += 1
    end
    indexes.keys.each do |k|
      ipath = "#{@index_path}/#{k}.index"
      i_list_s = indexes[k].join("")
      File.open(ipath, "w") do |f|
        f.write(i_list_s)
      end
    end
  end

  def parse_index(w)
    v = w.chars.map(&:downcase).map(&:ord).map { |x| x.to_s(16) }.join()
    return nil unless File.exist?("#{@index_path}/#{v}.index")
    File.read("#{@index_path}/#{v}.index").split("\n")
  end

  # インデックスデータを渡す
  def index_search(k, q)
    ngrams = q.each_char
               .each_cons(3)
               .map { |chars| chars.join.downcase }
    ngrams
      .map { |x| parse_index(x) }
      .filter{|x| !x.nil? }
      .flatten
      .uniq
      .sort
  end
end
