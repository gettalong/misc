$data[:width] = 1000
$data[:height] = 600
t = $data[:turtle] = Turtle.new

def draw(t, l)
  return if l <= 10
  t.move(l)
  t.right(30)
  draw(t, l - 10)
  t.left(60)
  draw(t, l - 10)
  t.right(30)
  t.back(l)
end

t.pen(:up)
t.left(90)
t.back(250)
t.pen(:down)

draw(t, 100)
