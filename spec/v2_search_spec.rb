require_relative "../lib/v2_index_search.rb"

N = 2
v2 = V2Search.new
# パーティション作成
unless File.exist?("#{__dir__}/../indexes/db.csv.0")
  puts "run si"
  v2.partition 2000
  v2.index "title"
end

RSpec.describe "CSV検索V2" do
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
  context "サンプル検証" do
    it "テストデータ検証" do
      (test_case_pairs * N).each do |x|
        name, title = x
        rst = v2.search name, title
        expect(rst.is_a? Array).to be_truthy
        ftitle = ""
        ftitle = rst[0]["title"] if rst[0]
        puts "	first item title: #{ftitle}"
        puts "	items: #{rst.size}"
      end
    end
  end
end
