# coding: utf-8
require "csv"
require "json"

# 上から順番に検索していく。
module LinerSearch
  # csv_filepath
  # index_path
  def search(key, q)
    rst = []

    CSV.foreach(self.csv_filepath, headers: true) do |row|
      rst << row.to_h if row[key] && row[key].include?(q)
    end
    rst
  end
end
