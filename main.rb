require "benchmark"

require './lib/liner_search.rb'
require './lib/simple_index_search.rb'

n = 100

ls = LSearch.new
sis = SISearch.new
# name, query
Benchmark.bm do |x|

end
rst = ls.search ARGV[0], ARGV[1]

rst[0,10].each do |x|
  p rst
end

rst = sis.search ARGV[0], ARGV[1]
rst[0,10].each do |x|
  p rst
end
