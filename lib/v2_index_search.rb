require "csv"
require "json"

require_relative "./liner_search.rb"
# 機能をクラス名にいれていくと長くなるのである程度機能固まるまで暫定でバージョン名
# 機能的には
# FileIndex + Partition
class V2Search < LinerSearch
  attr_accessor :part_csv_pathes

  def partition(n = nil)
    @part_csv_pathes = []
    n = @row_size / 5 if n.nil?
    bname = File.basename(@csv_filepath)
    CSV.readlines(@csv_filepath, headers: true)
      .each_slice(n)
      .to_a
      .each_with_index do |x, i|
      header_s = x[0].headers.join(",") + "
"
      part_csv_path = "#{@index_path}/#{bname}.#{i}"
      File.open(part_csv_path, "w") do |f|
        f.write(([header_s] + x.map(&:to_csv)).join(""))
      end
      @part_csv_pathes << part_csv_path
    end
  end

  def index(key)
    if @part_csv_pathes.size <= 0
      raise Exception.new("not partition error")
    end
    @part_csv_pathes.each do |cpath|
      num = File.basename(cpath).split(".").last
      i_dir_path = "#{@index_path}/#{num}"
      Dir.mkdir(i_dir_path) unless Dir.exist?(i_dir_path)

      line_num = 0
      indexes = {}
      CSV.foreach(cpath, headers: true) do |row|
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
      indexes.keys.each do |k|
        File.write("#{i_dir_path}/#{key}.index", indexes[k].join(","))
      end
    end
  end

  def parse_index(w)
    if @part_csv_pathes.size <= 0
      raise Exception.new("not partition error")
    end
    index_table = []
    @part_csv_pathes.sort.each do |cpath|
      num = File.basename(cpath).split(".").last
      i_dir_path = "#{@index_path}/#{num}"
      v = w.chars.map(&:downcase).map(&:ord).map { |x| x.to_s(16) }.join()
      i_path = "#{i_dir_path}/#{v}.index"
      next unless File.exist?(i_path)
      index_table << File.read(i_path).split(",")
    end
    index_table
  end

  def index_search(key, q)
    if @part_csv_pathes.size <= 0
      raise Exception.new("not partition error")
    end
    bname = File.basename(@csv_filepath)
    result = q.each_char
      .each_cons(3)
      .map { |chars| chars.join.downcase }
      .inject({}) { |acm, x| acm.merge(self.parse_index(w)) { |k, ol, nw| (ol + nw).uniq } }
    rst = []
    # TODO: 複数パートファイルを走査する際にはreadlineで複数ファイル同時で進める
    result.each_with_index do |lines, num|
      line_nums = lines.sort.uniq
      line_num = 0
      part_csv_path = "#{@index_path}/#{bname}.#{num}"
      CSV.foreach(part_csv_path, headers: true) do |row|
        if line_nums[0] == line_num
          rst << row.to_h
          line_nums = line_nums.drop(1)
        end
        break if line_nums.size.zero? || line_num >= max
        line_num += 1
      end
    end
    rst
  end
end
