$data[:width] = 400
$data[:height] = 400
t = $data[:turtle] = Turtle.new

# Koch snowflacke
def koch(t, s, n)
   if n < 1
      t.forward s
      return
   end
   koch(t, s / 3, n - 1)
   t.left 60
   koch(t, s / 3, n - 1)
   t.right 120
   koch(t, s / 3, n - 1)
   t.left 60
   koch(t, s / 3, n - 1)
end
def snowflake(t, s, n)
   3.times { koch(t, s, n); t.right 120 }
end
t.pen(:up)
t.back 165; t.left 90; t.forward 95; t.right 90
t.pen(:down)
snowflake(t, 350, 4)
