#!/bin/bash
#This script walks through directory tree to convert word files to tex files and creates a driver tex file
#Pulls the preamble from main-template.tex
#TODO fix path used on includes - maybe use PWD?
#TODO improve how ordering and chapter / section numbers are handled.
texmain="main.tex"
set +B
format="\input{%s.tex}\n"
endtext="\end{document}"
set -B
showskip=0 # set to 0 to keep the noise down
source $(dirname "$0")"/functions.sh" # locate my utility functions
# functions used: startclean, stringcontain
walk() {
  local indent="${2:-0}"
	for entry in "$1"/*; do
      regex="^[0-9]+"
      path=${entry%/*} # the part of the path up to the final slash
      path="$path""/" # the final slash
      thisdir="${entry#"$path"}" # remove the path to get the name of the dir

      ## if its a directory
			if [[ -d "$entry" ]] ; then
        if [[ $thisdir =~ $regex ]]; then
            printf "%*s%s" $indent '' "$entry"
            printf "%s\n" " -- entering"
            #startclean "$thisdir"  # just display for now
            walk "$entry" $((indent+1)) # walk
        else
          if [ $showskip = 1 ]; then
            printf "%*s%s" $indent '' "$entry"
            printf "%s\n" " -- skipped"
          fi
        fi

     ## now the files
     else #if its a file
       if  [ $indent -gt 0 ]
       then
        pathname=$(dirname "${entry}")
        filename=${entry%.*}
        escapedfn="$(printf "\"%s\"" "$filename" )"
        ext="${entry##*.}"
        case $ext in
        docx)
        # handle the docx case.
          if stringcontain "~$" "$filename"; then
            echo "ignoring temp file"
          else
            pandoc --extract-media="${pathname}"   "$entry" -o "${filename}.tex"
            subimport=$(printf ${format} "${escapedfn}")
            echo ${subimport} >> ${texmain}
            printf "%*s%s" $indent '' "$entry"
            printf "%s\n" " -- included"
          fi
          ;;
        md)
          pandoc --extract-media="${pathname}"   "$entry" -o "${filename}.tex"
          subimport=$(printf ${format} "${escapedfn}")
          echo ${subimport} >> ${texmain}
          printf "%*s%s" $indent '' "$entry"
          printf "%s\n" "-- included"
          ;;
        *)
          if [ $showskip = 1 ]; then
            printf "%*s%s" $indent '' "$entry"
            printf "%s\n" " -- skipped"
          fi
          ;;
        esac
       else
          if [[ $indent -eq 0 ]]; then
            if [ $showskip = 1 ]; then
              printf "%*s%s" $indent '' "$entry"
              printf "%s\n" " -- skipped"
            fi
          fi
       fi
    fi
	done
	zero=0;
	if [[ $indent -eq $zero ]]; then 
		echo ${endtext} >> ${texmain}
		echo "" >> ${texmain}
	fi
}
cp main-template.tex ${texmain}
walk "$1"
