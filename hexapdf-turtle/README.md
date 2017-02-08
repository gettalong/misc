# Turtle graphics with PDF backend based on HexaPDF

This directory contains my implementation of a turtle graphics system which uses HexaPDF (at least
version 0.3.0) as backend for drawing the actual graphics.

The inspiration for doing this comes from reading Jamis Buck's website and his weekly challenges,
more exactly from his 15th challenge:
http://weblog.jamisbuck.org/2016/11/5/weekly-programming-challenge-15.html

The implementation of the turtle graphics can be found in `turtle.rb`.

There are also various example files which can be run using `ruby run.rb FILENAME`. Two output files
will be produced: One PDF with a single page showing the complete graphics, and another PDF with one
page per frame that can be viewed in presentation mode for getting animated turtle graphics.


## Talk

I gave a talk about the implementation at the [vienna.rb](http://www.vienna-rb.at/) meetup on
February 2nd 2017, see the corresponding talk directory.


## Example Credits

The example files `boxes.rb`, `circles.rb` and `spiral.rb` are examples from Jamis Buck's
implementation of turtle graphics, slightly adapted to fit my implementation. For the originals see
<https://github.com/jamis/weekly-challenges/tree/master/015-turtle-graphics>.

The `tree.rb` and `ruby.rb` examples were implemented by myself.


## Image Credits

* `turtle.png`:
  <https://clipartfest.com/download/efc669db8a84e2659da2630b3df89d0dc7e45701.html>
