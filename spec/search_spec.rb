require_relative "../lib/liner_search"
require_relative "../lib/simple_index_search"
require_relative "../lib/file_index_search"

class LSearch
  include LinerSearch

  def index_path
    "./indexes"
  end

  def csv_filepath
    "./db.csv"
  end
end

class SISearch
  include SimpleIndexSearch

  def index_path
    "./indexes"
  end

  def csv_filepath
    "./db.csv"
  end
end

class FISearch
  include FileIndexSearch

  def index_path
    "./findexes"
  end

  def csv_filepath
    "./db.csv"
  end
end

N = 2

RSpec.describe "CSV検索" do
  let!(:test_case_pairs) {
    [
      ["title", "ジョジョ"],
      ["title", "鬼滅の刃"],
      ["title", "コナン"],
      ["title", "金田一"],
      ["title", "とある"],
    ]
  }
  let!(:ls) { LSearch.new }
  let!(:sis) { SISearch.new }
  let!(:fis) { FISearch.new }
  context "サンプルによる検索" do
    it "LSearch" do
      (test_case_pairs * N).each do |p|
        title, q = p
        rst = ls.search title, q
        expect(rst.is_a? Array).to be_truthy
      end
    end
    it "SISearch" do
      sis.index "title"
      title_index_json = JSON.parse(File.read("./indexes/title.json"))
      (test_case_pairs * N).each do |p|
        title, q = p
        rst = sis.index_search title, q, title_index_json
        expect(rst.is_a? Array).to be_truthy
      end
    end
    it "FISearch" do
      fis.index "title"
      (test_case_pairs * N).each do |p|
        title, q = p
        rst = fis.index_search title, q
        expect(rst.is_a? Array).to be_truthy
      end
    end
  end
end
