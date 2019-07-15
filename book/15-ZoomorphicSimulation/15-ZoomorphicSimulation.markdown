
# Simulating Zoomorphic Creature

The previous chapter presents the infrastructure to define and build zoomorphic creature. However, so far, they cannot do much. They are likely to not move much. This chapter will make a creature evolve to accomplish some simple tasks, such as moving toward a particular direction or passing through some obstacles.

## Process Interruption 

Making creatures evolve is a very costly operation. Most of the script given in this chapter may requires many minutes or hours to complete. We suggest you to be familiar with the way Pharo can be interrupting by pressing the `Cmd` and `.` keys on Mac OSX. On Windows or Linux, you should use the `Alt` key. 

Interrupting Pharo will bring up a Pharo debugger. When this happens, the execution has been interrupted. You can then execute any arbitrary code. 
Closing the debugger will simply end the ongoing computation. Keeping the debugger open means you can always resume the execution you interrupted by clicking on `Proceed`.

## Dedicated Genetic Operator

So far, we have seen two crossover operations: 

- `GACrossoverOperation` to perform a simple crossover, without enforcing any characteristics,
- `GAOrderedCrossoverOperation` to avoid repetitions of particular genes.

In the case of evolving our creatures, it is important to consider a muscle as a whole while performing the crossover. For example, it could be that two creatures have a similar behavior, but each with a very different genotype. We call this situation _competing conventions_. If we combine use the unconstrained crossover operation, it is likely that the children is worse that its parents. 

One way to avoid this problem is to restrict the crossover to happen at _any_ point, but only at a muscle extremity. Combining the genetic information of two different muscle is not efficient in our situation. We define a new operator, called `GAConstrainedCrossoverOperation`:

```Smalltalk
GAAbstractCrossoverOperation subclass: #GAConstrainedCrossoverOperation
	instanceVariableNames: 'possibleCutpoints'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'GeneticAlgorithm-Core'
```

The operator consider a set of possible cutpoints with the variable `possibleCutpoints`, which is set using:

```Smalltalk
GAConstrainedCrossoverOperation>>possibleCutpoints: indexes
	"Set the possible pointcuts considered by the operator"
	possibleCutpoints := indexes
```

We also add a utility method used to hook it into our framework:

```Smalltalk
GAConstrainedCrossoverOperation>>pickCutPointFor: partnerA
	"Argument is not used now. Maybe we can improve that"
	self assert: [ possibleCutpoints notNil ] description: 'Need to provide the possible cut points, using #possibleCutpoints:'.
	^ possibleCutpoints at: (random nextInt: possibleCutpoints size)
```

## Simple Creature

Making creatures evolve is a very costly operation.

Consider the following script:
~~~~~~
numberOfNodes := 3.
numberOfMuscles := (CCreature new configureBall: numberOfNodes) numberOfMuscles.
mg := CMuscleGenerator new
		minStrength: 0.01;
		deltaStrength: 0.8;
		minLength: 10;
		deltaLength: 80;
		deltaTime: 200;
		minTime: 20.
g := GAEngine new.
g crossoverOperator: (GAConstrainedCrossoverOperation new possibleCutpoints: (1 to: numberOfMuscles*5 by: 5)).
g selection: (GATournamentSelection new).
g mutationRate: 0.02.
g endForMaxNumberOfGeneration: 500.
"g endIfNoImprovementFor: 100 withinRangeOf: 40."
g populationSize: 100.
g numberOfGenes: numberOfMuscles * 5.
g createGeneBlock: [ :r :index | mg valueForIndex: index ].
g fitnessBlock: [ :genes |
	creature := CCreature new configureBall: numberOfNodes.
	creature materialize: genes.
	creature resetPosition.
	c := CWorld new.
	c addCreature: creature.
	1500 timesRepeat: [ c beat ].
	creature position x
].
g run. 
g.
~~~~~~


## Ball 

~~~~~~
numberOfMuscles := 90.
mg := CMuscleGenerator new
		minStrength: 0.01;
		deltaStrength: 0.8;
		minLength: 10;
		deltaLength: 80;
		deltaTime: 200;
		minTime: 20.
