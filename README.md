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

The root contains the files that control the composition, the finished output and some supporting files.  The primary input file is `main-template.tex`.  This file is the basis of the file `main.tex`, which is generated to include a series of files which occur lower in the folder tree. 



`├── 05_authentication
│   ├── 00_authn.docx
│   ├── 01_passwords
│   │   ├── 10_Passwords.docx
│   │   ├── 30_entropy
│   │   │   ├── Entropy.docx
│   │   │   └── media
│   │   └── media
│   └── 20_onetime
│       ├── 10_onetime.docx
│       └── 20_pad
│           ├── Pad.docx
│           └── media
├── 10_accounts
│   ├── 00_accounts.docx
│   └── 10_non_personal_accounts
│       └── non_personal.md`



Under the root folder are folders for each of the chapters.  Under the chapter folders are folders for the sections.  The chapter and section folders contain source documents which are either docx or markdown.

The folders and the source files are prefixed by numbers to aid in ordering (see below).  Ignoring those numbers, the source files here are authn.docx, Passwords.docx, Entropy.docx, onetime.docx, Pad.docx, accounts.docx and non_personal.md.

Once the "walk" script is run the folders also contain the resulting `tex` documents. 

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

forces authentication to come before accounts. Note: for now,  use underscores not spaces in file names.

## Processing

The script called "walk.sh" traverses the directory and selects only processes folders that begin with a digit. The script walks through the directory tree to convert input files to tex files using Pandoc. It creates a driver tex file which includes the converted files. It finds input files by looking for markdown and MS Word files by extension (.md, .docx). If both file types exist with the same name the last one (.md) wins.  
The script also normalizes the levels of the headings so that they align to the levels in the folder structure.
The script also adjusts the resulting text to better handle graphics placement.

The basic operating scenario is
1. Place files in folders and set names according to order desired.
2. Run the walk script to create the operating input to the "tex" formatter
3. Run the "tex" formatter to create the output.

## Helper files
In the case of graphics and tables, some of the information needed is not available in the source document or it is not consistently exported.  Captions are the primary example.  Information about column widths is not exported by Pandoc. The helper files must be created by the operator as needed.

### Graphics helper
The helper file has the same name as the graphics file but with the extension `caption`.
For instance in the media folder you might see
   `image1.caption
   image1.jpeg`

The contents of the caption file is the text for the caption for that image.  If Pandoc does export the caption, to prevent it showing up in the wrong place, it is removed during processing.  The graphics "help" is automatic.

### Table helper

The table needs additional assistance and the table is not an external file.  The tables in a single document are considered numbered 1...n. And for each table a file is created called `tableN.info` where N is the sequence number.  There are two rows in the .info file, one for the caption and one for the column specificiation. For instance:

```
caption=Components of Authentication
column_spec=l p{4in}
```

The column spec in this case says the 1st column is left aligned and the 2nd is paragraph wrapped at 4 inches.  The table help is handled by the operator (manual).




