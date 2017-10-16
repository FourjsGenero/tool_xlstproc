
IMPORT XML

MAIN
  DEFINE ok       BOOLEAN
  DEFINE ind      INTEGER
  DEFINE params DYNAMIC ARRAY OF RECORD
                  name  STRING,
                  val   STRING
                  END RECORD
  DEFINE  styleName   STRING
  DEFINE  srcName     STRING
  DEFINE  resultName  STRING
  DEFINE  isHTML      BOOLEAN
  DEFINE  source      xml.DomDocument
  DEFINE  styleSheet  xml.DomDocument
  
  IF num_args()<2 THEN
    DISPLAY "Usage : Xsltproc [option] <stylesheet> <source>"
    DISPLAY "  Options:"
    DISPLAY "    --output file: save to given file"
    DISPLAY "    --param name value: pass a (parameter,value) pair"
    DISPLAY "    --html: the input file is HTML"
    EXIT PROGRAM 1
  ELSE
    # Process command line
    LET ind=1
    WHILE ind <= num_args()
    
      CASE arg_val(ind)
        WHEN "--output"
          LET resultName = arg_val(ind+1)
          LET ind = ind + 2
          
        WHEN "--param"
          CALL params.appendElement()
          LET params[params.getLength()].name = arg_val(ind+1)
          LET params[params.getLength()].val = arg_val(ind+2)
          LET ind = ind + 3
          
        WHEN "--html"
          LET isHTML = TRUE
          LET ind = ind + 1
          
        OTHERWISE
          IF styleName IS NULL THEN
            LET styleName = arg_val(ind)
            LET ind = ind + 1
          ELSE
            IF srcName IS NULL THEN
              LET srcName = arg_val(ind)
              LET ind = ind + 1
            ELSE
              DISPLAY "ERROR: too many parameters"
              EXIT PROGRAM 1
            END IF
          END IF
      END CASE
    END WHILE
    
    # Load StyleSheet
    TRY
      LET styleSheet = xml.DomDocument.Create()
      CALL styleSheet.load(styleName)
    CATCH
      DISPLAY "Error: unable to load stylesheet",styleName
      EXIT PROGRAM 1
    END TRY

    # Load Source 
    TRY
      LET source = xml.DomDocument.Create()
      IF isHTML THEN
        CALL source.setFeature("enable-html-compliancy",TRUE)
      END IF
      CALL source.load(srcName)
    CATCH
      DISPLAY "Error : unable to load source from ",srcName
      EXIT PROGRAM 1
    END TRY
    
    LET ok = RunXSLP(params, styleSheet, source, resultName)
    
    IF NOT OK THEN
      DISPLAY "Error: failed"
      EXIT PROGRAM 1
    ELSE
      DISPLAY "Done"
      EXIT PROGRAM
    END IF
  END IF
END MAIN

FUNCTION RunXSLP(params,styleSheet,source,ret)
  DEFINE ret            STRING
  DEFINE ind            INTEGER
  DEFINE xslt           xml.XSLTTransformer
  DEFINE styleSheet     xml.DomDocument
  DEFINE source         xml.DomDocument
  DEFINE result         xml.DomDocument
  DEFINE params         DYNAMIC ARRAY OF RECORD
                          name  STRING,
                          val   STRING
                        END RECORD

  
  # Create XSLT transformer
  TRY
    LET xslt = xml.XSLTTransformer.CreateFromDocument(styleSheet)
    FOR ind=1 TO xslt.getErrorsCount()
      DISPLAY "StyleSheet error #"||ind||" : ",xslt.getErrorDescription(ind)
    END FOR
  CATCH
    DISPLAY "Error : unable to create XSLT transformer from ",styleSheet
    RETURN FALSE
  END TRY

  # Set literal parameters
  FOR ind=1 TO params.getLength()
    CALL xslt.setParameter(params[ind].name, "'" || params[ind].val || "'")
  END FOR

  
  # Execute XSLT 
  TRY
    LET result = xslt.doTransform(source)
    FOR ind=1 TO xslt.getErrorsCount()
      DISPLAY "Error #"||ind||" : ",xslt.getErrorDescription(ind)
    END FOR    
  CATCH
    DISPLAY "Error : unable to apply XSLT stylesheet"
    FOR ind=1 TO xslt.getErrorsCount()
      DISPLAY "Fatal Error #"||ind||" : ",xslt.getErrorDescription(ind)
    END FOR
    RETURN FALSE
  END TRY
  
  # Save resulting   
  TRY
    IF ret IS NULL THEN
      DISPLAY result.saveToString()
    ELSE
      CALL result.save(ret)
    END IF
  CATCH
    DISPLAY "Error : unable to save result"
    RETURN FALSE
  END TRY
  
  RETURN TRUE
END FUNCTION


