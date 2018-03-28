# -*- coding: utf-8 -*-

require 'hexapdf'

Dir.chdir(__dir__)

FONT_PATH = ARGV[0] || '/home/thomas/.fonts'

include HexaPDF::Layout

class Slides

  attr_reader :doc
  attr_reader :width
  attr_reader :height

  # The canvas of the current slide, if there is a current slide.
  attr_reader :canvas

  # The default style that is applied if no special style options are specified.
  attr_accessor :default_style

  def initialize(width, height)
    @doc = HexaPDF::Document.new
    @doc.config['page.default_media_box'] = HexaPDF::Rectangle.new([0, 0, width, height])
    @doc.config['font.map'] = {
      'normal' => {
        none: "#{FONT_PATH}/SourceSansPro-Regular.ttf",
        light: "#{FONT_PATH}/SourceSansPro-Light.ttf",
        bold: "#{FONT_PATH}/SourceSansPro-Bold.ttf",
      },
      'code' => {
        none: "#{FONT_PATH}/SourceCodePro-Regular.ttf"
      }
    }
    @width = width
    @height = height
    @default_style = Style.new(font: @doc.fonts.add('normal'), font_size: 100)
  end

  def slide(&block)
    @canvas = @doc.pages.add.canvas
    @canvas.save_graphics_state do
      @canvas.fill_color("3157a7")
      @canvas.rectangle(0, 0, width, height).fill
    end
    instance_exec(&block)
    puts "Slide #{@doc.pages.count} done" if $DEBUG
  ensure
    @canvas = nil
  end

  # A simple slide with just the given text, centered vertically and with line breaks applied.
  def simple(text)
    tl = TextLayouter.new(items: fragments(text, simple_style), width: width, height: height,
                          style: simple_style)
    if canvas
      text_layouter_draw(tl, canvas, 0, height)
    else
      slide { text_layouter_draw(tl, canvas, 0, height) }
    end
  end

  # Creates the header of a slide at the top.
  def header(text)
    tl = TextLayouter.new(items: fragments(text, header_style), width: width, height: height / 5,
                          style: header_style)
    text_layouter_draw(tl, canvas, 0, height)
    canvas.save_graphics_state do
      canvas.line_width(10).
        line_cap_style(:round).
        stroke_color(1.0).
        line(20, height * 4 / 5, width - 20, height * 4 / 5).stroke
    end
  end

  # Creates a list for the given items.
  def list(items, width: (self.width * 14 / 16), offset: (self.width / 16))
    y_offset = height * 3 / 4
    indent = 70
    items.map! do |item|
      tl = TextLayouter.new(items: fragments(item, content_style), width: width - indent,
                            height: y_offset, style: content_style)
      _, result = tl.fit
      unless result == :success
        warn("Some content didn't fit on page #{canvas.context.index + 1}")
        break
      end
      tl_offset = y_offset
      y_offset -= tl.actual_height + content_style.font_size / 2
      [tl, tl_offset]
    end
    y_offset = (y_offset - content_style.font_size / 2) / 2
    items.each do |layouter, layouter_offset|
      tl = TextLayouter.new(items: fragments("•", content_style), width: indent,
                            style: content_style)
      text_layouter_draw(tl, canvas, offset, layouter_offset - y_offset)
      layouter.draw(canvas, offset + indent, layouter_offset - y_offset)
    end
  end

  # Creates the content of a slide under the header.
  def content(text, width: (self.width * 15 / 16), offset: (self.width / 16 / 2))
    tl = TextLayouter.new(items: fragments(text, content_style), width: width,
                          height: height * 3 / 4, style: content_style)
    text_layouter_draw(tl, canvas, offset, height * 3 / 4)
  end

  def write(filename = 'talk.pdf')
    @doc.write(filename)
  end

  private

  # Converts text into an array of text fragments.
  #
  # The argument +text+ may either be a simple string or an array of hashes/strings. In case of
  # hashes:
  #
  # * If there is a :text key, it is used as as simple text.
  # * If there is a :link key, a link is created. If no :text key was specified, the link is used
  #   as text.
  # * All other keys are assumed to be style keys. If no other keys are specified, the default
  #   style is used.
  def fragments(text, used_default_style = default_style)
    if text.kind_of?(String)
      fragment = TextFragment.new(items: used_default_style.font.decode_utf8(text), 
                                  style: used_default_style)
      [TextShaper.new.shape_text(fragment)]
    else
      text.map do |hash|
        hash = {text: hash} if hash.kind_of?(String)
        link = hash.delete(:link)
        text = hash.delete(:text) || link
        if link || !hash.empty?
          hash[:font] ||= used_default_style.font
          # The next 3 lines are a hack until style inheritance works!
          style = used_default_style.clone
          hash.each {|key, value| style.send(key, value) }
          style.instance_eval { @scaled_item_widths = {} }
          style.clear_cache
          style.overlays.add(:link, uri: link) if link
        else
          style = used_default_style
        end

        fragment = TextFragment.new(items: style.font.decode_utf8(text), style: style)
        TextShaper.new.shape_text(fragment)
      end
    end
  end

  # Wraps TextLayouter#draw to write out a warning if some text didn't fit.
  def text_layouter_draw(tl, canvas, x, y)
    _, result = tl.fit
    unless result == :success
      warn("Some content didn't fit on page #{canvas.context.index + 1}")
    end
    tl.draw(canvas, x, y)
    result
  end

  # The style for the simple slides.
  def simple_style
    @simple_style ||= Style.new(font: default_style.font, font_size: 100, align: :center,
                                valign: :center, fill_color: [240, 240, 240])
  end

  # The style for the slide headers.
  def header_style
    @header_style ||= Style.new(font: doc.fonts.add("normal", variant: :bold), font_size: 100,
                                 align: :center, valign: :center, fill_color: [240, 240, 240])
  end

  # The style for the simple slides.
  def content_style
    @content_style ||= Style.new(font: doc.fonts.add("normal", variant: :light), font_size: 70,
                                 align: :left, valign: :top, font_features: {kern: true},
                                 fill_color: [240, 240, 240]).
      line_spacing(:proportional, 1.4)
  end

