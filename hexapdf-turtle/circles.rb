$data[:width] = 500
$data[:height] = 500
$data[:fps] = 50
$data[:moves_per_frame] = 45
t = $data[:turtle] = Turtle.new

r = 225
check = 0

while r >= 10
  t.push

  # Move to start position r steps on the x-axis
  t.pen(:up)
  t.move(r)
  t.left(90)
  t.pen(:down)

  dist = 2 * Math::PI * r / 360

  # Draw circle one degree at a time
  360.times do |n|
    if (n / 5) % 2 == check
      t.pen(:down)
    else
      t.pen(:up)
    end

    t.move(dist)
    t.left(1)
  end

  r -= 10
  check = 1 - check

  t.pop
end
