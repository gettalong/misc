require 'benchmark-driver'

Benchmark.driver do |x|
  x.prelude %{
    a = 5
    b = 10
  }
  x.report("a < b", %{ a < b ? b : a })
  x.report("[a, b].max", %{ [a, b].max })
end
