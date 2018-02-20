include types
from strutils import `%`
from algorithm import sorted
from config import loadConfig

proc newGenAlg*(popSize, numWeights: int, mutationRate, crossoverRate: float): GenAlgRef = 
  new(result)

  result.popSize = popSize
  result.chromoLength = numWeights
  result.mutationRate = mutationRate
  result.totalFitness = 0
  result.generationCounter = 0
  result.fittestGenome = 0
  result.bestFitness = 0
  result.worstFitness = 999999
  result.averageFitness = 0
  result.crossoverRate = crossoverRate
  result.population = newSeq[GenomeRef](popSize)

  #Populate our genomes
  for i in 0 .. <result.popSize:
    result.population[i] = newGenome()

    #populate each genome's chromosomes
    for j in 0 .. result.chromoLength:
      result.population[i].weights.add(newWeight())

proc mutate(alg: var GenAlgRef, chromo: var seq[WeightRef]) {.discardable.} =
  let config = loadConfig()

  for weight in chromo:
    if random(1.0) > alg.mutationRate:
      weight.value += random(-1.0 .. 1.0) * config.dMaxPerturbation

proc getChromoRoulette(alg: GenAlgRef): GenomeRef = 
  new(result)

  var randomFitness = random(0.0 .. alg.totalFitness)
  var fitnessSoFar = 0.0

  for ix in 0 .. <alg.population.len:
    fitnessSoFar += alg.population[ix].fitness

    if fitnessSoFar >= randomFitness:
      result.fitness = alg.population[ix].fitness
      result.weights = @[]
      for w in alg.population[ix].weights:
        result.weights.add(w)
      break

proc crossover(alg: GenAlgRef, mum, dad: seq[WeightRef]): (seq[WeightRef], seq[WeightRef]) =
  var ran_num = random(0.0 .. 1.0)
  if  ran_num > alg.crossoverRate or mum == dad:
    var baby1 = newSeq[WeightRef](mum.len)
    for ix in 0 ..< mum.len:
      baby1[ix].deepCopy(mum[ix])
    var baby2 = newSeq[WeightRef](dad.len)
    for ix in 0 ..< dad.len:
      baby2[ix].deepCopy(dad[ix])
    result = (baby1, baby2)
    return 


  #determine a crossover point
  var cp: int = random(0 .. <alg.chromoLength)

  var baby1, baby2 = newSeq[WeightRef](cp)

  for i in 0 .. <cp:
    baby1[i].deepCopy(mum[i])
    baby2[i].deepCopy(dad[i])

  for i in cp .. <mum.len:
    baby1[i].deepCopy(dad[i])
    baby2[i].deepCopy(mum[i])


  return (baby1, baby2)


proc calculateBestWorstAvgTotal(alg: GenAlgRef): GenAlgRef =
  result.deepCopy(alg)

  result.totalFitness = 0
  var highest, lowest: float64

  for ix in 0 .. <result.population.len:
    if alg.population[ix].fitness > highest:
      highest = alg.population[ix].fitness
      result.fittestGenome = ix
      result.bestFitness = highest

    if alg.population[ix].fitness < lowest:
      lowest = alg.population[ix].fitness
      result.worstFitness = lowest

    result.totalFitness += alg.population[ix].fitness

  result.averageFitness = result.totalFitness / float(result.population.len)

proc getNBest(alg: GenAlgRef, nBest, nCopies: int): seq[GenomeRef] =
  echo "Getting elite copies!"
  echo "Best: " & $nBest
  echo "Copies: " & $nCopies
  var copyVar: GenomeRef
  result = @[]
  for i in countdown(nBest, 0):
    echo "LOOPING I " & $i
    for j in 0 .. nCopies:
      echo "LOOPING J " & $j
      copyVar.deepCopy(alg.population[(alg.population.len - 1) - nBest])
      result.add(copyVar)
  echo "Got " & $result.len & " elite copies!"

proc resetGeneration(alg: GenAlgRef): GenAlgRef = 
  result.deepCopy(alg)

  result.totalFitness = 0
  result.bestFitness = 0
  result.worstFitness = 999999
  result.averageFitness = 0

proc epoch*(alg: GenAlgRef, oldPop: seq[GenomeRef]): seq[GenomeRef] =
  let config = loadConfig()
  #
  #Create a copy of our Genetic Algorithm object
  var genAlg: GenAlgRef = new(GenAlgRef)
  genAlg.deepCopy(alg)

  genAlg.population = oldPop

  genAlg = genAlg.resetGeneration()
  
  genAlg.population = genAlg.population.sorted do (x, y: GenomeRef) -> int:
    return cmp(x, y)

  genAlg = genAlg.calculateBestWorstAvgTotal()
  
  result = @[]
  #Make every second genome an elite mofo
  if (config.NumEliteCopies * config.NumElite) mod 2 == 0:
    result = genAlg.getNBest(config.NumElite, config.NumEliteCopies)


  while result.len < genAlg.popSize:
    let mum = genAlg.getChromoRoulette()
    let dad = genAlg.getChromoRoulette()

    var (baby1, baby2) = genAlg.crossover(mum.weights, dad.weights)

    genAlg.mutate(baby1)
    genAlg.mutate(baby2)


    result.add(newGenome(fitness=0.0, weights=baby1))
    result.add(newGenome(fitness=0.0, weights=baby2))

when isMainModule:
  block:
    echo "RUNNING TESTS FOR GEN ALG"

    let alg = newGenAlg(100, 20, 0.3, 0.7)
    doAssert alg.population.len == 100
    doAssert alg.chromoLength == 20

    let s = alg.epoch(alg.population)
    echo $s.len
    doAssert s.len > 1
