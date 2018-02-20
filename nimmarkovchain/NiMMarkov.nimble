# Package

version       = "0.1.0"
author        = "Ryan Cotter"
description   = "A basic markov chain implementation"
license       = "MIT"

# Dependencies

requires "nim >= 0.17.2"

task run, "Run":
    exec "mkdir -p bin"
    exec "nim c -r --out:bin/nimmarkov nimmarkov.nim"
