;===============================================================================
; kml.pro
;   KML output package for IDL
;
;     2006-10-30 Saito-A
;
; CHANGE
;   2006-12-15 Saito-A: Clean-up. Cube_KML is added.
;   2006-12-27 nobuyuki: add Normal in Plygon_KML & Cube_KML
;   2007-02-18 Saito-A: Satellite_KML, Map_KML & Arrow_KML are added.
;   2007-02-22 Saito-A: Satellite_KML, Map_KML bugs are fixed.
;   2007-03-02 Saito-A: "no_mark" is added in Arrow_KML
;   2007-06-01 Saito-A: Polygon_KML, "S_Time" & "E_Time" are added.
;   2007-06-04 Saito-A: Satellite_KML, "S_Time" & "E_Time" are added.
;               2008-01-17 Saito-A: Color_KML, RGB colors are added.
;                       Close_KML, "Free_LUN" is added.
;                       Map_KML, use Write_PNG for Transparent image
;   2008-01-20 Saito-A: Map_KML_M: for monthly map from "clouds"
;           Arrow_KML: Car2pol version from "NICT_RTmodel"
;   2008-09-20 Polygon_KML: Extrude is added.
;   2008-09-20 Saito-A: Colorbar_KML: Make color bar for color plot
;
;
;===============================================================================
;===============================================================================
Function  Open_KML, File_Name, File_Unit
  ;===============================================================================
  ; Open KML file
  ;
  ; Input: KML file name
  ; Output: File Unit Number
  ; Return: File Open Status
  ; Usage:
  ;       I_err=Open_KML('test.kml',I_Unit)
  ;
  ;   2006-10-30 Saito-A
  ;
  ;-------------------------------------------------------------------------------
  openw,File_Unit,File_Name, ERR=error_ID, /GET_LUN
  Error_ID=0
  
  printf, File_Unit, '<?xml version="1.0" encoding="UTF-8"?> '
  printf, File_Unit, '<kml xmlns="http://earth.google.com/kml/2.0"> <Document>'
  
  return, Error_ID
  
end

;===============================================================================
Pro  Close_KML, File_Unit
  ;===============================================================================
  ; Close KML file
  ;
  ; Input: File Unit Number
  ; Usage:
  ;        Close_KML,  I_Unit
  ;
  ;   2006-10-30 Saito-A
  ;
  ;-------------------------------------------------------------------------------

  printf, File_Unit,  '</Document> </kml>'
  close, File_Unit
  free_lun, File_Unit
  
end

;===============================================================================
Pro  Style_KML,  File_Unit, Style_Name,  $
    Style_iconcolor=Style_iconcolor, Style_iconscale=Style_iconscale,$
    Style_iconhref=Style_iconref,Style_labelcolor=Style_labelcolor
  ;===============================================================================
  printf, File_Unit,  '<Style id="'+Style_Name+'">'
  IF NOT KEYWORD_SET(Style_iconcolor) THEN Style_iconcolor='ff0000ff' ; Omitted color: red,opacity
  IF NOT KEYWORD_SET(Style_iconscale) THEN Style_iconscale=1.4
  IF NOT KEYWORD_SET(Style_iconhref) THEN Style_iconhref='http://maps.google.com/mapfiles/kml/shapes/shaded_dot.png'
  IF NOT KEYWORD_SET(Style_labelcolor) THEN Style_labelcolor='ccffffff'
  PrintF, file_unit, '  <IconStyle>'
  PrintF, file_unit, '    <color>'+Style_iconcolor+'</color>'
  PrintF, file_unit, '    <scale>'+STRCOMPRESS(Style_iconscale,/remove_all)+'</scale>'
  PrintF, file_unit, '    <Icon>'
  PrintF, file_unit, '      <href>'+Style_iconhref+'</href>'
  PrintF, file_unit, '    </Icon>'
  PrintF, file_unit, '  </IconStyle>'
  PrintF, file_unit, '  <LabelStyle>'
  PrintF, file_unit, '    <color>'+Style_labelcolor+'</color>'
  PrintF, file_unit, '  </LabelStyle>'
  printf, File_Unit,  '</Style>'
end


;===============================================================================
Pro  Begin_Folder_KML,  File_Unit, NAME=Name, TIME=Time
  ;===============================================================================
  ; Begin Foler in KML file
  ;
  ; Input: File Unit Number
  ;       Input(Optional)
  ;              Name: Name of Folder [String]
  ;        Time: Time in KML format e.g., "2006-12-15T17:00:25Z"
  ; Usage:
  ;        Begin_Folder_KML, I_Unit
  ;        Begin_Folder_KML, I_Unit, Name='Folder 1'
  ;        Begin_Folder_KML, I_Unit, Name='Folder 1', Time='2006-12-15'
  ;
  ;   2006-10-30 Saito-A
  ;
  ;-------------------------------------------------------------------------------
  ;-------------------------------------------------------------------------------
  Default_Name='Folder'
  if KEYWORD_SET(Name) EQ 0 then Name=Default_Name
  ;-------------------------------------------------------------------------------
  
  printf, File_Unit,  '<Folder><name> '+Name+' </name>'
  if KEYWORD_SET(Time) then printf, File_Unit,  '<TimeStamp><when>'+Time+'</when></TimeStamp>'
  
end

;===============================================================================
Pro  End_Folder_KML, File_Unit
  ;===============================================================================
  ; End Foler in KML file
  ;
  ; Input: File Unit Number & Folder Name
  ; Usage:
  ;        End_Folder_KML, I_Unit
  ;
  ;   2006-10-30 Saito-A
  ;
  ;-------------------------------------------------------------------------------

  printf, File_Unit,  '</Folder>'
  
end

;===============================================================================
Pro  LookAt_KML,  File_Unit, Point, NAME=Name
  ;===============================================================================
  ;
  ; Google Earth "LookAt" output for Given Location[Lat, Long, Alt[km]]
  ;
  ; Input: File_Unit: File Unit Number
  ;        Location: [Lat, Long, Alt[km]]
  ;       Input(Optional)
  ;              Name: Name of LookAt Point [String]
  ; Usage:
  ;         Lookat_KML, I_Unit,[35., 135., 100.]
  ;         Lookat_KML, I_Unit,[35., 135., 100.], Name='point'
  ;
  ;   2006-10-30 Saito-A
  ;
  ;-------------------------------------------------------------------------------
  Default_Name='LookAt'
  if KEYWORD_SET(Name) EQ 0 then Name=Default_Name
  ;-------------------------------------------------------------------------------
  
  Location=Point
  
  Min_Alt_km=10.
  TILT=45.
  HEADING=0.
  
  if Location(1) GE 180. then Location(1)=Location(1)-360.
  if Location(2) LE Min_Alt_km then Location(2)=Min_Alt_km
  
  printf, File_Unit,  '<Placemark> <name>'+Name+'</name>'
  printf, File_Unit,  "<LookAt><longitude>"+string(Location(1))+$
    "</longitude><latitude>"+string(Location(0))+$
    "</latitude><altitude>0</altitude><range>"+$
    string(Location(2)*1000.)+"</range> <tilt>"+string(TILT)+$
    "</tilt><heading>"+string(HEADING)+$
    "</heading></LookAt></Placemark>"
end


