# -*- encoding: utf-8 -*-

require 'hexapdf'

# Implements a turtle graphics system for HexaPDF as a graphic object.
#
# To use it, get a turtle graphic object via HexaPDF::Content::Canvas#graphic_object(:turtle), then
# play with the turtle and finally draw it.
#
# Or just use the #save method when you are done!
class Turtle

  # Represents a single turtle instruction.
  Instruction = Struct.new(:operation, :arg)

  # Represents the state of the turtle.
  State = Struct.new(:x, :y, :heading, :color, :pen_down)

  # Returns an initialized turtle graphic object.
  #
  # See #configure for information on possible arguments.
  def self.configure(**kwargs)
    new.configure(**kwargs)
  end

  def initialize # :nodoc:
    @instructions = []
    @x = 0
    @y = 0
    @scale = 1
  end

  # Returns a HexaPDF::Document object with a single page on which the turtle graphics are drawn.
  def create_pdf(width, height)
    doc = HexaPDF::Document.new
    page = doc.pages.add
    page[:MediaBox] = [0, 0, width, height]
    page.canvas.draw(self, x: width / 2.0, y: height / 2.0)
    doc
  end

  # Returns a HexaPDF::Document object with a page for each frame of the turtle graphics.
  #
  # When viewing this PDF in presentation mode, the pages are automatically switched after viewing
  # the second page.
  def create_pdf_animation(width, height, moves_per_frame: 1, fps: 25, turtle_size: 20, turns_as_frames: false)
    configure(x: width / 2.0, y: height / 2.0)

    doc = HexaPDF::Document.new(config: {"page.default_media_box" => nil})
    doc.pages.root[:MediaBox] = [0, 0, width, height]
    image = doc.images.add(File.join(__dir__, 'turtle.png'))

    page = doc.pages.add
    page.canvas.image(image, at: [@x - turtle_size / 2, @y - turtle_size / 2], width: turtle_size)

    form = doc.wrap(Type: :XObject, Subtype: :Form)
    canvas = HexaPDF::Content::Canvas.new(form)
    frame_states = draw(canvas, mark_frames: true, turns_as_frames: turns_as_frames)
    frames = HexaPDF::Filter.string_from_source(canvas.stream_data.fiber).split(/\/Turtle MP\n/)

    streams = []
    duration = (fps ? 1.0 / fps : nil)
    data = ""

    index = 0
    while index < frame_states.length
      page = doc.pages.add
      page[:Dur] = duration if duration

      moves_per_frame.times do
        data << frames[index]
        index += 1
        if index % 10 == 0
          streams << doc.add({Filter: :FlateDecode}, stream: data)
          data = ""
        end
        break if index >= frame_states.length
      end

      canvas = HexaPDF::Content::Canvas.new(page)
      origin = [frame_states[index - 1][0], frame_states[index - 1][1]]
      canvas.rotate(frame_states[index - 1][2] * 180 / Math::PI, origin: origin) do
        canvas.image(image, at: [origin[0] - turtle_size / 2, origin[1] - turtle_size / 2], width: turtle_size)
      end
      page_data = data + "\nS\n" + HexaPDF::Filter.string_from_source(canvas.stream_data.fiber)

      page[:Contents] = streams.dup + [doc.add({Filter: :FlateDecode}, stream: page_data)]
    end

    doc
  end

  # Configures the turtle graphics and returns self.
  #
  # x:: The x-coordinate of the starting point.
  # y:: The y-coordinate of the starting point.
  # scale:: Scale the drawing according to the given scale.
  def configure(x: nil, y: nil, scale: nil)
    @x = x if x
    @y = y if y
    @scale = scale if scale
    self
  end

  # Draws the turtle graphic on the canvas.
  #
  # The option +mark_frames+ should only be used when the content stream is post-processed because
  # the inserted marks are not PDF conform (though most readers will ignore them).
  def draw(canvas, mark_frames: false, turns_as_frames: false)
    x = @x
    y = @y
    heading = 0
    pen_down = true
    color = 0

    stack = []
    frame_states = []

    mark_frame = lambda do
      return unless mark_frames
      canvas.contents << "/Turtle MP\n"
      frame_states << [x, y, heading]
    end

    canvas.stroke_color(color)
    canvas.line_width(@scale)
    canvas.move_to(x, y)

    @instructions.each do |instruction|
      case instruction.operation
      when :move
        x += Math.cos(heading) * instruction.arg * @scale
        y += Math.sin(heading) * instruction.arg * @scale
        if pen_down
          canvas.line_to(x, y)
        else
          canvas.move_to(x, y)
        end
        mark_frame.call

      when :turn
        heading += Math::PI / 180.0 * instruction.arg
        mark_frame.call if turns_as_frames

      when :pen_down
        pen_down = instruction.arg

      when :color
        color = instruction.arg
        canvas.stroke
        canvas.stroke_color(color)
        canvas.move_to(x, y)

      when :push
        stack << State.new(x, y, heading, color, pen_down)

      when :pop
        if stack.empty?
          raise ArgumentError, "No more pushed state available"
        end
        x, y, heading, color, pen_down = *stack.pop
        canvas.stroke
        canvas.stroke_color(color)
        canvas.move_to(x, y)

      else
        raise ArgumentError, "Unsupported turtle graphics operation"
      end
    end

    canvas.stroke

    frame_states
  end

  # Moves the turtle the given number of steps, forward if steps is positive and backwards
  # otherwise.
  def move(steps)
    @instructions << Instruction.new(:move, steps)
    self
  end

  # Moves the turtle forward by the given number of steps.
  def forward(steps)
    move(steps)
  end

  # Moves the turtle backwards by the given number of steps.
  def back(steps)
    move(-steps)
  end

  # Rotate the turtle by the number of degrees, counterclockwise if degrees is positive and
  # clockwise otherwise.
  def turn(degrees)
    @instructions << Instruction.new(:turn, degrees)
    self
  end

  # Rotates the turtle by the number of degrees towards right.
  def right(degrees)
    turn(-degrees)
  end

  # Rotates the turtle by the number of degrees towards left.
  def left(degrees)
    turn(degrees)
  end

  # Defines whether the turtle should draw while moving. Can either be :up or :down.
  def pen(up_or_down)
    @instructions << Instruction.new(:pen_down, up_or_down == :down)
    self
  end

  # Defines the color that should be used for subsequent drawing operations. Can be any valid
  # argument for HexaPDF::Content::Canvas#stroke_color
  def color(*args)
    @instructions << Instruction.new(:color, args)
    self
  end

  # Saves the current state (position, heading, pen status, color) of the turtle.
  def push
    @instructions << Instruction.new(:push)
    self
  end

  # Restores the state of the turtle to the last pushed state.
  def pop
    @instructions << Instruction.new(:pop)
    self
  end

end


HexaPDF::DefaultDocumentConfiguration['graphic_object.map'][:turtle] = 'Turtle'
