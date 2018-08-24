#!/bin/bash
mkdir -p slides
cd slides
slideshow build ../talk.md -t reveal.js
cp ../*.png .