;===============================================================================
Pro  Point_KML,  File_Unit, Point, NAME=Name, TIME=time, S_TIME=s_time, E_TIME=e_time, DESCRI=Descri, STYLE_NAME=Style_Name
  ;===============================================================================
  ;
  ; Google Earth "Point" output for Given Point[Lat, Long, Alt[km]]
  ;
  ; Input: File_Unit: File Unit Number
  ;        Point: [Lat, Long, Alt[km]]
  ;       Input(Optional)
  ;              Name: Name of Point [String]
  ;        Time: Time in KML format e.g., "2006-12-15T17:00:25Z"
  ;        S_Time: Start Time in KML format e.g., "2006-12-15T17:00:25Z"
  ;        E_Time: End Time in KML format e.g., "2006-12-15T17:00:25Z"
  ;        Descri: Description of the Point shown in "Baloon"
  ;        Style_Name: Name of Style ID, which is specifed Style_KML
  ; Usage:
  ;   Point_KML,  I_Unit, [35., 135., 100.]
  ;   Point_KML,  I_Unit, [35., 135., 100.], Name='point1'
  ;
  ;
  ;   2006-10-30 Saito-A
  ;
  ;-------------------------------------------------------------------------------
  Default_Name=''
  if KEYWORD_SET(Name) EQ 0 then Name=Default_Name
  ;-------------------------------------------------------------------------------
  
  Location=Point
  
  if Location(1) GE 180. then Location(1)=Location(1)-360.
  
  printf, File_Unit,  '<Placemark> <name>'+Name+'</name>'
  if KEYWORD_SET(Descri) then printf, File_Unit, '<description>'+Descri+'</description>'
  if KEYWORD_SET(Time) then printf, File_Unit,  '<TimeStamp><when>'+Time+'</when></TimeStamp>'
  if KEYWORD_SET(S_Time) then begin
    printf, File_Unit,  '<TimeSpan><begin>'+S_Time+'</begin>'
    if KEYWORD_SET(E_Time) then printf, File_Unit,  '<end>'+E_Time+'</end>'
    printf, File_Unit,  '</TimeSpan>'
  endif
  if KEYWORD_SET(Style_Name) then printf, File_Unit, '<styleUrl>#'+Style_Name+'</styleUrl>'
  printf, File_Unit,  "<Point><coordinates>"+STRCOMPRESS(STRJOIN([location(1), location[0], location[2]], ','),/REMOVE_ALL)+$
    "</coordinates>" +$
    "<altitudeMode>absolute</altitudeMode>"+$
    ;   "<extrude>1</extrude>"+$
    "</Point></Placemark>"
    
end

;===============================================================================
Pro  Line_KML,  File_Unit, Line, NAME=Name, Color=Color, Width=Width, S_TIME=s_time, E_TIME=e_time, TIME=Time
  ;===============================================================================
  ;
  ; Google Earth "Line" output for Given Line (3, *)
  ;
  ; Input: File_Unit: File Unit Number
  ;        Line: (3, *), ([Lat, Long, Alt[km]], *)
  ; Input(Optional)
  ;        Name: Name of Line [String]
  ;        Color: Color in KML format, #TTBBGGRR
  ;        Time: Time in KML format e.g., "2006-12-15T17:00:25Z"
  ; Usage:
  ;        Line=[[33.8, 133.8, 2.],[33.9, 133.9, 2.]]
  ;        Line_KML, I_Unit, Line
  ;        Line_KML, I_Unit, Line, Name='Line'
  ;        Line_KML, I_Unit, Line, Name='Line', Color='5500ff00', Width=3
  ;
  ;   2006-10-30 Saito-A
  ;
  ;-------------------------------------------------------------------------------
  Default_Color='5500ff00'
  Default_Name='Line'
  Default_Width=3
  if KEYWORD_SET(Name) EQ 0 then Name=Default_Name
  if KEYWORD_SET(Color) EQ 0 then Color=Default_Color
  if KEYWORD_SET(Width) EQ 0 then Width=Default_Width
  ;-------------------------------------------------------------------------------
  Num_Point=N_elements(Line(0,*))
  
  printf, File_Unit,  '<Placemark> <name>'+Name+'</name>'
  if KEYWORD_SET(S_Time) then begin
    printf, File_Unit,   '<TimeSpan><begin>'+S_Time+'</begin>'
    if KEYWORD_SET(E_Time) then printf, File_Unit,   '<end>'+E_Time+'</end>'
    printf, File_Unit,   '</TimeSpan>'
  endif
  if KEYWORD_SET(Time) then printf, File_Unit,  '<TimeStamp><when>'+Time+'</when></TimeStamp>'
  printf, File_Unit,  '<Style> <LineStyle> <color>'+COLOR+'</color>'
  printf, File_Unit,  '<width>'+string(Width,format='(i)')+'</width>'
  printf, File_Unit,  '</LineStyle> </Style>'
  printf, File_Unit,  '<LineString> <tessellate>1</tessellate>'
  ;        printf, File_Unit,  '<altitudeMode>relativeToGround</altitudeMode>'
  printf, File_Unit,   '<altitudeMode>absolute</altitudeMode>'
  printf, File_Unit,  '<coordinates>'
  
  for I_Point=0, Num_Point-1 do begin
    if Line(1,I_Point) GE 180. then Line(1,I_Point)=Line(1,I_Point)-360.
    printf, File_Unit,   Line(1, I_Point),', ',  Line(0, I_point),$
      ', ', Line(2, I_point)*1000.
  endfor
  
  printf, File_Unit,  '</coordinates> </LineString> </Placemark>'
  
end

