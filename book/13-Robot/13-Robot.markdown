
# Exiting a Maze

This chapter is about applying a genetic algorithm to help a small robot find an exit. The robot lives in a randomly generated maze, in which its objective is finding the maze exit.

We will encode a path in the maze as a sequence of step orders. An order could be to move one step north, south, west, or east. 

## Robot Definition

First, we define a class `GARobot` that knows its position and the map it lives in:

```Smalltalk
Object subclass: #GARobot
	instanceVariableNames: 'position map'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Robot'
```

The position of the robot may be set using the method:

```Smalltalk
GARobot>>position: aPoint
	"Set the position of the robot"
	position := aPoint
```

The position of the robot may be obtained using:

```Smalltalk
GARobot>>position
	"Return the position of the robot"
	^ position
```

The initialization of the map is performed using the method:

```Smalltalk
GARobot>>map: aMap
	"Set the map where the robot lives in"
	map := aMap
```

A map is an instance of the class `GARobotMap`, which we will see later on. A map will also define the initial position of the robot. 

A robot has the ability to follow some a set of step orders, given as a collection of character `$N`, `$S`, `$W`, and `$E`. The robot will move accordingly, if no wall prevent it. The method `followOrders:` is defined as follows:

```Smalltalk
GARobot>>followOrders: orders
	| d possiblePosition path |
	d := { $N -> (0 @ -1) . $S -> (0 @ 1) . 
		   $W -> (-1 @ 0) . $E -> (1 @ 0) } asDictionary.
	path := OrderedCollection new.
	path add: map initialPosition.
	self position: map initialPosition.
	orders
		do: [ :direction | 
			possiblePosition := position + (d at: direction).
			
			"If we found the exit, then we return"
			possiblePosition == map exitPosition ifTrue: [ ^ path ].
			
			"If there is no wall, then we effectively do the move"
			(map gridAt: possiblePosition) ~= #wall ifTrue: [ 
				position := possiblePosition.
				path add: position ] ].
	^ path
```

The following section describes the map in which the robot can live in. 

## Map Definition

The class `GARobotMap` is made of three variables: 

- `size` to represent the size of the map. A map is a squared space, `size` is the number of unit on a size;
- `content` is an array of array which contains the map itself;
- `random`, as always, is a random number generator.

The class is defined at: 

```Smalltalk
Object subclass: #GARobotMap
	instanceVariableNames: 'size content random path'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Robot'
```

The map is initialized with:

```Smalltalk
GARobotMap>>initialize
	super initialize.
	random := Random seed: 42.
	self size: 30.
```

The map may be modified using the method `gridAt:put:`, defined as:

```Smalltalk
GARobotMap>>gridAt: aPoint put: value
	(self includesPoint: aPoint)
		ifFalse: [ ^ self ].
	^ (content at: aPoint y) at: aPoint x put: value
```

Reading the content of a position is achieved with the method:

```Smalltalk
GARobotMap>>gridAt: aPoint
	(self includesPoint: aPoint)
		ifFalse: [ ^ #empty ].
	^ (content at: aPoint y) at: aPoint x
```

Initialize the map with a given size. The map is filled with `#empty` symbol. 

```Smalltalk
GARobotMap>>size: aSize
	"Create a map filled with #empty"
	size := aSize.
	content := Array new: aSize.
	1 to: size do: [ :i | content at: i put: (Array new: aSize withAll: #empty) ].
	self fillStartAndEndPoints
```

We can fill the starting points and the exit using a dedicated method:

```Smalltalk
GARobotMap>>fillStartAndEndPoints
	self gridAt: self initialPosition put: #start.
	self gridAt: self exitPosition put: #end
```

A method useful to generate random number is:

```Smalltalk
GARobotMap>>rand: anInteger
	"Return a new random number"
	^ random nextInt: anInteger
```

Another utility method to check whether a particular point is within the map:

```Smalltalk
GARobotMap>>includesPoint: aPoint
	"Answer whether a point is within the map"
	^ (1 @ 1 extent: size @ size) containsPoint: aPoint
```

The exit is located at the bottom right of the map:

```Smalltalk
GARobotMap>>exitPosition
	"The exit position, as a fixed position, 
	at the bottom right of the map"
	^ (size - 1) @ (size - 1)
```

The initial position is located at the top left of the map:

```Smalltalk
GARobotMap>>initialPosition
	"The starting position is at the top left of the map"
	^ 2 @ 2
```

Walls are added to the map using the method `fillDensity:`. The method takes an integer as parameter, indicating the number of walls to be added. Each wall is 3 unit long, and is either horizontal or vertical. The method `fillDensity:` is:

