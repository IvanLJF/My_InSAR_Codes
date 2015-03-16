;- 
;- Script that:
;-   Calculate perpendicular baseline and look angle for each PS
;-   First please call base_all.sh to generate all base files.
;- e.g.

PRO TLI_GAMMA_BP_LA
  workpath='/mnt/software/myfiles/Software/experiment/TSX_PS_Tianjin_121023'
  workpath=workpath+PATH_SEP()
  hpapath=workpath+'HPA'
  hpapath=hpapath+PATH_SEP()
  ptfile= hpapath+'plistupdate'
  itabfile= workpath+'itab'
  slctabfile= workpath+'SLC_tab'
  basepath=hpapath+'base'
  
  ; Outputfile
  pbasefile=ptfile+'.pbase'
  plafile=ptfile+'.pla'
  TLI_GAMMA_BP_LA_FUN, ptfile, itabfile, slctabfile, basepath, pbasefile, plafile
END