;===============================================================================
Pro  Polygon_KML, File_Unit, Polygon, NAME=Name, Color=Color, S_TIME=s_time, E_TIME=e_time, TIME=Time, Normal=Normal, Extrude=Extrude,$
                  Absolute=Absolute, Description=Description
  ;===============================================================================
  ;
  ; Google Earth "Polygon" output for Given Polygon (3, *)
  ;
  ; Input: File_Unit: File Unit Number
  ;        Polygon: (3, *), ([Lat, Long, Alt[km]], *)
  ; Input(Optional)
  ;        Name        : Name of Polygon [String]
  ;        Color       : Color in KML format, #TTBBGGRR
  ;        Time        : Time in KML format e.g., "2006-12-15T17:00:25Z"
  ;        Normal      : direction of Normal ( 1 or -1 )
  ;        Description : Description of the KML file.
  ; Input Keyword (Optional)
  ;   Extrude
  ;   Absolute : Using Absolute height (Using relative 0 if not set.)
  ;
  ; Usage:
  ;  Polygon=[[35., 135., 3.], [35, 134, 3.], [34., 134., 3.],[34, 135, 3.]]
  ;  Polygon_KML, I_Unit, Polygon
  ;  Polygon_KML, I_Unit, Polygon, Name='poly', Color='55ff0000'
  ;
  ;   2006-10-30 Saito-A
  ;   2006-12-27 nobuyuki add Normal
  ;   2014-09-09 T.LI add description.
  ;
  ;-------------------------------------------------------------------------------
  Default_Color='5500ff00'
  Default_Name='Polygon'
  Default_Normal=1
  if KEYWORD_SET(Color) EQ 0 then Color=Default_Color
  if KEYWORD_SET(Name) EQ 0 then Name=Default_Name
  if KEYWORD_SET(Normal) EQ 0 then Normal=Default_Normal
  IF NOT KEYWORD_SET(description) THEN description=''
  ;-------------------------------------------------------------------------------
  Num_Point=N_elements(Polygon(0,*))
  
  IF NOT KEYWORD_SET(absolute) THEN polygon[2, *]=0
  
  printf, File_Unit,  '<Placemark> <name>'+Name+'</name>'
  PrintF, file_unit, '<description>'+description+'</description>'
  ;... TIME ...
  if KEYWORD_SET(Time) then printf, File_Unit,  '<TimeStamp><when>'+Time+'</when></TimeStamp>'
  if KEYWORD_SET(S_Time) then begin
    printf, File_Unit,  '<TimeSpan><begin>'+S_Time+'</begin>'
    if KEYWORD_SET(E_Time) then printf, File_Unit,  '<end>'+E_Time+'</end>'
    printf, File_Unit,  '</TimeSpan>'
  endif
  ;............
  printf, File_Unit,   '<Style><PolyStyle> '
  printf, File_Unit,   '<color>'+COLOR+'</color> '
  printf, File_Unit,   '<outline>0</outline></PolyStyle></Style> '
  
  IF KEYWORD_SET(absolute) THEN BEGIN
    printf, File_Unit,   '<Polygon> <altitudeMode>absolute</altitudeMode> '
  ENDIF ELSE BEGIN
    PrintF, File_Unit, '<Polygon> <altitudeMode>relative</altitudeMode> '
  ENDELSE
  
  if KEYWORD_SET(Extrude) then begin
    printf, File_Unit,   '<extrude>1</extrude>'
  endif
  printf, File_Unit,   '<outerBoundaryIs> <LinearRing> <coordinates> '
  
  strs=STRARR(1, num_point)
  FOR i=0, num_point-1 DO BEGIN
    strs[0,i]=STRCOMPRESS(STRJOIN([polygon[1, i], polygon[0, i], polygon[2, i]], ','),/REMOVE_ALL)  
  ENDFOR
  strs=strs[0:*]
  strs=STRJOIN(strs, ' ')
  PrintF, file_Unit, strs
  
;  if ( Normal EQ 1 ) then begin
;    for I_Point=0, Num_Point-1 do begin
;      printf, File_Unit,   Polygon(1,I_point),", ", $
;        Polygon(0, I_point),", ", Polygon(2, I_point)*1000.
;    endfor
;  endif else begin
;    if (Normal EQ -1) then begin
;      for I_Point=Num_Point-1, 0, -1 do begin
;        printf, File_Unit,   Polygon(1,I_point),", ", $
;          Polygon(0, I_point),", ", Polygon(2, I_point)*1000.
;      endfor
;    endif
;  endelse
  
  printf, File_Unit,   '</coordinates> </LinearRing>'
  printf, File_Unit,   '</outerBoundaryIs> </Polygon> '
  printf, File_Unit,   '</Placemark> '
end

;===============================================================================
Pro  Cube_KML,  File_Unit, Center, Width=Width, Name=Name, Color=Color, TIME=Time
  ;===============================================================================
  ;
  ; Google Earth "Cube" output for Given Location (3)
  ;
  ; Input:
  ;        File_Unit: File Unit Number
  ;        Center: [Lat, Long, Alt[km]]
  ; Input(Optional)
  ;        Width: Size of Cube in [Lat, Long, Alt[km]]
  ;        Name: Name of Cube [String]
  ;        Color: Color in KML format, #TTBBGGRR
  ;        Time: Time in KML format e.g., "2006-12-15T17:00:25Z"
  ; Usage:
  ;  Center=[35., 135.,100.]
  ;  Cube_KML, I_Unit,Center
  ;  Cube_KML, I_Unit,Center,Width=[0.5,1,.1.],Name='Name',Color='5500ff00'
  ;
  ;   2006-12-15 Saito-A
  ;   2006-12-27 nobuyuki add Normal
  ;
  ;-------------------------------------------------------------------------------
  Surface=fltarr(3,4)
  ID=indgen(3)
  ;-------------------------------------------------------------------------------
  Default_Width=[1., 1., 100.]
  Default_Color='5500ff00'
  Default_Name='Cube'
  if KEYWORD_SET(Width) EQ 0 then Width=Default_Width
  if KEYWORD_SET(Color) EQ 0 then Color=Default_Color
  if KEYWORD_SET(Name) EQ 0 then Name=Default_Name
  ;-------------------------------------------------------------------------------
  
  Begin_Folder_KML, File_Unit, Name=Name
  if KEYWORD_SET(Time) then printf, File_Unit,  '<TimeStamp><when>'+Time+'</when></TimeStamp>'
  ;------
  for I_POS_NEG=-1, 1, 2 do begin
    for I_surface=0, 3-1 do begin
      for I_Corner=0, 3, 3 do Surface(ID(0),I_Corner)=Center(ID(0))-Width(ID(0))/2.
      for I_Corner=1, 2 do Surface(ID(0),I_Corner)=Center(ID(0))+Width(ID(0))/2.
      for I_Corner=0, 1 do Surface(ID(1),I_Corner)=Center(ID(1))-Width(ID(1))/2.
      for I_Corner=2, 3 do Surface(ID(1),I_Corner)=Center(ID(1))+Width(ID(1))/2.
      for I_Corner=0, 3 do Surface(ID(2),I_Corner)=Center(ID(2))+I_POS_NEG*Width(ID(2))/2.
      Polygon_KML, File_Unit, Surface, Color=Color, Normal=-1*I_POS_NEG
      ID=shift(ID,1)
    endfor
  endfor
  ;------
  End_Folder_KML, File_Unit
  
end

