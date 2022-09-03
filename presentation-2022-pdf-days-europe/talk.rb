require 'hexapdf'
require 'rdoc'
require 'stringio'

class SlideComposer < HexaPDF::Composer

  def initialize
    #super(page_size: [0, 0, 812.438, 457.002])
    super(page_size: [0, 0, 1152, 648], margin: 0)
    set_up_styles
  end

  def new_page(*, **)
    if document.pages.count == 0
      super(margin: 0)
    else
      super(margin: [54, 53, 89, 53])
      canvas.fill_color(@color_grey).rectangle(0, 69, page.box.width, page.box.height - 69).fill
      canvas.fill_color("black").rectangle(113, 527, 844, 67).fill.
        fill_color("white").rectangle(956, 527, 143, 67).fill.
        fill_color(@color_red).rectangle(53, 527, 68, 67).fill.
        save_graphics_state do
          canvas.rectangle(994, 527, 67, 67).clip_path.end_path.
            image('pdf-days-europe.jpg', at: [990, 524], height: 74)
        end
      canvas.fill_color("black").font("SourceSansPro", size: 12).
        image('pdf-association-logo.pdf', at: [45, 5], height: 60)
      canvas.text("Copyright © 2022, PDF Association", at: [490, 32]).
        text(document.pages.count.to_s, at: [1080, 32])
    end
  end

  def title_slide(text, subtext)
    canvas.fill_color("e7e7e7").rectangle(0, 0, page.box.width, page.box.height).fill
    image('title.png', width: 1152, height: 356.5, position: :absolute,
          position_hint: [0, 291.5])
    image('pdf-days-europe.jpg', width: 291.5, height: 291.5, position: :absolute,
          position_hint: [0, 0])

    # Simulate margins left and right of the pdf days logo
    box(:base, width: 40, style: {position_hint: :right, position: :float})
    box(:base, width: 40, style: {position_hint: :left, position: :float})

    # Title
    formatted_text([text], height: 146, padding: [0, 0, 40],
                   align: :center, valign: :bottom,
                   font: ['SourceSansPro', variant: :bold],
                   font_size: 45, line_spacing: {type: 1.2},
                   fill_color: [0, 0, 0])
    # Subtitle
    if subtext
      text(subtext, box_style: {background_color: @color_red, padding: [10, 40],
                                align: :center, line_spacing: {type: 1.5}},
           font_size: 25.6,
           fill_color: "white")
    end
  end

  def bullet_slide(title, bullets)
    new_page
    slide_title(title)
    box(:list, item_type: list_item_bullet(1), content_indentation: 53, item_spacing: 10, style: :list1) do |box|
      bullets.each do |bullet|
        box.formatted_text(Array(bullet), style: :list1)
      end
    end
  end

  def image_slide(title, image, desc = nil)
    new_page
    slide_title(title)
    self.image(image, position_hint: :center, valign: :center, background_color: 'white',
               border: {width: 1})
  end

  def code_slide(title, code, highlight: true, size: 0)
    new_page
    slide_title(title)
    font_size = style(:codeblock).font_size + size
    if highlight
      tokens = RDoc::Parser::RipperStateLex.parse(code.gsub(/^ /, "\u{00A0}"))
      formatted_text(to_formatted_text(tokens), style: :codeblock, font_size: font_size)
    else
      text(code, style: :codeblock, font_size: font_size)
    end
  end

  def slide_title(title)
    text(title, height: 67, font: ['SourceSansPro', variant: :bold], font_size: 63,
         valign: :bottom, fill_color: 'white', padding: [0, 143, 0, 77], margin: [0, 0, 47])
  end

  private

  def set_up_styles
    @color_red = [208, 63, 78]
    @color_green = [139, 152, 91]
    @color_yellow = [202, 152, 49]
    @color_blue = [72, 145, 175]
    @color_grey = [236, 237, 238]
    document.config['font.map']['SourceSansPro'] = {
      none: 'SourceSansPro-Regular.ttf',
      bold: 'SourceSansPro-Semibold.ttf',
    }
    document.config['font.map']['SourceCodePro'] = {
      none: 'SourceCodePro-Semibold.ttf',
    }
    style(:base, font: 'SourceSansPro', fill_color: 0, font_size: 34)
    style(:code, font: 'SourceCodePro')
    style(:codeblock, font: 'SourceCodePro',
                      background_color: "black",
                      fill_color: "white",
                      position_hint: :center,
                      padding: 9,
                      font_size: 18,
                      line_spacing: {type: 1.2})
    style(:list1, font_size: 34,
                  line_spacing: {type: 1.2})
    style(:list2, font_size: 28,
                  line_spacing: {type: 1.2})
    style(:list3, font_size: 18,
                  line_spacing: {type: 1.2})
    style(:list4, font_size: 15,
                  line_spacing: {type: 1.2})
  end

  def list_item_bullet(level)
    lambda do |document, box, index|
      color, font_size = case level
                         when 1 then [@color_red, 22]
                         when 2 then [@color_green, 18]
                         when 3 then [@color_yellow, 12]
                         when 4 then [@color_blue, 10]
                         end
      fragment = HexaPDF::Layout::TextFragment.create("■", font: document.fonts.add("SourceSansPro"),
                                                      font_size: font_size, fill_color: color,
                                                      line_height: style(:"list#{level}").font_size)
      HexaPDF::Layout::TextBox.new(items: [fragment],
                                   style: {align: :right, padding: [0, 12, 0, 0]})
    end
  end

  def to_formatted_text(token_stream)
    token_stream.map do |t|
      next unless t

      color = case t[:kind]
              when :on_const
                '7fffd4'
              when :on_kw
                '00ffff'
              when :on_ivar
                'eedd82'
              when :on_cvar, :on_gvar, :on_ident, :on_heredoc_beg, :on_heredoc_end
                'ffdead'
              when '=' != t[:text] && :on_op, :on_tlambda
                '00ffee'
              when :on_backref, :on_dstring
                'ffa07a'
              when :on_comment, :on_embdoc
                'dc6666'
              when :on_regexp
                'ffa07a'
              when :on_tstring
                'white'
              when :on_int, :on_float, :on_rational, :on_imaginary, :on_heredoc,
                   :on_symbol, :on_CHAR, :on_label
                '77ffd4'
              else
                'white'
              end

      {text: t[:text], fill_color: color}
    end.compact
  end

