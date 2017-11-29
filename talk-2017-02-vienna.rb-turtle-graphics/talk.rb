# -*- coding: utf-8 -*-

# This string points to the directory with turtle graphics implementation
TURTLE_DIR="../hexapdf-turtle"

require 'hexapdf'
require 'hexapdf/utils/graphics_helpers'
require_relative File.join(TURTLE_DIR, 'turtle')

include HexaPDF::Utils::GraphicsHelpers

$slides = 0

def slide_info
  $slides += 1
  puts "Slide #{$slides} done"
end

def center_text(canvas, text, font: "normal", variant: :bold, size: 100, vpos: nil)
  box = canvas.context.box(:media)
  canvas.font(font, size: size, variant: variant)
  text = canvas.font.decode_utf8(text)
  text_width = text.inject(0) {|sum, char| sum + char.width * canvas.graphics_state.scaled_font_size}

  vpos ||= box.height / 2
  canvas.move_text_cursor(offset: [(box.width - text_width) / 2, vpos])
  canvas.show_glyphs(text)
end

def image_with_text(canvas, text, image, credits, height: nil)
  box = canvas.context.box(:media)
  image = canvas.context.document.images.add(image)

  height ||= box.height * 0.6
  width, height = calculate_dimensions(image[:Width], image[:Height], rheight: height)
  canvas.image(image, at: [(box.width - width) / 2, (box.height - height) * 0.4], height: height)
  center_text(canvas, credits, variant: :none, size: 20, vpos: box.height * 0.1 - 20)
  center_text(canvas, text, vpos: box.height * 0.85)
end

def turtle_graphics(doc, t, scale: 1, animation: true, fps: nil)
  width = doc.config['page.default_media_box'].width
  height = doc.config['page.default_media_box'].height
  t.configure(scale: scale)
  pdf = if animation
          t.create_pdf_animation(width, height, turtle_size: 100, fps: fps, turns_as_frames: true)
        else
          t.create_pdf(width, height)
        end
  pdf.pages[-1].delete(:Dur)
  pdf.pages.each do |page|
    doc.pages << doc.import(page)
    slide_info
  end
end


doc = HexaPDF::Document.new
box = HexaPDF::Rectangle.new([0, 0, 1920, 1080])
doc.config['page.default_media_box'] = box
doc.config['font.map'] = {
  'normal' => {
    none: '/home/thomas/.fonts/SourceSansPro-Regular.ttf',
    bold: '/home/thomas/.fonts/SourceSansPro-Bold.ttf'
  },
  'code' => {
    none: '/home/thomas/.fonts/SourceCodePro-Regular.ttf'
  }
}

center_text(doc.pages.add.canvas, "Something Else About Turtles")
slide_info

center_text(doc.pages.add.canvas, "This talk has something to do with turtles")
slide_info


image_with_text(doc.pages.add.canvas, "But not with these turtles", "tmnt.png",
               "http://www.cartoon-clipart.co/teenage-mutant-ninja-turtles.html")
slide_info

image_with_text(doc.pages.add.canvas, "... or these", "nemo-meme.jpg",
               "https://www.bustle.com/articles/166547-crush-is-in-finding-dory-the-turtles-appearance-is-totally-sick")
slide_info

image_with_text(doc.pages.add.canvas, "... or this one", "dw-turtle.jpg",
               "http://meganchristopher.net/crafters-anonymous-the-turtle-moves/")
slide_info

image_with_text(doc.pages.add.canvas, "... but with this little fella here", File.join(TURTLE_DIR, 'turtle.png'),
               "https://clipartfest.com/download/efc669db8a84e2659da2630b3df89d0dc7e45701.html", height: 200)
slide_info

canvas = doc.pages.add.canvas
center_text(canvas, "Turtle Graphics", vpos: box.height * 0.85)
center_text(canvas, "A turtle moves around and draws something", variant: :none, size: 80)
slide_info

canvas = doc.pages.add.canvas
center_text(canvas, "First you need a turtle", vpos: box.height * 0.85)
center_text(canvas, "turtle = Turtle.new", variant: :none, font: "code", size: 80)
slide_info

turtle_graphics(doc, Turtle.new)

canvas = doc.pages.add.canvas
center_text(canvas, "Move forward or backward", vpos: box.height * 0.85)
center_text(canvas, "turtle.forward(steps)", variant: :none, font: "code", size: 80)
center_text(canvas, "turtle.back(steps)", variant: :none, font: "code", size: 80, vpos: box.height / 2 - 80)
slide_info

t = Turtle.new
t.forward(500)
t.back(1000)
t.forward(500)
turtle_graphics(doc, t, fps: 2)

canvas = doc.pages.add.canvas
center_text(canvas, "Turn left or right", vpos: box.height * 0.85)
center_text(canvas, "turtle.left(degrees)", variant: :none, font: "code", size: 80)
center_text(canvas, "turtle.right(degrees)", variant: :none, font: "code", size: 80, vpos: box.height / 2 - 80)
slide_info