;===============================================================================
Function  Color_KML, Value, Min_Value, Max_Value, COLOR_TB=Color_Tb, TRANSPARENCY=Transparency,Colors=Colors
  ;===============================================================================
  ;
  ;       Make Color string for Google Earth
  ;
  ; Input:
  ;   Value: Value for setting color
  ;   Min_Value: Value for the minimum: Blue
  ;   Max_Value: Value for the maximum: Red
  ; Input(Optional)
  ;   Color_Tb: Color Table Number
  ;           =1: Rainbow
  ;           =2: Blue-Red
  ;           =3: Black-White
  ;           =4: Red-White
  ;           =5: Green-White
  ;           =6: Blue-White
  ;   Transparency: Transparency [2digit]:from 00 to ff (ff is opaque)
  ;   Colors: The colors to use. 3 columns containing [R G B]
  ; Return: Color code in KML format, #TTBBGGRR
  ; Usage:
  ;   I_Color=Color_KML(60., 0., 100.)
  ;   I_Color=Color_KML(60., 0., 100., Transparency='55')
  ;   I_Color=Color_KML(60., 0., 100., Color_TB=2, Transparency='55')
  ;
  ;               2006-04-01 Saito-A
  ;
  ;-------------------------------------------------------------------------------
  IF NOT KEYWORD_SET(colors) THEN BEGIN
    Default_Color_Tb=1
    Default_Transparency='ff'
    if KEYWORD_SET(Color_TB) EQ 0 then Color_TB=Default_Color_TB
    if KEYWORD_SET(Transparency) EQ 0 then Transparency=Default_Transparency
    ;-------------------------------------------------------------------------------
    
    ;-------------------------------------------------------------------------------
    case Color_Tb of
      1: begin
        RED=  [0, 255,   0,   0, 255, 255]
        GREEN=[0,   0,   0, 255, 255,   0]
        BLUE= [0, 255, 255,   0,   0,   0]
        dum_arr=[0,10,30,110,170,255]
        RED=Interpol(RED, dum_arr, indgen(256))
        GREEN=Interpol(GREEN, dum_arr, indgen(256))
        BLUE=Interpol(BLUE, dum_arr, indgen(256))
      end
      2: begin
        RED=[0,255]
        GREEN=[0,0]
        BLUE=[255,0]
      end
      3: begin
        RED=[0,255]
        GREEN=[0,255]
        BLUE=[0,255]
      end
      4: begin
        RED= [0, 130, 255,   255,   255]
        GREEN=[0, 0, 148, 154,   255]
        BLUE=  [0, 0, 0, 0,  255]
        dum_arr=[0, 96, 188, 192, 255]
        RED=Interpol(RED, dum_arr, indgen(256))
        GREEN=Interpol(GREEN, dum_arr, indgen(256))
        BLUE=Interpol(BLUE, dum_arr, indgen(256))
      end
      5: begin
        RED=[0, 0, 148, 154,   255]
        GREEN= [0, 130, 255,   255,   255]
        BLUE=  [0, 0, 0, 0,  255]
        dum_arr=[0, 96, 188, 192, 255]
        RED=Interpol(RED, dum_arr, indgen(256))
        GREEN=Interpol(GREEN, dum_arr, indgen(256))
        BLUE=Interpol(BLUE, dum_arr, indgen(256))
      end
      6: begin
        RED=  [0, 0, 0, 0,  255]
        GREEN=[0, 0, 148, 154,   255]
        BLUE= [0, 130, 255,   255,   255]
        dum_arr=[0, 96, 188, 192, 255]
        RED=Interpol(RED, dum_arr, indgen(256))
        GREEN=Interpol(GREEN, dum_arr, indgen(256))
        BLUE=Interpol(BLUE, dum_arr, indgen(256))
      end
      else: begin
        RED=[0,255]
        GREEN=[0,0]
        BLUE=[255,0]
      end
    endcase
    ;-------------------------------------------------------------------------------
    
    ;-------------------------------------------------------------------------------
    Num_Level=256
    RED=Interpol(RED, num_Level)
    GREEN=Interpol(GREEN, num_Level)
    BLUE=Interpol(BLUE, num_Level)
  ENDIF ELSE BEGIN
    Num_Level=256
    RED=colors[0,*]
    GREEN=colors[1, *]
    BLUE=colors[2, *]
  ENDELSE
  ;-------------------------------------------------------------------------------
  
  ;-------------------------------------------------------------------------------
  RATIO=(float(Value)-float(Min_Value))/(float(Max_Value)-float(Min_Value))
  
  if RATIO GT 1. then RATIO=1.
  if RATIO LT 0. then RATIO=0.
  
  I_COLOR=fix(RATIO * (Num_Level-1))
  COLOR=string(BLUE(I_COLOR),GREEN(I_COLOR),RED(I_COLOR),format='(3z2.2)')
  ;-------------------------------------------------------------------------------
  
  return, TRANSPARENCY+COLOR
end


;===============================================================================
Pro Satellite_KML, File_Unit, Year, Month, Day, Time, Lat, Lon, Alt, Plot_Data, Min_V=Min_V, Max_V=Max_V, BAD_DATA=BAD_DATA, Plot_Interval=Plot_Interval, Name=Name, Alt_Plot=Alt_Plot
  ;===============================================================================
  ;
  ;       Plot Satellite data on KML
  ;
  ; Input:
  ;   Year, Month, Day:
  ;   Time: Time of data in Hours in the day: float(Num_Data)
  ;   Lat, Lon, Alt:  Location of data: float(Num_Data)
  ;   Plot_Data: Data array: float(Num_Data)
  ; Input(Optional)
  ;   Min_Value: Value for the minimum: Blue
  ;   Max_Value: Value for the maximum: Red
  ;   BAD_DATA: Be not plotted.
  ;   Plot_Interval: Plot every "Plot_Interval" data
  ;   Name: Name of data, used for folder name
  ; Input Keyword(Optional)
  ;   Alt_Plot: Change Altitude according to Data Values
  ;
  ;   2007-02-09 Saito-A
  ;
  ;-------------------------------------------------------------------------------
  ;===============================================================================

  Data_Alt_km=Alt(0)
  Alt_Factor=Data_Alt_km/(Max_V-Min_V)
  
  ;-------------------------------------------------------------------------------
  BAD_DATA_FLAG=1
  if KEYWORD_SET(Min_V) EQ 0 then Min_V=min(Plot_Data)
  if KEYWORD_SET(Max_V) EQ 0 then Max_V=max(Plot_Data)
  if KEYWORD_SET(Plot_Interval) EQ 0 then Plot_Interval=1
  if KEYWORD_SET(Name) EQ 0 then Name='Data'
  if KEYWORD_SET(BAD_DATA) EQ 0 then BAD_DATA_FLAG=0
  ;-------------------------------------------------------------------------------
  
  ;----
  INTERVAL_HOUR=time(Plot_Interval)-time(0)
  ;----
  
  ;--- Set Date strings ---
  DATE=string(format='((I4),"-",(I2.2),"-",(I2.2))',YEAR,MONTH,DAY)
  ;------------------------
  
  ;--- Number of Data  ---
  Num_Data=N_elements(Time)
  ;-----------------------
  
  ;--- Draw Line in KML ---
  Line=fltarr(3,2)
  Begin_Folder_KML, File_Unit,Name=Name+' '+Date
  
  for I_time=0L, Num_Data-1-Plot_Interval, Plot_Interval do begin
  
    if BAD_DATA_FLAG EQ 1 then begin
      if (Plot_Data(I_time) EQ BAD_DATA ) OR (Plot_Data(I_time+Plot_Interval) EQ BAD_DATA) then begin
        goto, SKIP_PLOT
      endif
    endif
    
    
    I_Color=Color_KML(Plot_Data(I_time),min_v, max_v)
    I_Width=8.
    
    Line(0,*)=[lat(I_time), lat(I_time+Plot_Interval)]
    Line(1,*)=[lon(I_time), lon(I_time+Plot_Interval)]
    ;--- Altitude Plot or Normal Plot ---
    if KEYWORD_SET(Alt_Plot) eq 0 then begin
      Line(2,*)=[alt(I_time), alt(I_time+Plot_Interval)]
    endif else begin
      Line(2,*)=[alt(I_time)+(Plot_Data(I_time)-min_v)*Alt_Factor, alt(I_time+Plot_Interval)+(Plot_Data(I_time+Plot_Interval)-min_v)*Alt_Factor]
    endelse
    ;-------------------------------------
    
    
    ;--- Time String ---
    HOUR=fix(time(I_time))
    MIN=fix(time(I_time)*60.-HOUR*60.)
    SEC=fix(time(I_time)*3600.-HOUR*60.*60.-MIN*60.)
    S_Time=DATE+"T"+string(HOUR, MIN, SEC, format='((I2.2),":",(I2.2),":",(I2.2),"Z")')
    
    HOUR=fix(time(I_time)+INTERVAL_HOUR)
    MIN=fix((time(I_time)+INTERVAL_HOUR)*60.-HOUR*60.)
    SEC=fix((time(I_time)+INTERVAL_HOUR)*3600.-HOUR*60.*60.-MIN*60.)
    E_Time=DATE+"T"+string(HOUR, MIN, SEC, format='((I2.2),":",(I2.2),":",(I2.2),"Z")')
    ;-------------------
    
    Line_KML, File_Unit, Line, Color=I_Color, S_Time=S_Time, E_Time=E_Time, Width=I_Width
    
    SKIP_PLOT:
  endfor
  
  End_Folder_KML, File_Unit