end

def parse_bullets(composer, text)
  text.scan(/^---.*?(?=---|\z)/m).each do |slide_text|
    title, *rest = slide_text.split("\n")
    title = title[4..-1]
    rest.reject! {|line| line.strip.empty?}
    rest.map! do |line|
      line[2..-1].split(/\*(.*?)\*/).map.with_index do |item, index|
        if index.even?
          item.split(/`(.*?)`/).map.with_index do |item, index|
            if index.even?
              item
            else
              {text: item, font: 'SourceCodePro', font_size: 28}
            end
          end
        else
          {text: item, font: ['SourceSansPro', variant: :bold]}
        end
      end.flatten
    end
    composer.bullet_slide(title, rest)
  end
end

composer = SlideComposer.new

composer.title_slide(
  "Implementing a PDF Library in Ruby",
  "Design and implementation decisions to create a fully-featured, fast and memory-efficient PDF library"
)

parse_bullets(composer, <<EOL)
--- Table of Contents

* Why Ruby?
* Why HexaPDF?
* Parsing
* Object Model
* Serializing
* Encryption
* Document Layout Engine
* Optimizations
* General Design

--- Why Ruby?

* Language of choice for side projects
* Fast development/feedback loop
* *No existing, feature-complete, pure Ruby PDF library*


--- Why HexaPDF?

* Scratching an itch (PDF generation library Prawn not good enough)
* Desire to implement a complex, publicly available specification
* Provide high-quality library and *dual-license AGPL+commercial to sustain development*
EOL

composer.code_slide('HexaPDF Code Example', <<EOL, size: 8)
require 'hexapdf'

doc = HexaPDF::Document.new
doc.trailer.info[:CreationDate] = Time.now
doc.trailer.info[:Title] = "My Hello World"
canvas = doc.pages.add.canvas
canvas.font('Helvetica', size: 100)
canvas.text("Hello World!", at: [20, 400])
doc.write("hello-world.pdf", optimize: true)
EOL

parse_bullets(composer, <<EOL)
--- Parsing

* Usual separation between tokenizer and parser
* Tokenizer also responsible for parsing whole PDF objects
* *StringScanner and regular expressions used for tokenization*, not byte-by-byte

