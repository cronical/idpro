# IDPro
Demo to experiment with IDPro Body of Knowledge techniques

## Tools needed
1. Tool for intake of various formats - accept docx, md, and tex
2. Source management tool - manage revisions, allow for distributed collaboration
3. Composition tool - compile inputs into output format(s)

4. Visual editor(s) - for productivity need word processing style editor
5. Tracking mechanism for provenance of content - author and copyright holder at a minimum.

## Tools in play

1. The open source pandoc provides reasonable translation between the three listed formats.  However, there are some considerations with graphics, tables etc.
2. The use of *git* and *github* provides a strong facility to manage the storage and versioning of the content in a controlled collaborative way.
3. Two options for composition of the components have been identified. 
   * Latex - very long  history with *a lot* of industry support.  However, there is a learning curve.
   * MS Word Master documents.  Master documents can do the job, but they have a terrible reputation as being finicky and even corrupting files.  
4. For visual editing MS Word is widely known but various Markdown editors may be workable (e.g. this is written on Typora)
5. The mechanism for tracking content is probably best done with meta data on the content itself.  Tagging in *git* should be explored.

## Structure

The root contains the files that control the composition and any supporting files.  These are `main.tex` and (eventually) `main.docx`. 

Under the root folder are folders for each of the chapters.  Under the chapter folders are folders for the sections.  

The chapter and section folders contain source documents (currently `docx`) and resulting `tex` documents. 

A subfolder named `media` will exist if any media are extracted from the source document.  This folder will be created and populated by a script (see `walk.sh`)

References to the `media` folder will exist in the `.tex` file.

In addition to the content folders there are two utility folders for notes and scripts.
### Order
The nested set of folders provides the heirarchy of the document outline.  
The order of the sections is provided by the file and folder names.
The script sorts them alphabetically, which of course, is not what we typically want.
By convention the files and folders are named with numeric prefixes so that they come in the desired order. For instance: 
`05_authentication`
`10_accounts`

forces authentication to come before accounts. Note: for now, anyway, use underscores not spaces.

### Processing

The script only processes folders that begin with a digit.

## Helper files
In the case of graphics and tables, some of the information needed is not available in the source document or it is not consistently exported.  Captions are the primary example.  Information about column widths is not exported by Pandoc. The helper files must be created by the operator as needed.

### Graphics helper
The helper file has the same name as the graphics file but with the extension `caption`.
For instance in the media folder you might see
   `image1.caption
   image1.jpeg`

The contents of the caption file is the text for the caption for that image.  If Pandoc does export the caption, to prevent it showing up in the wrong place, it is removed during processing.

### Table helper

The table needs additional assistance and the table is not an external file.  The tables in a single document are considered numbered 1...n. And for each table a file is created called `tableN.info` where N is the sequence number.  There are two rows in the table, one for the caption and one for the column specificiation. For instance:

```
caption=Components of Authentication
column_spec=l p{4in}
```

The column spec in this case says the 1st column is left aligned and the 2nd is paragraph wrapped at 4 inches.