;------------------------
  
end


;===============================================================================
Pro Map_KML, File_Unit, Year, Month, Day, Time, Min_Lat, Max_Lat, Min_Lon, Max_Lon, Alt, Map_Data, Min_V=Min_V, Max_V=Max_V, BAD_DATA=BAD_DATA, Plot_interval=Plot_interval, Name=Name
  ;===============================================================================
  ;
  ;       Plot MAP data on KML
  ;
  ; Input:
  ;   Time: Time of data in Hours in the day: float(Num_Data)
  ;   Map_Data: Data array, (Time, Longitude, Latitude):
  ;                              float(Num_Data, Num_Long, Num_Lat)
  ;   Year, Month, Day:
  ;   Min_Lat, Max_Lat, Min_Lon, Max_Lon: Four corners of Image
  ;   Alt: Altitude
  ; Input(Optional)
  ;   Min_V: Value for the minimum: Blue
  ;   Max_V: Value for the maximum: Red
  ;   BAD_DATA: Be not plotted.
  ;   Plot_Interval: Plot every "Plot_Interval" data
  ;   Name: Name of data, used for folder name
  ;
  ;   2007-02-09 Saito-A
  ;
  ;-------------------------------------------------------------------------------
  ;===============================================================================
  figs_dir="./images/"
  
  BAD_DATA_FLAG=1
  ;-------------------------------------------------------------------------------
  if KEYWORD_SET(Min_V) EQ 0 then Min_V=min(Map_Data)
  if KEYWORD_SET(Max_V) EQ 0 then Max_V=max(Map_Data)
  if KEYWORD_SET(Plot_Interval) EQ 0 then Plot_Interval=1
  if KEYWORD_SET(BAD_DATA) EQ 0 then BAD_DATA_FLAG=0
  if KEYWORD_SET(Name) EQ 0 then Name='Data'
  ;-------------------------------------------------------------------------------
  
  ;----
  INTERVAL_HOUR=time(Plot_Interval)-time(0)
  ;----
  
  ;--- Set Date strings ---
  DATE=string(format='((I4),"-",(I2.2),"-",(I2.2))',YEAR,MONTH,DAY)
  YEAR2=string(format='(I4)',YEAR)
  MONTH2=string(format='(I2.2)',MONTH)
  ;------------------------
  
  ;--- Number of Data  ---
  Num_X=N_elements(Map_Data(0,*,0))
  Num_Y=N_elements(Map_Data(0,0,*))
  Num_Data=N_elements(Time)
  ;-----------------------
  
  ;--- Draw Line in KML ---
  Line=fltarr(3,2)
  Begin_Folder_KML, File_Unit,Name=Name+' '+Date
  
  ;=============================================================== Time LooP =====
  for I_time=0L, Num_Data-1-Plot_Interval, Plot_Interval do begin
  
    ;--- Convert to Byte array               ---
    ;--- Use 39 color table: Bad data = 255B ---
    ;--- Bad data is transparent             ---
    loadct,39
    tvlct, Red, Green, Blue, /get
    Transparent=bytarr(256)+255B
    Transparent(255)=0B
    
    if (BAD_DATA_FLAG EQ 1) then begin
      BAD_INDEX=where(Map_Data(I_time,*,*) GE BAD_DATA, Num_BAD)
    endif
    
    HIGH_INDEX=where(Map_Data(I_time,*,*) GE Max_V, Num_High)
    LOW_INDEX=where(Map_Data(I_time,*,*) LE Min_V, Num_Low)
    
    IMAGE=byte((Map_Data(I_time,*,*)-Min_V)/(Max_V-Min_V)*254)
    if Num_LOW GT 0 then IMAGE(LOW_INDEX)=0B
    if Num_HIGH GT 0 then IMAGE(HIGH_INDEX)=254B
    if (BAD_DATA_FLAG EQ 1) then begin
      if Num_BAD GT 0 then IMAGE(BAD_INDEX)=255B
    endif
    IMAGE=reform(Image(0,*,*))
    ;---------------------------------------------
    
    ;--- Time String ---
    HOUR=fix(time(I_time))
    MIN=fix(time(I_time)*60.-HOUR*60.)
    SEC=fix(time(I_time)*3600.-HOUR*60.*60.-MIN*60.)
    S_Time=DATE+"T"+string(HOUR, MIN, SEC, format='((I2.2),":",(I2.2),":",(I2.2),"Z")')
    
    HOUR=fix(time(I_time)+INTERVAL_HOUR)
    MIN=fix((time(I_time)+INTERVAL_HOUR)*60.-HOUR*60.)
    SEC=fix((time(I_time)+INTERVAL_HOUR)*3600.-HOUR*60.*60.-MIN*60.)
    E_Time=DATE+"T"+string(HOUR, MIN, SEC, format='((I2.2),":",(I2.2),":",(I2.2),"Z")')
    ;-------------------
    
    ;-------------------
    Fig_Name=figs_dir+DATE+'_'+string(HOUR,MIN,SEC,format='((I2.2),"_",(I2.2),"_",(I2.2))')+'.png'
    write_png,Fig_Name, IMAGE, Red, Green, Blue, transparent=Transparent
    ;-------------------
    
    ;-------------------
    printf, File_Unit, "<GroundOverlay>"
    printf, File_Unit, "<name>"+string(HOUR,MIN,SEC,format='((I2.2),"_",(I2.2),"_",(I2.2))')+"</name>"
    printf, File_Unit, "<TimeSpan><begin>"+S_Time+"</begin>"
    printf, File_Unit, "<end>"+E_Time+"</end></TimeSpan>"
    ;printf, File_Unit, "<TimeStamp><when>"+Time_String+"</when></TimeStamp>"
    printf, File_Unit, "<color>ffffffff</color>"
    printf, File_Unit, "<Icon><href>"+Fig_Name+"</href></Icon>"
    printf, File_Unit, "<altitude>"+String(Alt*1000.)+"</altitude><altitudeMode>absolute</altitudeMode>"
    printf, File_Unit, "<LatLonBox><south>"+string(Min_Lat)+"</south> <north>"+string(Max_Lat)+"</north> <west>"+string(Min_Lon)+"</west> <east>"+string(Max_Lon)+"</east> <rotation>0.</rotation> </LatLonBox>"
    printf, File_Unit, "</GroundOverlay>"
    
  ;-------------------
    
  endfor
  ;======================================================== End of Time LooP =====
  
  End_Folder_KML, File_Unit
;------------------------
  
end

