#!/bin/bash
#This script walks through directory tree to convert word files to tex files and creates a driver tex file
#Pulls the preamble from main-template.tex
#TODO fix path used on includes - maybe use PWD?
#TODO improve how ordering and chapter / section numbers are handled.
TEXMAIN="main.tex"
set +B
FORMAT="\input{%s.tex}\n"
END="\end{document}"
set -B
walk() {
    local indent="${2:-0}"
    printf "%*s%s\n" $indent '' "$1"
	for entry in "$1"/*; do
			[[ -d "$entry" ]] && walk "$entry" $((indent+4))
		 if [ -f $entry ] && [ $indent -gt 0 ]
		 then
			printf "%*s%s\n" $indent '' "$entry"
			DIR=$(dirname "${entry}")
			FILENAME=${entry%.*}
			EXT=${entry##*.}
# handle the docx case.  Will also include any temp files so close doc in word until code handles 
			if [ "$EXT" == "docx" ] 
			then
				pandoc --extract-media="${DIR}"   "$entry" -o "${FILENAME}.tex"
				SUBIMPORT=$(printf ${FORMAT} ${FILENAME})
				echo ${SUBIMPORT} >> ${TEXMAIN}
				echo ${SUBIMPORT}
			fi

		 fi
	done
	zero=0;
	if [[ $indent -eq $zero ]]; then 
		echo ${END} >> ${TEXMAIN}
		echo "" >> ${TEXMAIN}
	fi
}
cp main-template.tex ${TEXMAIN}
walk "$1"


