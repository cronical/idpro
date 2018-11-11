# make a copy of a tex file revising graphics command and tables
# pass in var, path, with -v.  Used to locate table meta data
# 1 adjusts graphics
# a) adds a "here" command after \begin{figure} which is missing from pandoc md output
# b) wraps bare graphics with a figure
# c) replace figures with wrapfigures
# 2. adjusts tables
# a) wraps \longtable with \table and adds caption

BEGIN{
  in_figure=0; # track if we are in a figure environment
  close_figure=0; # track if we need to close a newly generated figure wrapper
  left_brace = "{"
  right_brace = "}"
  begin_table= "\\begin{table}"
  end_table="\\end{table}"
  table_no=0
  pandoc_col_spec="@{}ll@{}"

  # experimenting with wrapping text around graphics
  wrap_text=1 
  if (wrap_text==1){
      begin_figure="\\begin{wrapfigure}{i}";
      end_figure="\\end{wrapfigure}"
      default_width = "{0.3\\textwidth}"
  }
  if (wrap_text==0){
      begin_figure="\\begin{figure}";
      end_figure="\\end{figure}"
  }
}

/\\begin{figure}$/ {
      in_figure=1; # flag that we are in figure environment
}

/\\end{figure}$/ {
      in_figure=0; # # we exited the figure environment
}


/.*/ {

    # if we are doing wrapping change begin and in figure statements
    if (wrap_text==1){
      count=sub(/\\begin{figure}$/, (begin_figure default_width), $0)
      count=sub(/\\end{figure}$/, "\\end{wrapfigure}", $0)
    }

    # look for graphics that need adjusting.
    # Pandoc does not put figures around graphics from docx files
    idx = match($0 , /\\includegraphics/)
    if (idx != 0 && in_figure==0){ # we have encounter a 'bare' graphic
      if (wrap_text==1) {
        #Files from docx do provide dimensions
        #We are given a width that we extract now if we are wrapping text
        split($0, parts ,"[\\[\\]]") # pull out the part in brackets
        split(parts[2],wh,"[,]") # a set of two strings for width and height
        for (idx in wh){
          idx = match(wh[idx] , /width/)
          if (idx!=0){
            split(wh[idx], w, "=")
            width = w[2]  # the actual width as number and units
            break
          } # close if
        } # close for

        # begin the wrap of the bare graphic with a figure, using the width we found
        print (begin_figure left_brace width right_brace )
        print "\\vspace{-8pt}"
      } # close wrap_text==1
      if (wrap_text==0){
        print begin_figure
      }
      close_figure=1 ; # flag to close later

      # due to pandoc leaving a word after the closing brace on the include graphics line
      # carry anything there forward
      # and at the same time, look for instructions about the caption
      split($0, parts, right_brace)
      leftover = parts[2] # the stuff not part of the \includegraphics command
      $0 = (parts[1] right_brace) # the command itself

      #construct file name idx instructions about caption may be
      split(parts[1], tmp ,left_brace) # extracting the path
      path=tmp[2] # path and file name of the inserted graphic
      n = split(path, a , "/")
      ffn=a[n] # full filename including the extension
      n = split(ffn, a , ".")
      ffn2= (a[1] ".caption")
      sub(ffn, ffn2, path) # modify path to use constructed filename
      getline caption < path # get the caption to place inside figure and filter out later
      do_caption=1  # it has to be processed out of order, so flag
    } # done with the if for bare graphics

    #see if table
    idx = match($0 , /\\begin{longtable}/)
    if (idx != 0){
      print begin_table
      table_no++
      #now get info from tableN.info
      caption="" # in case the file is not there
      fn = (path "table" table_no++ ".info")
      while ((getline line < fn) > 0){
        split(line, tmp, "=")

        # add the caption
        if(tmp[1]=="caption"){
          print ("\\caption" left_brace tmp[2] right_brace)
        }
        # replace the default column specification
        if(tmp[1]=="column_spec"){
          sub(pandoc_col_spec, tmp[2], $0)
        }
      }
      close(fn)
    }

    idx = match($0 , /\\end{longtable}/)
    if (idx != 0){
      close_table=1
    }



    #for png graphics from word files, the caption is just text a bit below the figure - just ignore it.
    idx = match($0, ("^Figure " caption))
    if(idx == 0){
      print $0  # print all lines (possibly modified) unless it is filtered out.
    }

    # insert the caption once
    if(do_caption==1){
      print ("\\caption{" caption "}")
      do_caption=0
    }

    if (close_figure==1){ # close out the wrap
      print end_figure
      print leftover
      close_figure=0
    }
    if (close_table==1){ # close out the wrap
      print end_table
      close_table=0
    }
}