;===============================================================================
Pro Map_KML_m, File_Unit, Year, Month, Day_array, Time, Min_Lat, Max_Lat, Min_Lon, Max_Lon, Alt, Map_Data, Min_V=Min_V, Max_V=Max_V, BAD_DATA=BAD_DATA, Plot_interval=Plot_interval, Name=Name
  ;===============================================================================
  ;
  ;       Plot MAP data on KML
  ;
  ; Input:
  ;   Time: Time of data in Hours in the day: float(Num_Data)
  ;   Map_Data: Data array, (Time, Longitude, Latitude):
  ;                              float(Num_Data, Num_Long, Num_Lat)
  ;   Year, Month, Day:
  ;   Min_Lat, Max_Lat, Min_Lon, Max_Lon: Four corners of Image
  ;   Alt: Altitude
  ; Input(Optional)
  ;   Min_V: Value for the minimum: Blue
  ;   Max_V: Value for the maximum: Red
  ;   BAD_DATA: Be not plotted.
  ;   Plot_Interval: Plot every "Plot_Interval" data
  ;   Name: Name of data, used for folder name
  ;
  ;   2007-02-09 Saito-A
  ;
  ;-------------------------------------------------------------------------------
  ;===============================================================================
  figs_dir="./images/"
  
  BAD_DATA_FLAG=1
  ;-------------------------------------------------------------------------------
  if KEYWORD_SET(Min_V) EQ 0 then Min_V=min(Map_Data)
  if KEYWORD_SET(Max_V) EQ 0 then Max_V=max(Map_Data)
  if KEYWORD_SET(Plot_Interval) EQ 0 then Plot_Interval=1
  if KEYWORD_SET(BAD_DATA) EQ 0 then BAD_DATA_FLAG=0
  if KEYWORD_SET(Name) EQ 0 then Name='Data'
  ;-------------------------------------------------------------------------------
  
  ;----
  INTERVAL_HOUR=time(Plot_Interval)-time(0)-1./60.
  ;----
  
  
  ;--- Number of Data  ---
  Num_X=N_elements(Map_Data(0,*,0))
  Num_Y=N_elements(Map_Data(0,0,*))
  Num_Data=N_elements(Time)
  ;-----------------------
  
  ;--- Draw Line in KML ---
  Line=fltarr(3,2)
  Begin_Folder_KML, File_Unit,Name=Name+' '+string(format='((I4),"-",(I2.2))',YEAR,MONTH)
  
  ;=============================================================== Time LooP =====
  ;for I_time=0L, Num_Data-1-Plot_Interval, Plot_Interval do begin
  for I_time=0L, Num_Data-1 do begin
  
    ;--- Convert to Byte array               ---
    ;--- Use 39 color table: Bad data = 255B ---
    ;loadct,1
    if (BAD_DATA_FLAG EQ 1) then begin
      BAD_INDEX=where(Map_Data(I_time,*,*) EQ BAD_DATA, Num_BAD)
    endif
    
    HIGH_INDEX=where(Map_Data(I_time,*,*) GE Max_V, Num_High)
    LOW_INDEX=where(Map_Data(I_time,*,*) LE Min_V, Num_Low)
    
    ;IMAGE=255B-byte((Map_Data(I_time,*,*)-Min_V)/(Max_V-Min_V)*253)
    ;IMAGE=byte((Map_Data(I_time,*,*)-Min_V)/(Max_V-Min_V)*255)
    IMAGE=byte((Map_Data(I_time,*,*)-Min_V)/(Max_V-Min_V)*254+1)
    if Num_LOW GT 0 then IMAGE(LOW_INDEX)=1B
    if Num_HIGH GT 0 then IMAGE(HIGH_INDEX)=255B
    if (BAD_DATA_FLAG EQ 1) then begin
      if Num_BAD GT 0 then IMAGE(BAD_INDEX)=0B
    endif
    IMAGE=reform(Image(0,*,*))
    ;---------------------------------------------
    
    ;--- Time String ---
    ;--- Set Date strings ---
    DATE=string(format='((I4),"-",(I2.2),"-",(I2.2))',YEAR,MONTH,DAY_Array(I_time))
    ;------------------------
    HOUR=fix(time(I_time))
    MIN=fix(time(I_time)*60.-HOUR*60.)
    SEC=fix(time(I_time)*3600.-HOUR*60.*60.-MIN*60.)
    S_Time=DATE+"T"+string(HOUR, MIN, SEC, format='((I2.2),":",(I2.2),":",(I2.2),"Z")')
    
    
    Dum_HOUR=fix(time(I_time)+INTERVAL_HOUR)
    Dum_MIN=fix((time(I_time)+INTERVAL_HOUR)*60.-dum_HOUR*60.)
    ;Dum_SEC=fix((time(I_time)+INTERVAL_HOUR)*3600.-dum_HOUR*60.*60.-dum_MIN*60.-1)
    Dum_SEC=59
    E_Time=DATE+"T23:59:59Z"
    ;E_Time=DATE+"T"+string(Dum_HOUR, Dum_MIN, Dum_SEC, format='((I2.2),":",(I2.2),":",(I2.2),"Z")')
    ;-------------------
    
    ;-------------------
    ;Fig_Name=figs_dir+DATE+'_'+string(HOUR,MIN,SEC,format='((I2.2),"_",(I2.2),"_",(I2.2))')+'.jpg'
    ;write_JPEG,Fig_Name, IMAGE
    
    Fig_Name=figs_dir+DATE+'_'+string(HOUR,MIN,SEC,format='((I2.2),"_",(I2.2),"_",(I2.2))')+'.png'
    red=indgen(256,/byte)
    blue=indgen(256,/byte)
    green=indgen(256,/byte)
    green(0)=255B
    tra=bytarr(256)
    for I_tra=120, 256-1 do begin
      tra(I_tra)=255B
    endfor
    write_png,Fig_Name,IMAGE,red,green,blue,transparent=tra
    ;-------------------
    
    ;-------------------
    printf, File_Unit, "<GroundOverlay>"
    printf, File_Unit, "<name>"+string(HOUR,MIN,SEC,format='((I2.2),"_",(I2.2),"_",(I2.2))')+"</name>"
    printf, File_Unit, "<TimeSpan><begin>"+S_Time+"</begin>"
    printf, File_Unit, "<end>"+E_Time+"</end></TimeSpan>"
    ;printf, File_Unit, "<TimeStamp><when>"+Time_String+"</when></TimeStamp>"
    printf, File_Unit, "<color>ccffffff</color>"
    printf, File_Unit, "<Icon><href>"+Fig_Name+"</href></Icon>"
    printf, File_Unit, "<altitude>"+String(Alt*1000.)+"</altitude><altitudeMode>absolute</altitudeMode>"
    printf, File_Unit, "<LatLonBox><south>"+string(Min_Lat)+"</south> <north>"+string(Max_Lat)+"</north> <west>"+string(Min_Lon)+"</west> <east>"+string(Max_Lon)+"</east> <rotation>0.</rotation> </LatLonBox>"
    printf, File_Unit, "</GroundOverlay>"
    
  ;-------------------
    
  endfor
  ;======================================================== End of Time LooP =====
  
  End_Folder_KML, File_Unit
;------------------------
  
end

