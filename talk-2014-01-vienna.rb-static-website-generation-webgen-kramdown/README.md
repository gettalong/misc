# Sample webgen Website

This is a sample website I created for a talk at [vienna.rb] on 9th January 2014.

The talk is primarily about webgen and how it can be used to build a static website. Since kramdown
is used as primary Markdown converter for webgen, there is also some information about it.


## How to Generate the Website

You need webgen and some other gems:

    gem install webgen webgen-tipue_search-bundle prawn sass

Then just execute `webgen` in the directory and view the output in the `out/` sub directory.


## Features of the Website

The sample website is based on the [vienna.rb] website theme which I converted for use with webgen
in about 20 minutes.

After that I added some things that are showcased by the site, namely:

* kramdown
* a custom content processor for generating PDFs via kramdown
* multilingual pages
* meta information files
* virtual files
* tipue_search bundle integration
* CSS generation via Sass

[vienna.rb]: http://vienna-rb.at