EOL

composer.code_slide('Parsing - StringScanner Usage', <<EOL, size: 3)
# Parses the hex string at the current position.
#
# See: PDF1.7 s7.3.4.3
def parse_hex_string
  @ss.pos += 1                     # @ss is the StringScanner object
  data = scan_until(/(?=>)/)
  unless data
    raise HexaPDF::MalformedPDFError.new("Unclosed hex string found", pos: pos)
  end
  @ss.pos += 1
  data.tr!(WHITESPACE, "")
  [data].pack('H*')
end
EOL

parse_bullets(composer, <<EOL)
--- Parsing - Continued

* First iteration done like described in the specification, then added work-arounds for invalid PDFs
* Now capable of parsing a wide array of invalid PDFs

--- Object Model

* Many implementations create custom classes for PDF object types
* *HexaPDF uses built-in Ruby classes* where possible for performance, lower memory usage and ease of use
* *Nearly perfect mapping* between PDF object types and Ruby's built-in classes
EOL

composer.new_page
composer.slide_title('Object Model - Type Mapping')
composer.box(:base, width: 53, style: {position: :float})
[
  ['Boolean', 'true/false'],
  ['Numeric', 'Integer, Float'],
  ['String', 'String'],
  ['Name', 'Symbol'],
  ['Null', 'nil'],
  ['Array', 'Array, HexaPDF::PDFArray'],
  ['Dictionary', 'Hash, HexaPDF::Dictionary'],
  ['Indirect Objects', 'HexaPDF::Object'],
  ['Stream', 'HexaPDF::Stream'],
].each do |left, right|
  composer.text(left, width: 400, position: :float, padding: 3, border: {width: 1}, margin: [0, -1, -1, 0])
  composer.text(right, width: 400, padding: 3, border: {width: 1})
end

parse_bullets(composer, <<EOL)
--- Evolution of Object Model

* Use custom `HexaPDF::Dictionary` class in addition to the built-in Hash class for dictionaries
* Allows *automatic reference resolving* on access
* PDF types like the document catalog as subclasses with *field definitions*
EOL


composer.code_slide('PDF Type Implementation ', <<EOL, size: 1)
class Trailer < Dictionary

  define_type :XXTrailer

  define_field :Size,    type: Integer, indirect: false
  define_field :Prev,    type: Integer
  define_field :Root,    type: :Catalog, indirect: true
  define_field :Encrypt, type: Dictionary
  define_field :Info,    type: :XXInfo, indirect: true
  define_field :ID,      type: PDFArray
  define_field :XRefStm, type: Integer, version: '1.5'

end

HexaPDF::GlobalConfiguration['object.type_map'][:XXTrailer] = 'HexaPDF::Type::Trailer'
EOL

#* Also use custom Array class for arrays, for automatic reference resolving
parse_bullets(composer, <<EOL)
--- Dictionary Fields Usages

* Return *default values* for unset fields on access
* Field information is used for basic *object validation*
* *Automatic conversion* of values based on the field type (e.g. PDF dates but also specific type classes)

--- Memory Usage vs Ease-of-use

* Auto-converting dictionaries is a trade-off between lower memory usage and ease-of-use
* Core data (object number, generation number, value, stream) is put in `HexaPDF::PDFData` object
* Data object is wrapped by one or more `HexaPDF::Object` instances

--- Auto-converting Dictionaries

* Automatically convert loaded or added hashes/dictionaries to specific type classes
* Conversion is based on the `/Type` and `/Subtype` entries as well as the required fields
* Problem: False positives, e.g. artifact property list containing `<</Type /Page>>`

--- Serializing

* Any Ruby object can be serialized, serializer is extendable
* Compact serialization representation by default
EOL

composer.code_slide('Serializing Strings', <<'EOL')
STRING_ESCAPE_MAP = {"(" => "\\(", ")" => "\\)", "\\" => "\\\\", "\r" => "\\r"}.freeze