;===============================================================================
Pro  Arrow_KML_old, File_Unit, Location, Vector, Scale, Name=Name, Color=Color, Time=Time, S_Time=S_Time, E_Time=E_Time, Width=Width, No_mark=No_mark
  ;===============================================================================
  ; Open KML file
  ;
  ; Input:
  ;   Location: Location of data point [Lat, Long, Alt[km]]
  ;   Vector: Vectror of arrow in Geophysical coordinate
  ;       [Northward, Eastward, Upward]
  ;   Scale: Scale factor of arrow.
  ;     If Scale = Vector, Arrow length=300km
  ; Input (Optional):
  ;              Name: Name of Line [String]
  ;              Color: Color in KML format, #TTBBGGRR
  ;              Time: Time in KML format e.g., "2006-12-15T17:00:25Z"
  ;
  ; Usage:
  ;       Arrow_KML, File_Unit, [35., 135., 300], [100., 200., 300.], 1000.
  ;
  ;   2007-02-18 Saito-A
  ;
  ;-------------------------------------------------------------------------------
  Length_of_Arrow_km=300.
  
  Earth_Radi=6375.
  Tip=fltarr(3)
  
  if KEYWORD_SET(Name) EQ 0 then Name='Arrow'
  if KEYWORD_SET(Color) EQ 0 then Color='ff0000ff'
  if KEYWORD_SET(Width) EQ 0 then Width=3.
  if KEYWORD_SET(No_mark) EQ 0 then No_mark=0
  
  ;------------------------------------------------------- Tip Location ----------
  Tip(0)=Location(0)+Vector(0)/Scale*(Length_of_Arrow_km/(Earth_Radi*2*!PI))*360.
  Tip(1)=Location(1)+Vector(1)/Scale*(Length_of_Arrow_km/(Earth_Radi*2*!PI*cos(Location(0)/180.*!PI)))*360.
  Tip(2)=Location(2)+Vector(2)/Scale*Length_of_Arrow_km
  ;-------------------------------------------------------------------------------
  
  ;--------------------------------------------------------- Line Array ----------
  Line=fltarr(3,2)
  Line(*, 0)=Location
  Line(*, 1)=Tip
  ;-------------------------------------------------------------------------------
  
  
  ;------------------------------------ Arrow Line from Location to Tip ----------
  if KEYWORD_SET(Time) then begin
    Line_KML, File_Unit, Line, Color=Color, Name=Name, Time=Time, Width=Width
    if No_Mark EQ 0 then begin
      Point_KML, File_Unit, Location, Name=' ', Style_Name='Arrow_Point', Time=Time
    endif
  endif else begin
    if KEYWORD_SET(S_Time) then begin
      Line_KML, File_Unit, Line, Color=Color, Name=Name, S_Time=S_Time, E_Time=E_Time, Width=Width
      if No_Mark EQ 0 then begin
        Point_KML, File_Unit, Location, Name=' ', Style_Name='Arrow_Point', S_TIME=s_time, E_TIME=e_time
      endif
    endif else begin
      Line_KML, File_Unit, Line, Color=Color, Name=Name, Width=Width
      if No_Mark EQ 0 then begin
        Point_KML, File_Unit, Location, Name=' ', Style_Name='Arrow_Point'
      endif
    endelse
  endelse
;-------------------------------------------------------------------------------
  
end

;===============================================================================
Pro  Arrow_KML, File_Unit, Location, Vector, Scale, Name=Name, Color=Color, Time=Time, S_Time=S_Time, E_Time=E_Time, Width=Width, No_mark=No_Mark
  ;===============================================================================
  ; Using Coordinates.pro
  ;
  ; Input:
  ;   Location: Location of data point [Lat, Long, Alt[km]]
  ;   Vector: Vectror of arrow in Geophysical coordinate
  ;       [Northward, Eastward, Upward]
  ;   Scale: Scale factor of arrow.
  ;     If Scale = Vector, Arrow length=300km
  ; Input (Optional):
  ;              Name: Name of Line [String]
  ;              Color: Color in KML format, #TTBBGGRR
  ;              Time: Time in KML format e.g., "2006-12-15T17:00:25Z"
  ;
  ; Usage:
  ;       Arrow_KML, File_Unit, [35., 135., 300], [100., 200., 300.], 1000.
  ;
  ;   2007-02-18 Saito-A
  ;
  ;-------------------------------------------------------------------------------
  Length_of_Arrow_km=300.
  
  Earth_Radi=6375.
  Tip=fltarr(3)
  
  if KEYWORD_SET(Name) EQ 0 then Name='Arrow'
  if KEYWORD_SET(Color) EQ 0 then Color='ff0000ff'
  if KEYWORD_SET(Width) EQ 0 then Width=3.
  if KEYWORD_SET(No_mark) EQ 0 then No_mark=0
  
  ;------------------------------------------------------- Tip Location ----------
  ;if KEYWORD_SET(Color_Plot) EQ 1 then begin
  ; Amplitude=sqrt(Vector(0)^2+Vector(1)^2+Vector(2)^2)
  ;;  Min_Value=0.
  ; Max_Value=Scale
  ; Color=Color_KML(Amplitude, Min_Value, Max_Value)
  
  Loc_car=pol2car(Location)
  L=-Vector(0)*sin(Location(0)/180.*!PI)+Vector(2)*cos(Location(0)/180.*!PI)
  Tip(0)=L*cos(Location(1)/180.*!PI)-Vector(1)*sin(Location(1)/180.*!PI)
  Tip(1)=L*sin(Location(1)/180.*!PI)+Vector(1)*cos(Location(1)/180.*!PI)
  Tip(2)=Vector(0)*cos(Location(0)/180.*!PI)+Vector(2)*sin(Location(0)/180.*!PI)
  
  Tip=Loc_Car+Length_of_Arrow_km*Tip/Scale
  Tip=car2pol(Tip)
  
  ;Tip(0)=Location(0)+Vector(0)/Scale*(Length_of_Arrow_km/(Earth_Radi*2*!PI))*360.
  ;Tip(1)=Location(1)+Vector(1)/Scale*(Length_of_Arrow_km/(Earth_Radi*2*!PI*cos(Location(0)/180.*!PI)))*360.
  ;Tip(2)=Location(2)+Vector(2)/Scale*Length_of_Arrow_km
  ;-------------------------------------------------------------------------------
  
  ;--------------------------------------------------------- Line Array ----------
  Line=fltarr(3,2)
  Line(*, 0)=Location
  Line(*, 1)=Tip
  ;-------------------------------------------------------------------------------
  
  
  ;------------------------------------ Arrow Line from Location to Tip ----------
  if KEYWORD_SET(Time) then begin
    Line_KML, File_Unit, Line, Color=Color, Name=Name, Time=Time, Width=Width
    if No_Mark EQ 0 then begin
      Point_KML, File_Unit, Location, Name=' ', Style_Name='Arrow_Point', Time=Time
    endif
  endif else begin
    if KEYWORD_SET(S_Time) then begin
      Line_KML, File_Unit, Line, Color=Color, Name=Name, S_Time=S_Time, E_Time=E_Time, Width=Width
      if No_Mark EQ 0 then begin
        Point_KML, File_Unit, Location, Name=' ', Style_Name='Arrow_Point', S_TIME=s_time, E_TIME=e_time
      endif
    endif else begin
      Line_KML, File_Unit, Line, Color=Color, Name=Name, Width=Width
      if No_Mark EQ 0 then begin
        Point_KML, File_Unit, Location, Name=' ', Style_Name='Arrow_Point'
      endif
    endelse
  endelse
;-------------------------------------------------------------------------------
  
end