end

slides = Slides.new(1920, 1080)
code = slides.doc.fonts.add('code')
bold = slides.doc.fonts.add('normal', variant: :bold)

link = {fill_color: [255, 255, 128], underline: true}

slides.slide do
  canvas.image("fossil.pdf", at: [200, 250], width: 500)
  simple([
    "Fossil SCM\n\n",
    {link: "https://www.fossil-scm.org/", font: code, font_size: 50, **link},
    {text: "\n\n\nvienna.rb Talk — 2017-12-07\nThomas Leitner (gettalong)", font_size: 40},
  ])
end

slides.slide do
  header("Contents")
  list([
    'Principles',
    'Workflows',
    'Fossil vs. Git',
    'Hands On',
    'Where\'s my Ruby',
  ])
end

slides.slide do
  header("Principles")
  list([
    ['Repository is a single file (an ', {text: 'SQLite database', font: bold}, ')'],
    'Multiple check-outs per repository',
    ['Source tree identified by occurence of ', {text: '.fslckout', font: code}, ' file'],
  ])
end

slides.slide do
  header("Principles")
  list([
    ['Particular version of a file is an "', {text: 'artifact', font: bold}, '"'],
    'Artifacts are referenced by a hash ID (SHA3-256 or SHA1)',
    ['Artifacts are ', {text: 'immutable', font: bold}],
    'Repository is an unordered collection of artifacts',
  ])
end

slides.slide do
  header("Principles")
  list([
    ['Revisions are called "', {text: 'check-ins', font: bold}, '" (i.e. hierarchy of files)'],
    ['Special "', {text: 'manifest', font: bold}, '" file identifies every artifact of a check-in'],
    'The manifest can optionally be materialized in a source tree',
    'Artifact ID of the manifest is the ID of the check-in',
  ])
end

slides.slide do
  header("Workflows")
  canvas.image("workflow.png", at: [1500, 50], height: 800)
  list([
    'Fossil supports two workflows: autosync and manual-merge',
    [{text: 'autosync', font: bold}, ': a commit will automatically push'],
    [{text: 'manual-merge', font: bold}, ': a commit must manually be follwed by push'],
  ], width: 1300)
end

slides.slide do
  header("Fossil vs. Git")
  list([
    'Cathedral vs. Bazaar style development',
    'Self-contained system vs. Many small tools',
    'Many check-outs vs. One check-out',
    'What you did vs. What you should have done',
    'BSD vs. GPL',
  ])
end

slides.slide do
  header("Features in Fossil Missing in Git")
  list([
    'Single-file static executable (6MiB)',
    'Wiki, embedded documentation, ticket system, tech notes',
    'Unversioned files',
    'Named branches (pushed/pulled from server)',
    'Integrated multi-purpose web UI',
  ])
end

slides.slide do
  header("Features in Git Missing in Fossil")
  list([
    'Staging area',
    [{text: 'git add -p', font: code}],
    'Rebase command',
    'Push/Pull of single branch',
    'Colorized output',
  ])
end

slides.slide do
  header("Git-to-Fossil")
  list([
    [{text: "git fast-export --signed-tags=strip --all |\n  fossil import --git rails.fossil",
     font: code, font_size: 50}],
    "Took about 40min",
    "Fossil repo size 236MiB\nGit repo size 171MiB",
  ])
end

slides.slide do
  header("Hands On")
  list([
    'fossil new or fossil clone',
    'fossil add/rm',
    'fossil changes/status/extras/clean/unversioned',
    'fossil commit',
    'fossil settings',
  ])
end

slides.slide do
  canvas.opacity(fill_alpha: 0.8) do
    canvas.image('ruby-logo.png', at: [710, 290], width: 500)
  end
  simple("So... where is my Ruby?")
end

slides.slide do
  header("It's just SQLite  ;-)")
  content([
    {text: <<~TEXT, font: code, font_size: 60},
    gem install sqlite3

    require "sqlite3"
    db = SQLite3::Database.new("repo.fossil")
    db.execute("select * from ticket") do |row|
      p row
    end
    TEXT
  ])
end

slides.slide do
  header("More Information")
  list([
    ['Fossil Homepage → ',
      {link: 'https://www.fossil-scm.org/xfer/doc/trunk/www/permutedindex.html',
       font: code, font_size: 50, **link}],
    ['Colorize output (or ', {text: 'fossil diff --tk', font: code}, ') → ',
     {link: 'https://www.mail-archive.com/fossil-users@lists.fossil-scm.org/msg09912.html',
      font: code, font_size: 50, **link}],
    'Private branches (not pushed/pulled)',
    'Emacs/Vim integration available',
    ['Hosting: ', {link: 'http://chiselapp.com', font: code, font_size: 50, **link}],
  ])
end

slides.slide do
  header("Summary")
  list([
    'Fossil is a distributed SCM that includes a ticket system and a wiki',
    'Good for (smaller) teams with a centralized workflow',
    'Synchronization with Git possible',
    'Single file installation',
    'Ease of use, e.g. integrated web UI',
  ])
end

slides.slide do
  canvas.image("fossil.pdf", at: [400, 250], width: 500)
  simple([
    "\n\n\n\nThanks!\n\n\n\n\n",
    {text: "And for some more Ruby: This talk was built with Ruby and HexaPDF :-)",
     font_size: 30, fill_color: [200, 100, 100]},
  ])
end


slides.write
