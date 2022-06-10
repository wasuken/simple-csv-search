require "fileutils"
require_relative "../lib/v2_index_search.rb"

N = 2
v2 = V2Search.new
# パーティション作成
unless File.exist?("#{__dir__}/../indexes/db.csv.0")
  puts "run si"
  v2.partition 2000
  v2.index "title"
end

RSpec.describe "CSV検索V2 unit test" do
  let!(:v2_unit) { V2Search.new("./test_dir/db.csv", "./test_dir/indexes") }
  before do
    fp = "./test_dir/indexes"
    FileUtils.mkdir_p(fp)
    FileUtils.copy("./db.csv", "./test_dir/db.csv")
  end
  context "partition test" do
    # TODO: indexiesのしたに作らずに、別ディレクトリに作成するように修正する
    #       ある程度テストを書いてから修正する。
    it "file naming" do
      v2_unit.partition 2000
      # CSVファイルから指定した数にそってファイルを分割
      # 連番で作成
      rst = Dir.glob("./test_dir/indexes/*.csv.*").map { |fp| File.basename(fp) }
      expect(rst).to contain_exactly("db.csv.0", "db.csv.1", "db.csv.2", "db.csv.3", "db.csv.4", "db.csv.5")
    end
    it "file line size" do
    end
  end
  context "indexing test" do
    puts "test未実装"
  end
  context "index parse test" do
    puts "test未実装"
  end
  context "search test" do
    puts "test未実装"
  end
end

RSpec.describe "CSV検索V2 検索機能、速度テスト" do
  let!(:test_case_pairs) {
    [
      ["title", "ジョジョ"],
      ["title", "鬼滅の刃"],
      ["title", "コナン"],
      ["title", "金田一"],
      ["title", "とある"],
    ]
  }
  let!(:v2) { V2Search.new }
  context "検証データテスト" do
    it "テストデータ[test_case_pairs]" do
      (test_case_pairs * N).each do |x|
        name, title = x
        rst = v2.search name, title

        ftitle = ""
        ftitle = rst[0]["title"] if rst[0]
        puts "	first item title: #{ftitle}"
        puts "	items: #{rst.size}"
        expect(rst.is_a? Array).to be_truthy
      end
    end
  end
end
