PRO TXT2KML, txtfile, kmlfile=kmlfile
  IF ~KEYWORD_SET(txtfile) THEN Message, 'TXT2KML: Usage: TXT2KML, txt, kml=kml'
  points_file=txtfile
  nlines= FILE_LINES(points_file)
  
  Names=''
  Coors=DBLARR(2)
  OPENR, lun, points_file,/GET_LUN
  For i=0, nlines-1 DO BEGIN
    temp=''
    READF, lun, temp
    temp= STRSPLIT(temp,/EXTRACT)
    Names=[[Names], [temp[0]]]
    Coors=[[Coors], [DOUBLE(temp[1:2])]]
  ENDFOR
  Names= Names[*, 1:*]
  Coors= Coors[*, 1:*]
  Coors= [Coors, DBLARR(1, nlines)]
  
  IF ~KEYWORD_SET(kmlfile) THEN BEGIN
    temp= STRSPLIT(txtfile, '.', /EXTRACT)
    kmlfile= temp[0]+'.kml'
  ENDIF
  I_err=Open_KML(kmlfile,I_Unit)  
  Begin_Folder_KML, I_Unit
  For i=0, nlines-1 DO BEGIN
    Point_KML, I_Unit, Coors[*, i], Name=Names[i],Time=SYSTIME(), Descri='This is:'+Names[i]
  ENDFOR
  Lookat_KML, I_Unit,Coors[*, 0]
  I_Color=Color_KML(60., 0., 100.,Transparency='55')
  End_Folder_KML, I_Unit
  
  Close_KML,  I_Unit
  
END