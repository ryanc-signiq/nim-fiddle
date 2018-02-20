# Package

version       = "0.1.0"
author        = "tangdongle"
description   = "A simple neural network"
license       = "MIT"

# Dependencies

requires "nim >= 0.17.3"

skipDirs      = @["tests"]

binDir        = "bin/"

# Tasks

task run, "Build and run the project":
    exec "mkdir -p bin"
    exec "nim c -r --out:bin/nimneural nimneural.nim"

task test_genalg, "Test the Gen Alg Class":
    exec "mkdir -p bin"
    exec "nim c -r --out:bin/genalg nimneural/GenAlg.nim"