Function ColorBar_KML, File_Unit, Title_String, Min_V, Max_V, ColorTable, Start_Time, End_Time,ColorBar_ImageName=ColorBar_ImageName
  ;===============================================================================
  ; Make ColorBar image file, and Screen Overlay entry
  ;
  ; Input:
  ;   File_Unit
  ;   Title_String:
  ;   Min_V, Max_V: Minimum & Maximum Values
  ;   ColorTable: Colortable number
  ; Input (Optional):
  ;   Start_Time, End_Time: Time in KML format
  ; Return: Color Bar image File name
  ; Usage:
  ;   Title_String='TEC'
  ;   Start_Time='2008-01-01T00:00:00Z'
  ;   Start_Time= $
  ;   string(YEAR,month,day,format='(I4.4,"-",I2.2,"-",I2.2,"T")')+'00:00:00Z'
  ;   End_Time= $
  ;   string(YEAR,month,day,format='(I4.4,"-",I2.2,"-",I2.2,"T")')+'23:59:59Z'
  ;
  ;   ColorBar_ImageName=ColorBar_KML(KML_Unit, Title_String, $
  ;     Min_V, Max_V, 13, Start_Time, End_Time)
  ;
  ;   2008-09-20 Saito-A
  ;
  ;-------------------------------------------------------------------------------
  time_display=0
  if KEYWORD_SET(Start_Time) NE 0 then time_display=1
  if KEYWORD_SET(End_Time) NE 0 then time_display=1
  
  IF NOT KEYWORD_SET(ColorBar_ImageName) THEN BEGIN
    X_Size='0.24'
    Y_Size='0.03'
    X_Location='0.75'
    Y_Location='0.45'
    
    FORMAT_STRING='(F5.1)'
    
    ColorBar_ImageName="colorbar.png"
    PS_Name=ColorBar_ImageName+'.ps'
    
    CONVERT_COMMAND='convert '
    ;------------------------------------------------------------------------------
    ;------------------------------------------- Make Colorbar PS -----------------
    set_plot,'ps'
    device,BITS_PER_PIXEL=8,/color,xsize=8,ysize=3,yoffset=2.,/TIMES, $
      Filename=PS_Name
    loadct,ColorTable
    !P.FONT=0
    fsc_colorbar, POSITION=[0.1, 0.2, .9, .8],  $
      FORMAT=Format_String, divisions=4, minrange=Min_V,  maxrange=Max_V, $
      Title=Title_String,  ncolors=256
    ;    FORMAT=Format_String, divisions=4, min=Min_V,  max=Max_V, $
    ;    Title=Title_String,  ncolors=256
    Device,/close
    ;------------------------------------------------------------------------------
    
    ;------------------------------------------- Convert PS to PNG -----------------
    spawn, CONVERT_COMMAND+' '+PS_Name+' '+ColorBar_ImageName
    ;------------------------------------------------------------------------------
    
    ;------------------- Remove ColorBar Image ------
    spawn,'rm -f '+PS_Name
  ;------------------------------------------------
    
  ENDIF ELSE BEGIN
    isawindir=0
    IF NOT FILE_TEST(ColorBar_ImageName) THEN BEGIN
    isawindir=1
      IF NOT FILE_TEST(TLI_DIRW2L(ColorBar_ImageName)) THEN BEGIN
        Message, 'ERROR: File not exist.',TLI_DIRW2L(ColorBar_ImageName)
      ENDIF
    ENDIF
    IF isawindir THEN BEGIN
      img=READ_IMAGE(TLI_DIRW2L(ColorBar_ImageName))
    ENDIF ELSE BEGIN
      img=READ_IMAGE(ColorBar_ImageName)
    ENDELSE
    minsize=0.0618
    sz=SIZE(img,/DIMENSIONS)
    IF N_ELEMENTS(sz) EQ 2 THEN BEGIN
      samples=sz[0]
      lines=sz[1]
    ENDIF ELSE BEGIN
      samples=sz[1]
      lines=sz[2]
    ENDELSE
    
    res=GET_SCREEN_SIZE() ; Resolution of device.
    x_res=res[0]
    y_res=res[1]
    IF samples GE lines THEN BEGIN
      Y_size=minsize
      x_size=y_size/lines*samples/x_res*y_res
      x_location=1-x_size-0.075
      y_location=0.11
    ENDIF ELSE BEGIN
      x_size=minsize
      y_size=x_size/samples*lines/y_res*x_res
      x_location=1-x_size-0.075
      y_location=0.11
    ENDELSE
    
    X_Size=STRCOMPRESS(x_size,/REMOVE_ALL)
    Y_Size=STRCOMPRESS(y_size,/REMOVE_ALL)
    X_Location=STRCOMPRESS(x_location,/remove_all)
    Y_Location=STRCOMPRESS(y_location,/remove_all)
    
  ENDELSE
  ;---------------------------------------- ScreenOverlay Entry -----------------
  printf, File_Unit, '<ScreenOverlay> '
  printf, File_Unit, ' <Icon><href> '+FILE_BASENAME(ColorBar_ImageName)+'</href></Icon>'
  printf, File_Unit, ' <overlayXY x="0" y="0" xunits="fraction" yunits="fraction"/>'
  printf, File_Unit, ' <screenXY x="'+X_Location+'" y="'+Y_Location+$
    '" xunits="fraction" yunits="fraction"/>'
  printf, File_Unit, ' <size x="'+X_Size+'" y="'+Y_Size+$
    '" xunits="fraction" yunits="fraction"/>'
    
  printf, File_Unit,  '<color>deffffff</color>'
  if Time_Display EQ 1 then begin
    printf, File_Unit,  '<TimeSpan> '
    if KEYWORD_SET(Start_Time) NE 0 then printf, File_Unit,  ' <begin>'+Start_Time+'</begin>'
    if KEYWORD_SET(End_Time) NE 0 then printf, File_Unit,  ' <end>'+End_Time+'</end>'
    printf, File_Unit,  '</TimeSpan>'
  endif
  printf, File_Unit,  '<name> Color bar :'+Title_String+'</name>'
  printf, File_Unit,  '</ScreenOverlay>'
  ;------------------------------------------------------------------------------
  
  
  Return, ColorBar_ImageName
;------------------------------------------------------------------------------
end
;===============================================================================
;
; Example of Usage
;
;===============================================================================
;Line=[[33.8, 133.8, 5.],[34.3, 134.3, 5.]]
;Polygon=[[35., 135., 3.], [35, 134, 3.], [34., 134., 3.],[34, 135, 3.]]
;Center=[35.,135., 10.]
;Width=[.1,.1, 10.]
;
; I_err=Open_KML('test.kml',I_Unit)
;
; Begin_Folder_KML, I_Unit
;   Point_KML,  I_Unit, Line(*,0), Time='2006-12-15T02:08:30Z', Descri="This is ..."
;   Lookat_KML, I_Unit,Line(*,1)
;   Line_KML, I_Unit, Line, Color='550000ff', Width=10
;   Polygon_KML, I_Unit, Polygon, Color='5500ff00', Time='2006-12-17'
;   I_Color=Color_KML(60., 0., 100., Transparency='55')
;   Cube_KML,  I_Unit, Center, Width=Width, Color=I_Color
; End_Folder_KML, I_Unit
;
; Close_KML,  I_Unit
;end
;===============================================================================

PRO KML
  COMPILE_OPT idl2
  Print, 'This is a void main pro.'
END