g := GAEngine new.
g crossoverOperator: (GAConstrainedCrossoverOperation new possibleCutpoints: (1 to: numberOfMuscles*5 by: 5)).
g selection: (GATournamentSelection new).
g mutationRate: 0.02.
g endForMaxNumberOfGeneration: 500.
"g endIfNoImprovementFor: 100 withinRangeOf: 40."
g populationSize: 100.
g numberOfGenes: numberOfMuscles * 5.
g createGeneBlock: [ :r :index | mg valueForIndex: index ].
g fitnessBlock: [ :genes |
	creature := CCreature new configureBall: 10.
	creature materialize: genes.
	creature resetPosition.
	c := CWorld new.
	c addPlatform: (CPlatform new height: 20; width: 80; translateTo: 100 @ -10).
	c addPlatform: (CPlatform new height: 20; width: 80; translateTo: 400 @ -10).
	c addPlatform: (CPlatform new height: 20; width: 80; translateTo: 700 @ -10).
	c addPlatform: (CPlatform new height: 20; width: 80; translateTo: 1000 @ -10).
	c addCreature: creature.
	1500 timesRepeat: [ c beat ].
	creature position x
].
g run. 
g.
~~~~~~

~~~~~~
...
creature := CCreature new configureBall: 10.
creature materialize: g result.
c := CWorld new.
c addPlatform: CPlatform new.
c addCreature: creature.
c open
~~~~~~

