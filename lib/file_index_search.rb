# coding: utf-8
require "csv"
require "json"

# インデックスからデータを取得し、インデックス最大値まで読み取る
class FileIndexSearch < LinerSearch
  def index(key)
    self.base_index(key, @csv_filepath, @index_path)
  end

  def base_index(key, cpath, i_dir_path)
    line_num = 0
    indexes = {}
    CSV.foreach(cpath, headers: true) do |row|
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
      ipath = "#{i_dir_path}/#{k}.index"
      i_list_s = indexes[k].join("")
      File.open(ipath, "w") do |f|
        f.write(i_list_s)
      end
    end
  end

  def parse_index(w)
    v = w.chars.map(&:downcase).map(&:ord).map { |x| x.to_s(16) }.join()
    ipath = "#{@index_path}/#{v}.index"
    return nil unless File.exist?(i_path)
    self.base_parse_index(w, ipath)
  end

  def base_parse_index(w, i_path)
    File.read(i_path).split("
")
  end

  # インデックスデータを渡す
  def index_search(k, q)
    self.base_index_search(k, q, @index_path)
  end

  def base_index_search(k, q, i_dir_path)
    ngrams = q.each_char
      .each_cons(3)
      .map { |chars| chars.join.downcase }
    ngrams
      .map { |x| base_parse_index(x, "#{i_dir_path}/#{x}.index") }
      .filter { |x| !x.nil? }
      .flatten
      .uniq
      .sort
  end
end
