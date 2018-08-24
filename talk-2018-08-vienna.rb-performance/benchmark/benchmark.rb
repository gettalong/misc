require 'benchmark'

Benchmark.bmbm do |x|
  a = 5
  b = 10
  count = 10_000_000
  x.report("a < b") { count.times { a < b ? b : a } }
  x.report("[a, b].max") { count.times { [a, b].max } }
end
