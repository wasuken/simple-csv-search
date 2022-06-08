require_relative "../lib/liner_search"
require_relative "../lib/simple_index_search"
require_relative "../lib/file_index_search"

N = 2

# インデックス作成
unless File.exist?("#{__dir__}/../indexes/title.json")
  puts "run si"
  SimpleIndexSearch.new.index "title"
end
if Dir.glob("#{__dir__}/../fs_indexes/*.index").size <= 0
  puts "run fi"

  FileIndexSearch.new("./db.csv", "./fs_indexes").index "title"
end


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
  let!(:ls) { LinerSearch.new }
  let!(:sis) { SimpleIndexSearch.new }
  let!(:fis) { FileIndexSearch.new("./db.csv", "./fs_indexes") }
  context "サンプルによる検索" do
    it "LinerSearch" do
      (test_case_pairs * N).each do |p|
        title, q = p
        rst = ls.search title, q
        ftitle = ""
        ftitle = rst[0]["title"] if rst[0]
        puts "	first item title: #{ftitle}"
        puts "	items: #{rst.size}"
        expect(rst.is_a? Array).to be_truthy
      end
    end
    it "SimpleIndexSearch" do
      title_index_json = JSON.parse(File.read("./indexes/title.json"))
      (test_case_pairs * N).each do |p|
        title, q = p
        rst = sis.index_search title, q, title_index_json
        ftitle = ""
        ftitle = rst[0]["title"] if rst[0]
        puts "	first item title: #{ftitle}"
        puts "	items: #{rst.size}"
        expect(rst.is_a? Array).to be_truthy
      end
    end
    it "FileIndexSearch" do
      (test_case_pairs * N).each do |p|
        title, q = p
        rst = fis.index_search title, q

        ftitle = ""
        if rst.size > 0
          fitem = rst[0]
          ftitle = fitem.split(',')[4]
        end

        puts "	first item title: #{ftitle}"
        puts "	items: #{rst.size}"
        expect(rst.is_a? Array).to be_truthy
      end
    end
  end
end
