require 'benchmark/ips'

Benchmark.ips do |x|
  a = 5
  b = 10
  x.report("a < b") { a < b ? b : a }
  x.report("[a, b].max") { [a, b].max }
  x.report("a < b (2)", %{a = 5; b = 10; a < b ? b : a })
  x.report("[a, b].max (2)", %{a = 5; b = 10; [a, b].max })
  x.compare!
end
