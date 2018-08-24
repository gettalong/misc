#!/bin/bash
eval "$(rbenv init -)"
rbenv shell 2.0.0-p648
ruby -ve "puts RubyVM::InstructionSequence.compile('x, y = 1, 2; [x, y].max').disasm"
echo
rbenv shell 2.4.4
ruby -ve "puts RubyVM::InstructionSequence.compile('x, y = 1, 2; [x, y].max').disasm"
echo
rbenv shell 2.5.1
ruby -ve "puts RubyVM::InstructionSequence.compile('x, y = 1, 2; [x, y].max').disasm"
echo
rbenv shell 2.6.0-preview2
ruby -ve "puts RubyVM::InstructionSequence.compile('x, y = 1, 2; [x, y].max').disasm"
