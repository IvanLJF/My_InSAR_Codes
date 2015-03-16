;-
;- This is a class defined for slc file.
;-  
;- Structures for this class:
;-   finfo
;-   partinfo
;- Operations for this class:
;-   Define
;-   Init
;-   Set
;-   Get
;-   Partition
;-   Partrange
;-   Read
;-
;- Written By:
;-   T.LI @ ISEIS, 20131114
;-

@tli_ptr_valid

;-----------------------------------------------------
FUNCTION SLC::READ, part=part, roff=roff, nr=nr, loff=loff, nl=nl
  ; Read the specified data from the whole image.
  ; The information have to be loaded first.
  finfo=*(self.finfo)
  fname=finfo.filename
  samples=finfo.range_samples
  format=STRLOWCASE(finfo.image_format)
  lines=finfo.azimuth_lines
  fbytes=(FILE_INFO(fname)).size
  fMB=ROUND(fbytes/1024.0/1024.0)
  
  ; Read the whole image
  IF N_ELEMENTS(part) EQ 0 THEN BEGIN
    IF KEYWORD_SET(roff)+KEYWORD_SET(nr)+KEYWORD_SET(loff)+KEYWORD_SET(nl) EQ 0 THEN BEGIN
      Print, 'Warning: The whole image will be loaded.'
      Print, 'Memory to occupy (MB):'+STRCOMPRESS(fMB)
      roff=0
      nr=samples
      loff=0
      nl=lines
    ENDIF
  ENDIF
  
  ; Read partial image. The ranges are defined using the function TLI_PARTITION_DATA
  IF N_ELEMENTS(part) NE 0 THEN BEGIN
    IF NOT PTR_VALID(self.partinfo) THEN BEGIN
      Message, 'Error: No partation info. detected. Please part the image using SLC->partition'
    ENDIF
    
    ; Get the partial range.
    range=self->PARTRANGE(part=part)
    roff=range[0]
    nr=range[1]
    loff=range[2]
    nl=range[3]
  ENDIF
  
  ; Call TLI_SUBSETDATA() to read the partial data from the whole image scene.
  infile=fname
  ss=samples
  ls=lines
  soff=roff
  ns=nr
  loff=loff
  nl=nl
  IF format EQ 'scomplex' THEN sc=1
  IF format EQ 'fcomplex' THEN fc=1
  IF format EQ 'float' THEN float=1
  swap_endian=1
  result=TLI_SUBSETDATA(infile, ss, ls,  soff, ns, loff,nl, $
                      float=float,sc=sc,fc=fc,int=int,long=long,swap_endian=swap_endian)
  RETURN, result
END
;-----------------------------------------------------
PRO SLC::PARTITION, border_s=border_s,border_l=border_l, $
    nblocks=nblocks,nblocks_s=nblocks_s, nblocks_l=nblocks_l,block_samples=block_samples, block_lines=block_lines
    
  finfo=self->GET() ; Extract the file info
  inputfile=finfo.filename
  samples=finfo.range_samples
  format=finfo.image_format
  *(self.partinfo)=TLI_PARTITION_DATA( inputfile, samples=samples, lines=lines, format=format, border_s=border_s,border_l=border_l, $
    nblocks_all=nblocks_all,nblocks_s=nblocks_s, nblocks_l=nblocks_l,block_samples=block_samples, block_lines=block_lines)
    
END
;-----------------------------------------------------
FUNCTION SLC::PARTRANGE, part=part
  ; Return the range info for the specified part of the input data.  
  partinfo=*(self.partinfo)
  IF NOT PTR_VALID(self.partinfo) THEN BEGIN
    Message, 'No partation info. detected. Please part the image using SLC->partition'
  ENDIF
  
  IF part GT partinfo.nblocks_all THEN Message, 'Error: Part index is greater than the part number'+STRCOMPRESS(partinfo.nblocks_all)+':'+STRCOMPRESS(part)
  
  startx_part=partinfo.startx[part]
  starty_part=partinfo.starty[part]
  endx_part=partinfo.endx[part]
  endy_part=partinfo.endy[part]
  result=[startx_part, endx_part-startx_part+1, starty_part, endy_part-starty_part+1]
  Print, 'Returning: [roff nr loff nl]'
  RETURN, result
END

;-----------------------------------------------------
PRO SLC::Set,inputfile

  temp=TLI_LOAD_SLC_PAR(inputfile+'.par')
  *(self.finfo)=temp
  RETURN
  
END
;-----------------------------------------------------
FUNCTION SLC::GET, partinfo=partinfo
  ;-   partinfo   : Return partation information.
  
  IF TLI_PTR_VALID(self.finfo) THEN finfo=*(self.finfo)
  IF TLI_PTR_VALID(self.partinfo) THEN partinfo=*(self.partinfo)
  RETURN, finfo
END
;-----------------------------------------------------
FUNCTION SLC::INIT

  ; Do nothing - This will cause Error: Unable to dereference NULL pointer: <POINTER (<Null Pointer>)>
  self.finfo=PTR_NEW(/allocate)
  self.partinfo=PTR_NEW(/allocate)
  RETURN, 1
END
;-----------------------------------------------------
PRO SLC::Cleanup
  ;- Free the pointer
  ptr_free, self.finfo, self.partinfo
  return
END
;-----------------------------------------------------
PRO SLC__DEFINE
  ; Return information:
  ;- finfo         : The file header loaded from .slc.par file.
  ;- partinfo      : The partation information calculated from the given params
  ;- partrange     : [roff nr loff nl] for the specified part of the data.
  
  void= {slc, finfo:PTR_NEW(), partinfo:PTR_NEW()}
  
  RETURN
  
END