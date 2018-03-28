# A complete graph on the vertexes of a regular polygon.
def polygon(r, n)
   poly = []
   theta = 360. * DEG / n
   n.times do |k|
      angle = k * theta 
      poly << [r * sin(angle), r * cos(angle)]
   end
   poly
end
def ray(from, to)
   pd; go to; pu; go from
end
def fan(pt, others)
   others.each { |to| ray pt, to }
end
def mandala(r, n)
   poly = polygon(r, n)
   until poly.empty?
      v = poly.shift
      go v
      fan v, poly
   end
end
mandala(180, 24)
