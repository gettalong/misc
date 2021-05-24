#!/bin/bash
mkdir -p slides
cd slides
slideshow build ../index.md -t reveal.js
cp ../*.png ../*.svg .
