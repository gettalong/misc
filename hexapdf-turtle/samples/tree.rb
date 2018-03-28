$data[:width] = 400
$data[:height] = 400
t = $data[:turtle] = Turtle.new

# Draw a tree. Adapted from Chapter 10 of "Computer Science Logo Style",
# Chapter 10.
def tree(t, _size)
   if _size < 10
     t.forward _size; t.back _size; return
   end
   t.color(139, 69, 19)
   t.forward _size / 3
   t.color(*[[0,128,0], [0,100,0], [85,107,47]].sample)
   t.left 30; tree t, _size * 2 / 3; t.right 30
   t.forward _size / 6
   t.right 25; tree t, _size / 2; t.left 25
   t.forward _size / 3
   t.right 25; tree t,_size / 2; t.left 25
   t.forward _size / 6
   t.back _size
end
t.back 180
t.pen(:down)
tree(t, 240.0)
