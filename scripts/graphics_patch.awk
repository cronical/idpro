# copy a tex file with revised graphics command
# adds a "here" command after \begin{figure} which is missing from pandoc md output
#
BEGIN{}


/.*/ {
    str = $0
    count=sub(/\\begin{figure}/, "&[h]", str)
    if (count==1) $0 = str
    print $0
}


