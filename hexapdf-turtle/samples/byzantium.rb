$data[:width] = 400
$data[:height] = 400
t = $data[:turtle] = Turtle.new

# This is called BYZANTIUM because the fiqure it draws reminds me of one
# those jeweled crosses from medieval Byzantium.
def byzantium(t, r, n)
   return if n < 1
   t.forward(r);
   t.right(135)
   4.times {
     t.pen(:down)
     t.forward(2 * r * Math.sin(45 * Math::PI / 180))
     t.pen(:up)
     byzantium(t, r / 2, n - 1)
     t.right(90)
   }
   t.left(135)
   t.back(r)
end
byzantium(t, 100, 4)
