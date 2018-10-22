#!/bin/bash
TEXMAIN="main.tex"
set +B
FORMAT="\input{%s.tex}\n"
END="\end{document}"
set -B
walk() {
        local indent="${2:-0}"
        printf "%*s%s\n" $indent '' "$1"
	for entry in "$1"/*.docx; do
	 if [[ -f $entry ]]; 
	 then
		printf "%*s%s\n" $indent '' "$entry"
		DIR=$(dirname "${entry}")
		FILENAME=${entry%.*}
		pandoc --extract-media="${DIR}"   "$entry" -o "${FILENAME}.tex"
		SUBIMPORT=$(printf ${FORMAT} ${FILENAME})
		echo ${SUBIMPORT} >> ${TEXMAIN}
	 fi
	done
        for entry in "$1"/*; do
                [[ -d "$entry" ]] && walk "$entry" $((indent+4))
        done
	zero=0;
	if [[ $indent -eq $zero ]]; then 
		echo ${END} >> ${TEXMAIN}
		echo "" >> ${TEXMAIN}
	fi
}
cp main-template.tex ${TEXMAIN}
walk "$1"


