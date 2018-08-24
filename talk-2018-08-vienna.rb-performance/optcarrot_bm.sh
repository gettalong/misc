#!/bin/bash
eval "$(rbenv init -)"

rbenv shell 2.0.0-p648
time ruby -v -Ilib -r./tools/shim bin/optcarrot --benchmark examples/Lan_Master.nes

rbenv shell 2.5.1
time ruby -v -Ilib -r./tools/shim bin/optcarrot --benchmark examples/Lan_Master.nes

rbenv shell 2.6.0-preview2
time ruby -v -Ilib -r./tools/shim bin/optcarrot --benchmark examples/Lan_Master.nes
time ruby --jit -v -Ilib -r./tools/shim bin/optcarrot --benchmark examples/Lan_Master.nes

rbenv shell truffleruby-1.0.0-rc5
time ruby -v -Ilib -r./tools/shim bin/optcarrot --benchmark examples/Lan_Master.nes