```Smalltalk
GARobotMap>>fillDensity: numberOfWalls
	"Fill the map with a given number of walls"
	| offsets |
	numberOfWalls timesRepeat: [ 
		| x y |
		x := self rand: size.
		y := self rand: size.
		
		offsets := (self rand: 2) = 1 
			ifTrue: [ { 1 @ 0 . -1 @ 0 } ] 
			ifFalse: [ { 0 @ -1 . 0 @ -1 } ].
		self gridAt: x @ y put: #wall.
		self gridAt: (x @ y) + offsets first put: #wall.
		self gridAt: (x @ y) + offsets second put: #wall.
	].
	self fillStartAndEndPoints.

	"Fill the wall border"
	1 to: size do: [ :i | 
		self gridAt: i @ 1 put: #wall. 
		self gridAt: 1 @ i put: #wall.
		self gridAt: size @ i put: #wall.
		self gridAt: i @ size put: #wall ] 
```

One a robot has found its way to the exit, it will be convenient to actually draw the path taken by the robot. The following method achieve this:

```Smalltalk
GARobotMap>>drawRobotPath: aPath
	"Draw the robot path"
	path := aPath.
	aPath do: [ :pos | self gridAt: pos put: #robot ]
```

We are almost done. The last thing to implement is `open`, which is in charge of actually rendering the map. As previously, it uses Roassal to building the visual scene. Consider the method `open`:

```Smalltalk
GARobotMap>>open
	"Build and open the visual representation of the map"
	| v colors shape |
	colors := { #empty -> Color white . #wall -> Color brown . 
		#start -> Color red . #end -> Color green . 
		#robot -> Color yellow } asDictionary.

	v := RTView new.
	shape := RTBox new size: 10; color: [ :c | colors at: c ].
	content do: [ :line | 
		v addAll: (shape elementsOn: line) @ RTPopup
	].
	RTGridLayout new gapSize: 0; lineItemsCount: size; on: v elements.
	v add: (RTLabel elementOn: path size asString, ' steps').
	TRConstraint move: v elements last below: v elements allButLast.
	^ v open
```

## Example

We are now ready to build to test our robot how fit it is to find the exit. Consider the following script:

```Smalltalk
map := GARobotMap new fillDensity: 80.
robot := GARobot new.
robot map: map.
g := GAEngine new.
g endIfNoImprovementFor: 5.
g numberOfGenes: 100.
g populationSize: 250.
g createGeneBlock: [ :rand :index :ind | #($N $S $W $E) atRandom: rand ].
g minimizeComparator.
g
	fitnessBlock: [ :genes | 
		robot followOrders: genes.
		robot position dist: map exitPosition ].
g run.
```

![Evolution of the robot fitness.](13-Robot/figures/RobotFitness.png){#fig:RobotFitness.png}

Figure @fig:RobotFitness.png shows the evolution of the population along the generation. 

We can see the path by executing the following script:

```Smalltalk
...
map drawRobotPath: (robot followOrders: g result).
map open
```

![Robot footprint.](13-Robot/figures/RobotPathNotOptimal.png){#fig:RobotPathNotOptimal}

Figure @fig:RobotPathNotOptimal shows the path taken by our robot. We see that the robot made 81 steps to reach the exit. The path taken by our robot is clearly not the shortest. The robot made some unecessary steps.

The situation could be improved by adding a penalty reflecting the path length. Consider the script: 

```Smalltalk
map := GARobotMap new fillDensity: 80.
robot := GARobot new.
robot map: map.
g := GAEngine new.
g endIfNoImprovementFor: 5.
g numberOfGenes: 100.
g populationSize: 250.
g createGeneBlock: [ :rand :index :ind | #($N $S $W $E) atRandom: rand ].
g minimizeComparator.
g
	fitnessBlock: [ :genes | 
		| path |
		path := robot followOrders: genes.
		(robot position dist: map exitPosition) + (path size / 5) ].
g run.
map drawRobotPath: (robot followOrders: g result).
map open
```

![Short robot footprint.](13-Robot/figures/RobotOptimalPath.png){#fig:RobotOptimalPath}

Figure @fig:RobotOptimalPath gives a better path. Only 59 steps are necessary to reach the exit. Without the penalty, the path was 81 steps long. We divide the path length by the arbitrary 5. Removing the division (`(robot position dist: map exitPosition) + path size`) would prevent the robot from looking for the exit. The reason is that the reward for doing a short path is more atractive compare when reaching the exit. 

## What have we seen in this chapter?

We have seen a compeling application of the genetic algorithm to help a robot find an exit in a maze. In particular, we have covered:

- the robot and map modeling,
- modeling a robot path as a sequence of orders,
- a simple way to significantly improve the solution by adding a small penalty.

As a side note, _Reinforcement Learning_ (RL) is another exploration technique. The classical application of RL is making a robot find a maze exit, as we did in this chapter. RL is based on an explicit reward mechanism. Genetic Algorithm will produce a descent solution to the same problem, however the algorithm needs to be adequately tuned. For example, we need to specify the length of the individuals genetic information (`100` in our example). Using RL, no arbitrary sequence length need to be provided. 




