;-
;- Purpose:
;-     Count number of arcs in the arcsfile.
;
FUNCTION TLI_ARCNUMBER, arcsfile, arcs=arcs, dvddh=dvddh, vdh=vdh
  finfo= FILE_INFO(arcsfile)
  CASE 1 OF 
    KEYWORD_SET(dvddh): BEGIN
      narcs=finfo.size/(6D*8D)
    END
    KEYWORD_SET(vdh): BEGIN
      narcs=finfo.size/(5D*8D)
    END
    ELSE: BEGIN
      Print, 'Arcs files are organized as follows:'+STRING(13b)+'[COMPLEX(startcorr) , COMPLEX(endcorr), COMPLEX(startind, endind)]'
      narcs= finfo.size/24D
    END
  ENDCASE

  RETURN, narcs
END