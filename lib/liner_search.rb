# coding: utf-8
require "csv"
require "json"

# 上から順番に検索していく。
module LinerSearchModule
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

class LinerSearch
  attr_accessor :csv_filepath, :index_path
  include LinerSearchModule
  def initialize(cfile_path="./db.csv", ipath="./indexes")
    @csv_filepath = cfile_path
    @index_path = ipath
  end
end
