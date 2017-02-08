$data[:width] = 800
$data[:height] = 800
t = $data[:turtle] = Turtle.new

colors = [[255, 0, 0], [255, 0, 255], [0, 0, 255], [0, 255, 0], [255, 255, 0], [255, 165, 0]]

1.upto(360) do |i|
  t.color(*colors[i % 6])
  t.width(i / 180.0 + 0.1)
  t.forward(i)
  t.left(59.7)
end
