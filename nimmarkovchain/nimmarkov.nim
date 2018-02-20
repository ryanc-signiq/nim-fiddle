import os
import strutils
import tables


proc buildChain(text: string, chain: Table = initTable[string, seq[string]]()): Table[string, seq[string]] = 
    let words = text.split
    for word in wordsvar index = 1
    for 

proc main(filename: string) = 
    let text = readFile(filename)


if paramCount() == 0:
    quit("Please specify an input file to use")

let filename = paramStr(1)
main(filename)
