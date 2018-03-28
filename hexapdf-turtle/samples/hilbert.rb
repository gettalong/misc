$data[:width] = 400
$data[:height] = 400
t = $data[:turtle] = Turtle.new

# Hilbet.right curve
def hilbert(t, s, n, k)
   return if n < 1
   t.left k * 90
   hilbert(t, s, n - 1, -k)
   t.forward s
   t.right k * 90
   hilbert(t, s, n - 1, k)
   t.forward s
   hilbert(t, s, n - 1, k)
   t.right k * 90
   t.forward s
   hilbert(t, s, n - 1, -k)
   t.left k * 90
end
t.pen(:up)
t.back 185; t.right 90; t.forward 185; t.left 90
t.pen(:down)
hilbert(t, 12, 5, 1)
