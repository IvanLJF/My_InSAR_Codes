;-
;- Read my own files.
;- Type can be any one of the followings:
;- plist, v, dh, vdh, arcs, dvddh, ptattr, ptstruct
;-
;-
;- Read my own files.
;- Type can be any one of the followings:
;- plist, v, dh, vdh, arcs, dvddh, ptattr, ptstruct
;-

FUNCTION TLI_READMYFILES, inputfile, type=type,gamma=gamma


  COMPILE_OPT idl2
  ON_ERROR,2
  
  IF NOT file_test(inputfile) THEN Message, 'File does not exist:'$
    +STRING(13B)+inputfile
    
  type_c=STRLOWCASE(type)
  Case type_c OF
    'plist': BEGIN
      ; Fcomplex
      Print, 'Plist file Format [1 x n]: Fcomplex'
      result=TLI_READDATA(inputfile, samples=1, format='FCOMPLEX')
    END
    'v': BEGIN
      ; x, y, v(dh)
      Print, 'V file Format [3 x n]: [x, y, v(vdh)]'
      result=TLI_READDATA(inputfile, samples=3, format='DOUBLE')
    END
    'dh': BEGIN
      ; x, y, v(dh)
      Print, 'Dh file Format [3 x n]: [x, y, v(vdh)]'
      result=TLI_READDATA(inputfile, samples=3, format='DOUBLE')
    END
    'vdh': BEGIN
      ; ind, x, y, v, dh
      Print, 'Vdh file Format [5 x n]: [ind, x, y, v, dh]'
      result=TLI_READDATA(inputfile, samples=5, format='DOUBLE')
    END
    'arcs': BEGIN
      ; start_coor, end_coor, (s_ind, e_ind); sind>eind
      Print, 'Arcs file Format [ 3 x n]: start_coor, end_coor, (s_ind, e_ind); sind > eind, fcomplex'
      result=TLI_READDATA(inputfile, samples=3, format='FCOMPLEX')
      
    END
    'dvddh': BEGIN
      ; s_ind, e_ind, dv, ddh, coh, sigma (s_ind > e_ind)
      Print, 'Dvddh file Format [ 6 x n]: s_ind, e_ind, dv, ddh, coh, sigma (s_ind > e_ind), double'
      result= TLI_READDATA(inputfile, samples=6, format='DOUBLE')
    END
    'itab': BEGIN
      Print, 'Itab file format [structure]: m_ind, s_ind, int_ind, mask, valid_m, valid_s, valid_int, valid_nintf, valid_itab'
      ; Master_index, Slave_index, Int_index, Mask
      ; The indices start from 1. We have to convert it to 0.
      nintf=FILE_LINES(inputfile)
      itab=TLI_READTXT(inputfile,/EASY)
      itab=LONG(itab)
;      itab[0:2, *]=itab[0:2, *]-1 ; Keep it original.
      itab=CREATE_STRUCT('m_ind', itab[0 ,*], $
        's_ind', itab[1, *], $
        'int_ind', itab[2, *], $
        'mask', itab[3, *], $
        'nintf', nintf, $
        'itab_all', itab, $
        'm_valid', itab[0, WHERE(itab[3, *])], $
        's_valid', itab[1, WHERE(itab[3, *])], $
        'int_valid',itab[2, WHERE(itab[3, *])], $
        'nintf_valid', LONG(TOTAL(itab[3, *])), $
        'itab_valid', itab[*, WHERE(itab[3, *])])
      RETURN, itab
    END
    'ptattr': BEGIN
      ; lelapt_attr= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B,'accepted', 0B, 'v_acc', 0.0, 'dh_acc', 0.0 )
      result= CREATE_STRUCT('parent',-1L,'steps',0L, 'v', 0D,'dh', 0D, 'weight', 0D, 'calculated', 0B,'accepted', 0B, 'v_acc', 0.0, 'dh_acc', 0.0 )
      bytes=4+4+8+8+8+1+1+4+4 ;(42)
      finfo= FILE_INFO(inputfile)
      npt= finfo.size/bytes
      
      result= REPLICATE(result, npt)
      OPENR, lun, inputfile,/GET_LUN
      READU, lun, result
      FREE_LUN, lun
    END
    'ptstruct': BEGIN
      ; Tile structures of points.
      results= TLI_READDATA(inputfile, lines=1, fomrat='LONG')
    END
    
    
    ELSE: BEGIN
      Message, 'File type not supported!!'
    END
  ENDCASE
  
  RETURN, result
END