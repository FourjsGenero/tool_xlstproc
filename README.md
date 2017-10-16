# Xsltproc - XSL Processor
Xsltproc converts one xml file to another using GWS XSLT apis.<br/>
Xsltproc program is a replacement of fglxslp tool which was provided in Genero Application Server.<br/>

## Prerequisities
- Genero Business Language 3.10

## Usage
- Compile and run
```
Usage : Xsltproc [option] <stylesheet> <source>
  Options:
    --output file: save to given file
    --param name value: pass a (parameter,value) pair
    --html: the input file is HTML
```
```
fglrun Xsltproc data.xsl data.xml
```
```
fglrun Xsltproc --output data.html data.xsl data.xml
```