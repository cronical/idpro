#!/bin/bash
#strip leading digits from $1
#replace any underscores with spaces
#strip whitespace before or directly after the numbers
#places the result in std out
startclean(){
	str=$1
	str="${str#"${str%%[![:space:]]*}"}"   # remove leading whitespace characters
	while [ ${#str} -gt 0 ] 
	do
		case "$str" in
		[0-9]*)
			# digit
			str=${str##[0-9]}
			;;
		*) 
			#not digit
			break
			;;
		esac
	done
  str=$(tr '_' ' ' <<< $str)
	str="${str#"${str%%[![:space:]]*}"}"   # remove leading whitespace characters
	echo "$str"
}

stringcontain(){ [ -z "${2##*$1*}" ] && [ -z "$1" -o -n "$2" ]; }
