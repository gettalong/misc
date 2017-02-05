$data[:width] = 250
$data[:height] = 250
t = $data[:turtle] = Turtle.new

30.times do |n|
  i = 128 + 128 * n / 30
  t.color(i, i, i)

  t.pen(:up)
  t.move(10)
  t.pen(:down)

  4.times do
    t.move(50)
    t.right(90)
  end

  t.pen(:up)
  t.move(-10)
  t.pen(:down)

  t.right(12)
end
