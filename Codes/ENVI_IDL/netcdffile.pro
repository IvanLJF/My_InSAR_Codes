PRO NETCDFFILE
  file='/mnt/software/ForExperiment/GMT/ex02/HI_geoid2.nc'
  id= NCDF_OPEN(file)
  FOR i=0,4 DO BEGIN
    name= NCDF_ATTNAME(id,/GLOBAL,i)
    NCDF_ATTGET, id, /GLOBAL, name, val
    result= NCDF_ATTINQ(id, /GLOBAL, name)
    PRINT, name, STRING(val)
;    HELP, name,val, result
  ENDFOR
  NCDF_CLOSE, id
END
  

;- Create and write data
;file='/mnt/software/ForExperiment/GMT/dave.nc'  
;  id= NCDF_CREATE(file,/CLOBBER)
;  NCDF_ATTPUT, id, 'TITLE', 'Dave.nc for test',/GLOBAL
;  NCDF_ATTPUT, id, 'DATE', '201112021836',/GLOBAL
;  xid= NCDF_DIMDEF(id, 'x', 200)
;  yid= NCDF_DIMDEF(id, 'y', 200)
;  vid= NCDF_VARDEF(id, 'image', [yid, xid],/FLOAT)
;  ;- Rename if possible
;  NCDF_VARRENAME, id, vid, 'dist_image'
;  NCDF_ATTPUT, id, vid, 'TITLE', 'DIST_IMAGE'
;  NCDF_CONTROL, id, /ENDEF
;  image=DIST(200)
;  NCDF_VARPUT, id, vid, image
;  NCDF_CLOSE, id


;  -Get data from a NetCDF file.
;;  ; A variable that contains the offset for the sub-image: 
;;offset = [80, 20] 
;;; The dimensions of the sub-image: 
;;count = [70, 70] 
;;; Create a variable to be used as a value for the STRIDE keyword. 
;;; Every other X element and every third Y element will be sampled: 
;;stride = [2, 3] 
;;; Open the NetCDF file: 
;;id = NCDF_OPEN('dave.nc') 
;;; Get the variable ID for the image: 
;;image = NCDF_VARID(id, 'image') 
;;; Get the full image: 
;;NCDF_VARGET, id, image, fullimage 
;;; Extract the sub-sampled image: 
;;NCDF_VARGET, id, image, subimage, $ 
;;   COUNT=count, STRIDE=stride, OFFSET=offset 
;;; Close the NetCDF file: 
;;NCDF_CLOSE, id 



;;- Opration for NetCDF Attributions
;id = NCDF_CREATE('test.nc', /CLOBBER ; Open a new netCDF file. 
;id2 = NCDF_CREATE('test2.nc', /CLOBBER ; Open a second file. 
;; Create two global attributes TITLE and DATE: 
;NCDF_ATTPUT, id, /GLOBAL, 'TITLE', 'MY TITLE' 
;NCDF_ATTPUT, id, /GLOBAL, 'DAY', 'July 1,1996' 
;; Suppose we wanted to use DATE instead of DAY. We could use 
;; ATTRENAME to rename the attribute: 
;NCDF_ATTRENAME, id, 'DAY', 'DATE', /GLOBAL 
;; Next, copy both attributes into a duplicate file: 
;result = NCDF_ATTCOPY(id, 'TITLE', id2, /IN_GLOBAL, /OUT_GLOBAL) 
;result2 = NCDF_ATTCOPY(id, 'DATE', id2, /IN_GLOBAL, /OUT_GLOBAL) 
;; Put the file into data mode: 
;NCDF_CONTROL, id, /ENDEF 
;; Get the second attribute's name: 
;name = NCDF_ATTNAME(id, /GLOBAL, 1) 
;; Retrieve the date: 
;NCDF_ATTGET, id, /GLOBAL, name, date 
;; Get info about the attribute: 
;result = NCDF_ATTINQ(id, /GLOBAL, name) 
;HELP, name, date, result, /STRUCTURE 
;PRINT, date 
;PRINT, STRING(date) 
;NCDF_DELETE, id ; Close the netCDF files. 
;NCDF_DELETE, id2
