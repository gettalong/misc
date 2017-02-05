# -*- encoding: utf-8 -*-

require_relative 'turtle'

$data = {moves_per_frame: 1, fps: 25}

filename = ARGV.shift
name = File.basename(filename, '.*')

load(filename)

$data[:turtle].create_pdf($data[:width], $data[:height]).
  write("#{name}.pdf", optimize: true)

$data[:turtle].create_pdf_animation($data[:width], $data[:height],
                                    moves_per_frame: $data[:moves_per_frame],
                                    fps: $data[:fps]).
  write("#{name}-anim.pdf", optimize: true)