![The fitness evolution of a creature made of 10 nodes and 90 muscles.](15-ZoomorphicSimulation/figures/zoomorphicBall.png){#fig:zoomorphicBall}

Figure @fig:zoomorphicBall illustrates the evolution of the fitness through 800 generations.

```Smalltalk
creature := CCreature new configureBall: 10.
creature materialize: #(46 57 0.6301436936017796 73 35 57 37 0.7455573501137819 143 107 49 14 0.35115768426151844 169 92 85 86 0.32359463274180644 140 113 54 65 0.6027750701982413 191 59 53 71 0.0963423280819982 143 183 83 85 0.11049838726431988 67 61 22 79 0.10700324130105006 152 78 29 21 0.4994542904987253 32 30 19 12 0.18657419451352872 27 55 59 68 0.05450737798796379 179 120 31 74 0.21743850181225619 119 120 83 85 0.2863947514241537 66 167 27 48 0.17051114171767198 216 171 81 54 0.27594237027035207 217 143 47 56 0.5765871857509889 98 27 59 29 0.3982801273783111 78 164 20 56 0.035925943267497214 72 103 66 14 0.10116308134568999 120 33 12 21 0.5109705314882894 128 160 51 72 0.363804226011878 210 163 38 17 0.5800702822627827 173 165 35 45 0.2560888502402645 46 23 40 51 0.7652406590223502 96 102 27 40 0.7232469962878372 204 138 29 20 0.6939245676453806 185 42 78 81 0.3826264731831041 212 149 64 80 0.35226660967910045 183 143 25 64 0.3604653526239402 94 110 23 45 0.0212987645023031 68 158 84 86 0.716524867148383 180 121 11 18 0.7855720127260183 159 96 24 14 0.08532353739967734 27 72 68 83 0.40073455612675035 73 125 38 47 0.7297066403551524 44 147 77 63 0.28087378775275956 46 48 82 83 0.5397561886393262 108 202 70 51 0.49820878588045425 96 164 25 25 0.5034138467970369 46 159 38 53 0.601270998768169 185 209 28 28 0.3700446695275813 152 30 33 35 0.6353292634269825 98 54 58 43 0.33866740912602633 43 199 55 30 0.668907751673324 112 193 34 57 0.07028041432624703 141 124 43 47 0.4181811143123457 112 25 90 24 0.11373324346902466 166 39 83 17 0.765568998658829 40 38 42 48 0.5093237132669071 172 189 89 75 0.5919386507300375 115 129 44 29 0.5096213185133512 157 160 18 49 0.1467636942010204 82 158 40 31 0.4694113184415788 176 46 28 46 0.06753185639974282 192 103 76 87 0.32120877280421967 74 108 16 89 0.19919975356627245 90 156 43 43 0.09584452051941515 22 159 21 79 0.5514990971523799 25 26 46 89 0.3122694458729911 116 215 55 42 0.6226618064067615 122 139 71 77 0.597576727842715 70 132 84 21 0.17913475290366207 128 72 75 75 0.2226853180176976 133 99 68 72 0.5840837394139188 186 163 67 75 0.18421771482295252 64 203 79 36 0.10981141802846055 194 43 67 62 0.7963004159118517 177 71 24 16 0.6151985344873735 142 22 29 52 0.19339112670318745 114 195 83 66 0.7405028043363723 132 212 61 30 0.06893818366291848 162 134 55 31 0.09137207891855952 121 178 86 77 0.7793096931880851 184 215 16 55 0.12008714479863977 127 113 31 12 0.3681450776933437 100 40 67 11 0.3293022803958982 96 135 46 50 0.1097400381135475 54 43 56 52 0.36743698643401124 43 111 20 37 0.3154938433251781 40 38 44 47 0.671295115510605 56 56 84 36 0.1317935234875388 114 128 21 20 0.7409173337793524 114 75 75 72 0.037982394410289076 77 171 30 67 0.05339182006353132 103 127 28 16 0.014642127083913482 217 114 81 64 0.43913139333442386 88 174 90 11 0.8039305391134371 26 40 68 71 0.0870067006708154 112 79 77 72 0.043118794873877805 68 109 76 85 0.561802780363617 140 156 ).
c := CWorld new.
c addPlatform: CPlatform new.
c addCreature: creature.
c open
```


## Competing creatures

~~~~~~~~
c := CWorld new.
creature := CCreature new color: Color red; configureBall: 10.
creature materialize: g logs last fittestIndividual genes.
c addCreature: creature.

creature := CCreature new color: Color yellow darker darker; configureBall: 10.
creature materialize: (g logs at: 70) fittestIndividual genes.
c addCreature: creature.

creature := CCreature new color: Color blue darker darker; configureBall: 10.
creature materialize: (g logs at: 100) fittestIndividual genes.
c addCreature: creature.

creature := CCreature new color: Color green darker darker; configureBall: 10.
creature materialize: (g logs at: 180) fittestIndividual genes.
c addCreature: creature.




	c addPlatform: (CPlatform new height: 20; width: 80; translateTo: 100 @ -10).
	c addPlatform: (CPlatform new height: 20; width: 80; translateTo: 400 @ -10).
	c addPlatform: (CPlatform new height: 20; width: 80; translateTo: 700 @ -10).
	c addPlatform: (CPlatform new height: 20; width: 80; translateTo: 1000 @ -10).

c open.
~~~~~~~~

## Worm
~~~~~~~~
numberOfMuscles := 26.
mg := CMuscleGenerator new
		minStrength: 0.01;
		deltaStrength: 0.8;
		minLength: 10;
		deltaLength: 80;
		deltaTime: 200;
		minTime: 20.
g := GAEngine new.
g crossoverOperator: (GAConstrainedCrossoverOperation new possibleCutpoints: (1 to: numberOfMuscles * 5 by: 5)).
g selection: (GATournamentSelection new).
g mutationRate: 0.02.
g endForMaxNumberOfGeneration: 800.
g populationSize: 100.
g numberOfGenes: numberOfMuscles * 5.
g createGeneBlock: [ :r :index | mg valueForIndex: index ].
g fitnessBlock: [ :genes |
	creature := CCreature new configureWorm: 5.
	creature materialize: genes.
	creature resetPosition.
	c := CWorld new.
	c addPlatform: CPlatform new.
	c addCreature: creature.
	3000 timesRepeat: [ c beat ].
	creature position x
].
g run. 
g.

creature := CCreature new configureWorm: 5.
creature materialize: g result.
c := CWorld new.
c addPlatform: CPlatform new.
c addCreature: creature.
c open
~~~~~~~~
