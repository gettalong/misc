# = webgen extensions directory
#
# All init.rb files anywhere under this directory are automatically
# loaded. This allows you to add your own extensions to webgen or to
# modify webgen's core.
#
# If you don't need this feature you can savely delete this file and the
# directory in which it is!
#
# * For information on how to write extensions, have a look at the API
#   documentation of webgen at http://webgen.rubyforge.org/docs/api.
#
# * Have a look at the API documentation of Webgen::BundlerLoader to see
#   what methods are available in init.rb files.
#
load('tipue_search')

require 'json'
require 'fileutils'
require 'kramdown/document'

website.ext.content_processor.register('pdf') do |context|
  pdf_template = context.node.resolve(context.node['pdf-template'])

  tmp_img_dir = website.tmpdir(File.join('content_processor.pdf', context.node.cn))
  FileUtils.mkdir_p(tmp_img_dir)

  options = context.website.config['content_processor.kramdown.options'].dup
  options[:link_defs] = context.website.ext.link_definitions.merge(options[:link_defs] || {})
  options[:template] = "string://" + pdf_template.blocks['content']
  options[:context] = context
  options[:image_directories] = [File.join(context.website.directory, 'src', context.node.parent.dest_path),
                                tmp_img_dir]
  context.website.ext.item_tracker.add(context.dest_node, :node_content, pdf_template)
  doc = ::Kramdown::Document.new(context.content, options)
  context.content = doc.to_pdf
  doc.warnings.each do |warn|
    context.website.logger.warn { "kramdown PDF conversion warning while parsing <#{context.ref_node}>: #{warn}" }
  end
  context
end

