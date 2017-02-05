STEP_SIZE=5

$data[:width] = 250
$data[:height] = 250
t = $data[:turtle] = Turtle.new

r = 100
count = (r / STEP_SIZE) * 6
intensity = 255.0
inc = intensity / count

# Move to starting position at the bottom
t.pen(:up)
t.right(90)
t.move(r)
t.left(120)

t.pen(:down)
while r >= STEP_SIZE
  # One round of the hexagonal spiral
  6.times do |n|
    t.color(intensity.round, intensity.round, intensity.round)

    t.move(r + (n == 0 ? STEP_SIZE : (n == 5 ? -STEP_SIZE : 0)))
    t.left(60)

    intensity -= inc
  end

  r -= STEP_SIZE
end
