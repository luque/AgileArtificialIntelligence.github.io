#!/bin/bash

#	--mathml \
# 	
# 	--mathjax=https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML \

# 	--self-contained \




#FILES=`ls \
#	13-Robot/*.markdown \
#	14-Zoomorphic/*.markdown`

FILES=`ls \
	15-ZoomorphicSimulation/*.markdown`


#FILES=`ls 13-Robot/*.markdown`


if [ ! -d "build" ]; then
	mkdir build
fi

for originalFile in $FILES
do
	HTMLFILENAME=build/$(echo $originalFile | tr "/" " " | cut -f1 -d " ").html
	echo "Generating " $HTMLFILENAME

	pandoc -o $HTMLFILENAME --self-contained \
		--number-sections --top-level-division=chapter \
		--toc --toc-depth 2 \
		--filter pandoc-fignos \
		--mathml \
		--template template.html --css Template/template.css \
		$originalFile
done




