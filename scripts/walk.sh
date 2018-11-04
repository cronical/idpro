#!/bin/bash
#This script walks through directory tree to convert input files to tex files
# and creates a driver tex file which calls the converted files
# finds input files by looking for markdown and MS Word files by extension (.md, .docx)
# if both file types exist with the same name the last one (.md) wins
# Input file names may not currently have spaces in their name.
# Reason is the graphics command in Latex has trouble with these. Use underscores if needed.
#Begins the output file with the preamble from main-template.tex
#Uses the pandoc utility (on path) to perform the document translations
#Order is determined by the alphabetic sorting of sub-folders. Only folders starting with digits are included.
#Recommended usage is two digits then an underscore then the natural folder namea
#
#Heading levels are (to be) handled by modifying the naive translation of the source to reflect the folder context
#
texmain="main.tex"
set +B # avoid brace expansion for these variables
format="\input{%s.tex}\n"
endtext="\end{document}"
set -B
showskip=0 # set to 0 to keep the noise down
regex="^[0-9]+" # to find leading digits on directory names

# include my utility functions
source $(dirname "$0")"/functions.sh" # functions used: startclean, stringcontain
#
#define the main function, which walks a directory tree
# this is recursive.  parameter 1 is required and it s a folder (without the trailing space)
# parameter 2 is the indent level, which defaults to 0
walk() {
  local indent="${2:-0}"
	for entry in "$1"/*; do  # this construct puts the files and directories in alphabetic order
      path=${entry%/*} # the part of the path up to the final slash
      path="$path""/" # the final slash
      thisdir="${entry#"$path"}" # remove the path to get the name of the dir

      ## if its a directory
			if [[ -d "$entry" ]] ; then
         # if it begins with digits, we will process it
        if [[ $thisdir =~ $regex ]]; then
            printf "%*s%s" $indent '' "$entry"
            printf "%s\n" " -- (folder)"
            #startclean "$thisdir"  # just display for now
            walk "$entry" $((indent+1)) # walk
        else # don't process directories that don't start with digits
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
        # latex does not like file names with spaces
        # the following escaping works for files but does not (yet) work for graphics
        escapedfn="$(printf "\"%s\"" "$filename" )"

        # handle the file extensions
        ext="${entry##*.}"
        case $ext in
        docx|md) # it happens they are the same
        # handle the docx temp files.
          if stringcontain "~$" "$filename"; then
            echo "ignoring temp file" > /dev/null
          else
            pandoc --extract-media="${pathname}"   "$entry" -o "${filename}.tex"

            # adjust heading levels
            lowest=$(awk -f scripts/sections.awk "${filename}.tex")
            awk -f scripts/section_map.awk -v low=$lowest -v base=$indent ${filename}.tex > tmp && cp tmp ${filename}.tex
            rm tmp
            # improve graphics placement
            awk -f scripts/graphics_patch.awk ${filename}.tex > tmp && cp tmp ${filename}.tex
            rm tmp
            # include in main file
            subimport=$(printf ${format} "${escapedfn}")
            echo ${subimport} >> ${texmain}

            # report progress
            printf "%*s%s" $indent '' "$entry"
            printf "%s\n" ""
          fi
          ;;

        *) # if not one of the enumerated file types skip it
          if [ $showskip = 1 ]; then
            printf "%*s%s" $indent '' "$entry"
            printf "%s\n" " -- skipped"
          fi
          ;;
        esac
       else # skip all files at the root
          if [[ $indent -eq 0 ]]; then
            if [ $showskip = 1 ]; then
              printf "%*s%s" $indent '' "$entry"
              printf "%s\n" " -- skipped"
            fi
          fi
       fi
    fi
	done

}
# initialize the output file
cp main-template.tex ${texmain}
#start the walk
walk "$1"
# finalize
echo ${endtext} >> ${texmain}
echo "" >> ${texmain}

