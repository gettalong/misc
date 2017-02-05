$data[:width] = 125
$data[:height] = 125
t = $data[:turtle] = Turtle.new

t.pen(:up).move(50).right(90).move(50).left(90).pen(:down)
t.color(255, 0, 0)

# Lower Right Triangle
t.left(90)
t.forward(100)
t.left(135)
t.forward(141.421)
t.left(135)
t.forward(100)

# Middle Triangle
t.left(110)
t.forward(110)
t.push.right(115).forward(38).pop   # upper connection
t.left(115)
t.forward(46.5)
t.push.left(41).forward(44).pop # middle left connection
t.push.left(139).forward(44).pop # middle right connection
t.forward(46.5)
t.push.left(50).forward(38).pop # lower connection
t.left(115)
t.forward(110)