def serialize_string(obj)
  obj = if @encrypter && @object.kind_of?(HexaPDF::Object) && @object.indirect?
          encrypter.encrypt_string(obj, @object)
        elsif obj.encoding != Encoding::BINARY
          if obj.match?(/[^ -~\t\r\n]/)
            "\xFE\xFF".b << obj.encode(Encoding::UTF_16BE).force_encoding(Encoding::BINARY)
          else
            obj.b
          end
        else
          obj.dup
        end
  obj.gsub!(/[()\\\r]/n, STRING_ESCAPE_MAP)
  "(#{obj})"
end
EOL

parse_bullets(composer, <<EOL)
--- Encryption

* Done at a later stage, kind of "tucked" on but in a good way
* Loading encrypted objects is nearly orthogonal to parsing, only the object loader is amended
* Serialization class adapted to provide encryption
EOL

composer.code_slide('Decryption of Loaded Object', <<EOL, size: 8)
document.revisions.each do |r|
  loader = r.loader
  r.loader = lambda do |xref_entry|
    obj = loader.call(xref_entry)
    xref_entry.compressed? ? obj : handler.decrypt(obj)
  end
end
EOL

parse_bullets(composer, <<EOL)
--- Document Layout Engine

* PDF needs explicit glyph positions, conforming *writer does all the layout*
* HexaPDF's layout engine is written from scratch, based on the concept of *frames* and *boxes*
* Frames provide an area to place boxes and know where and how the next box can be placed
* The frame area, its shape, is usually rectangular but can generally be a set of rectilinear polygons
EOL

composer.image_slide('Document Layout - Frame', 'frames.pdf')

parse_bullets(composer, <<EOL)
--- Document Layout Cont.

* Boxes are responsible for three things: *fitting* their contents, *splitting* the box if necessary and *drawing* their contents
* A box may be fitted into a rectangular area or use the frame's shape to flow its contents
* The text layout engine can *flow text inside a set of arbitrary polygons*
EOL

composer.image_slide('Document Layout - Example', 'layout-example.pdf')

parse_bullets(composer, <<EOL)
--- Optimizations

* Stream filters implemented via *fiber pipeline* (allow processing streams in chunks, only apply necessary filters)
* *Optimize size of serialized output* (smaller files and faster operation due to less serialization)
* *Optimize text output* (use most compact representation possible)
EOL

composer.code_slide('Size Optimization Benchmark', <<EOL, highlight: false, size: -4)
|--------------------------------------------------------------------|
|                              ||    Time |     Memory |   File size |
|--------------------------------------------------------------------|
| hexapdf CS  | a.pdf          |    280ms |  40.852KiB |      49.154 |
| qpdf CS     | a.pdf          |     14ms |   8.288KiB |      49.287 |
|--------------------------------------------------------------------|
| hexapdf CS  | b.pdf          |    766ms |  59.172KiB |  11.045.146 |
| qpdf CS     | b.pdf          |    422ms |  22.568KiB |  11.124.779 |
|--------------------------------------------------------------------|
| hexapdf CS  | c.pdf          |  1.307ms |  63.652KiB |  13.180.380 |
| qpdf CS     | c.pdf          |  1.178ms |  95.596KiB |  13.228.102 |
|--------------------------------------------------------------------|
| hexapdf CS  | d.pdf          |  2.787ms |  92.552KiB |   6.418.439 |
| qpdf CS     | d.pdf          |  1.759ms |  69.308KiB |   6.703.374 |
|--------------------------------------------------------------------|
| hexapdf CS  | e.pdf          |    854ms | 104.944KiB |  21.751.197 |
| qpdf CS     | e.pdf          |    375ms |  31.456KiB |  21.787.558 |
|--------------------------------------------------------------------|
| hexapdf CS  | f.pdf          | 46.443ms | 593.312KiB | 117.545.254 |
| qpdf CS     | f.pdf          | 27.878ms | 975.288KiB | 118.114.521 |
|--------------------------------------------------------------------|
EOL

parse_bullets(composer, <<EOL)
--- General Design

* Make everything possible using a low-level interface
* Iteratively add classes for the PDF types (for automatic validation and value conversion)
* Add convenience methods for easier usage (e.g. manipulating the page tree)

--- General Design Cont.

* Provide convenience methods on the class where they are most useful
* If no class fits, create a new one and allow easy access via the main document object
* Make everything extendable and exchangable where possible and useful
EOL

composer.new_page
composer.text("Thank you!", font_size: 70, align: :center, valign: :center)
composer.write(ARGV[0] || 'talk.pdf')
