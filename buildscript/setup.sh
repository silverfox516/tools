#!/usr/bin/bash

PRJ=test

TARGET_FILES=(`ls targets`)

for t in ${TARGET_FILES[@]}; do
	echo target: $t
	source targets/$t

	eval "function ${PRJ}_${t}() {
		for key in \${!COMMANDS[@]}; do
			\${COMMANDS[\$key]};
		done
	}"
	${PRJ}_${t}
done