t = Turtle.new
t.forward(300).left(90).forward(300).left(135).forward(424.264)
t.right(45)
t.forward(300).right(90).forward(300).right(135).forward(424.264)
turtle_graphics(doc, t, fps: 2)

canvas = doc.pages.add.canvas
center_text(canvas, "Move with or without drawing", vpos: box.height * 0.85)
center_text(canvas, "turtle.pen(:up)", variant: :none, font: "code", size: 80)
center_text(canvas, "turtle.pen(:down)", variant: :none, font: "code", size: 80, vpos: box.height / 2 - 80)
slide_info

t = Turtle.new
t.pen(:up).back(300)
3.times { t.pen(:down).forward(100).pen(:up).forward(100) }
turtle_graphics(doc, t, fps: 2)

center_text(doc.pages.add.canvas, "That's the basics")
slide_info

canvas = doc.pages.add.canvas
center_text(canvas, "Why?", vpos: box.height * 0.85)
center_text(canvas, "Jamis Buck's Weekly Challenge", variant: :none, size: 80)
center_text(canvas, "http://weblog.jamisbuck.org/2016/11/5/weekly-programming-challenge-15.html",
            variant: :none, size: 40, vpos: box.height / 2 - 80)
slide_info

canvas = doc.pages.add.canvas
center_text(canvas, "Challenge: Implement Turtle Graphics", vpos: box.height * 0.85)
center_text(canvas, "Normal mode: move, turn, pen", variant: :none, size: 60)
center_text(canvas, "Hard mode: color, line style, width, push/pop, define/draw primitive, scale",
            variant: :none, size: 60, vpos: box.height / 2 - 120)
slide_info

image_with_text(doc.pages.add.canvas, "Hmm... which backend should I choose?", "thinking.jpg",
               "https://clipartfest.com/download/25874d2877d3f9c7a81babd4d2ba3111950663dc.html")
slide_info

center_text(doc.pages.add.canvas, "HexaPDF :-)")
slide_info

canvas = doc.pages.add.canvas
center_text(canvas, "Features", vpos: box.height * 0.85)
canvas.font("normal", size: 60)
canvas.text(<<EOF, at: [400, 600])
•    Vector graphics instead of bitmap
•    Reusable by implementing it as graphic object
•    Animation by (ab)using presentation mode
EOF
slide_info

canvas = doc.pages.add.canvas
center_text(canvas, "Problems With PDF Animation", vpos: box.height * 0.85)
canvas.font("normal", size: 60)
canvas.text(<<EOF, at: [100, 600])
•    Straight-forward implementation grows file size in O(n^2/2) manner
•    Alternative XObject nesting: only ~30 nesting levels possible
•    Alternative sub-page navigation with OCG: not widely supported
•    Alternative widget animation with Javascript: not widely supported

•    Solution: Multiple content streams
EOF
slide_info

center_text(doc.pages.add.canvas, "Show me the code!")
slide_info

canvas = doc.pages.add.canvas
center_text(canvas, "Uses of Turtle Graphics", vpos: box.height * 0.85)
center_text(canvas, "Teaching the Logo programming language", variant: :none, size: 80)
center_text(canvas, "Visualizing Lindenmayer systems", variant: :none, size: 80,
            vpos: box.height / 2 - 120)
center_text(canvas, "Just for playing around", variant: :none, size: 80,
            vpos: box.height / 2 - 240)
slide_info

center_text(doc.pages.add.canvas, "Examples")
slide_info

$data = {}
load(File.join(TURTLE_DIR, "spiral.rb"))
turtle_graphics(doc, $data[:turtle], scale: 5, animation: false)
load(File.join(TURTLE_DIR, "boxes.rb"))
turtle_graphics(doc, $data[:turtle], scale: 5, animation: false)
load(File.join(TURTLE_DIR, "circles.rb"))
turtle_graphics(doc, $data[:turtle], scale: 2, animation: false)
load(File.join(TURTLE_DIR, "tree.rb"))
turtle_graphics(doc, $data[:turtle], scale: 1.5, animation: false)
load(File.join(TURTLE_DIR, "ruby.rb"))
turtle_graphics(doc, $data[:turtle], scale: 8, animation: true, fps: 2)

canvas = doc.pages.add.canvas
center_text(canvas, "Thanks!", vpos: box.height * 2 / 3)
center_text(canvas, "This talk was built with Ruby and HexaPDF :-)",
            variant: :none, size: 60, vpos: box.height * 2 / 3 - 200)
center_text(canvas, "https://hexapdf.gettalong.org",
            variant: :none, size: 60, vpos: box.height * 2 / 3 - 350)
center_text(canvas, "Support HexaPDF - https://patreon.com/gettalong",
            variant: :none, size: 60, vpos: box.height * 2 / 3 - 500)
slide_info

doc.write('talk.pdf')
