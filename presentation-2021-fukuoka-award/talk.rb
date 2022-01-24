require 'hexapdf'
require 'stringio'

class SlideComposer < HexaPDF::Composer

  def initialize(file_source)
    @file_source = file_source
    super(page_size: [0, 0, 1920, 1080], margin: [220, 80, 80, 80])
    base_style.font('Helvetica').fill_color(40)
    @helvetica_bold = document.fonts.add('Helvetica', variant: :bold)
  end

  def write(output_file, **kwargs)
    @file_source.each do |name, io|
      document.files.add(io, name: name.b)
    end

    output = StringIO.new
    super(output, **kwargs)

    File.open(output_file, 'w+') do |file|
      file.puts(<<~CODE)
        require 'hexapdf'
        $script = nil
        doc = HexaPDF::Document.new(io: DATA)
        file_source = {}
        doc.files.each do |file|
          file_source[file.path] = StringIO.new(file.embedded_file_stream.stream)
        end
        eval(file_source['talk.rb'].string)
        __END__
      CODE
      file.write(output.string)
    end
  end

  def new_page(*, **)
    super
    if document.pages.count == 1
      margin, @margin = @margin, HexaPDF::Layout::Style::Quad.new(80)
      create_frame
      @margin = margin
    else
      @canvas.fill_color(22).rectangle(0, 940, 1920, 140).fill
      @canvas.image(@file_source['logo.png'], at: [50, 970], width: 80)
    end
  end

  def title_slide(text, subtext = nil)
    arr = [{text: text, style: title_style, align: :center, valign: :center}]
    if subtext
      style = {fill_color: 0, font_size: 60}
      arr.concat(["\n", subtext].flatten.map do |x|
        x.kind_of?(String) ? {text: x, **style} : {**style, **x}
      end)
    end
    formatted_text(arr, style: title_style, align: :center, valign: :center)
  end

  def title_style
    @title_style ||= base_style.dup.update(
      font: @helvetica_bold, font_size: 100, line_spacing: {type: 1.5},
      fill_color: [0, 64, 128],
    )
  end

  def bullet_slide(title, bullets)
    new_page
    slide_title(title)
    bullets.each do |bullet|
      text(bullet, style: bullet_style)
    end
  end

  def bullet_style
    @bullet_style ||= base_style.dup.update(
      font_size: 60,
      line_spacing: {type: 1.5},
      padding: [0, 0, 0, 60],
      margin: [30, 0, 30, 40],
      underlays: [lambda do |canvas, box|
        next unless box.kind_of?(HexaPDF::Layout::Box)
        canvas.fill_color(box.style.fill_color)
        canvas.circle(20, box.content_height - box.style.font_size / 2.5, box.style.font_size / 5).fill
      end],
    )
  end

  def image_slide(title, image, desc = nil)
    new_page
    slide_title(title)
    if desc
      self.image(@file_source[image], position: :float, valign: :center)
      desc.each do |bullet|
        text(bullet, style: bullet_style)
      end
    else
      self.image(@file_source[image], position_hint: :center, valign: :center)
    end
  end

  def code_slide(title, code)
    new_page
    slide_title(title)
    text(code, style: code_style)
  end

  def code_style
    @code_style ||= base_style.dup.update(
      font: document.fonts.add("Courier"),
      font_size: 40,
      line_spacing: {type: 1.8},
    )
  end

  private

  def slide_title(title)
    @canvas.font('Helvetica', size: 80).fill_color(213)
    @canvas.text(title, at: [180, 980])
  end

end

file_source ||= {
  'talk.rb' => File.open(__FILE__),
  'logo.png' => File.open('logo.png', 'rb'),
  'optimization.pdf' => File.open('optimization.pdf', 'rb'),
  'line_wrapping.pdf' => File.open('line_wrapping.pdf', 'rb'),
}
composer = SlideComposer.new(file_source)

composer.title_slide(
  "HexaPDF",
  ["Versatile PDF Manipulation and Creation Library for Ruby\n",
   {link: "https://hexapdf.gettalong.org", font_size: 40}],
)

composer.bullet_slide(
  "What is HexaPDF?",
  ['Complete PDF solution',
   'Written in pure Ruby',
   'Accompanying CLI tool',]
)

composer.code_slide(
  "Example HexaPDF Script",
  <<~CODE
  require 'hexapdf'

  doc = HexaPDF::Document.new
  canvas = doc.pages.add.canvas
  canvas.font('Helvetica', size: 100)
  canvas.text("Hello World!", at: [20, 400])
  doc.trailer.info[:Title] = 'Example Document'
  doc.encrypt(owner_password: 'fukuoka', permissions: [:print])
  doc.write("hello_world.pdf", optimize: true)
  CODE
)

composer.bullet_slide(
  "What makes HexaPDF stand out?",
  ['Designed from start with performance and low memory usage in mind',
   'Ruby-esque API',
   'Simple DSL for defining PDF types in Ruby',
   'Low-level API with convenience API on top',
   'Fully-tested with 100% code coverage',]
)

composer.image_slide(
  "File Size Optimization Benchmark", 'optimization.pdf',
  ['Compress PDF as good as possible',
   'qpdf is written in C++',
   'HexaPDF only 2x slower',]
)
composer.image_slide(
  "Line Wrapping Benchmark", 'line_wrapping.pdf',
  ['Wrap text into lines',
   'Prawn Ruby gem for PDF generation',
   'reportlab Python PDF generation library with C extension',
   'HexaPDF is much faster than Prawn',]
)

composer.bullet_slide(
  "Why implement HexaPDF in Ruby?",
  ['Language of choice for most programming tasks',
   'Fast development, especially for complex tasks',
   'Easy and succinct use of PDF objects due to direct mapping to standard Ruby types',]
)

composer.bullet_slide(
  "Impact of HexaPDF",
  ['PDFs are everywhere, e.g. government forms, invoices, manuals, ...',
   'Digitally signing PDFs became more important due to the pandemic',
   'HexaPDF makes working with PDFs in Ruby easy and straightforward',
   'Contributions to the Prawn project',
   'Helping strangers with their PDF problems/automation needs',]
)

composer.bullet_slide(
  "Conclusion",
  ['HexaPDF was only possible because of Ruby',
   'Ruby is already fast for this type of library/application',
   'HexaPDF will become the go-to PDF library for Ruby',
   'Developing HexaPDF in Ruby was and is still fun',]
)

composer.new_page
composer.title_slide("Thank you!")

composer.bullet_slide(
  "Addendum",
  ['This PDF file is also a valid Ruby source file',
   'Run it like `ruby talk.pdf output.pdf` to generate the PDF',
   'All necessary files are embedded into the PDF',]
)
composer.write(ARGV[0] || 'talk.pdf')
