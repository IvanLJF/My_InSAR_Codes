; $Id: //depot/idl/IDL_70/idldir/lib/read_bmp.pro#1 $
;
; Copyright (c) 1993-2007, ITT Visual Information Solutions. All
;       rights reserved. Unauthorized reproduction is prohibited.

FUNCTION READ_BMP, File, Red, Green, Blue, Ihdr, RGB=rgb
;+
; NAME:
;	READ_BMP
;
; PURPOSE:
; 	This function reads a Microsoft Windows Version 3 device
;	independent bitmap file (.BMP).
;
; CATEGORY:
;   	Input/Output
;
; CALLING SEQUENCE:
;   	Result = READ_BMP(File [, R, G, B [, IHDR]])
;
; INPUTS:
; 	File: The full path name of the bitmap file to read.
;
; OUTPUTS:
;	This function returns a byte array containing the image
;	from the bitmap file. In the case of 4-bit or 8-bit images,
;	the dimensions of the resulting array are [biWidth, biHeight];
;	for 16 and 24-bit decomposed color images the dimensions are
;	[3, biWidth, biHeight].
;	Dimensions are taken from the BITMAPINFOHEADER of the file.
;	NOTE: for 24 bit images, unless the RGB keyword is supplied,
;	color interleaving is blue, green, red;
;	i.e. result[0,i,j] = blue, result[1,i,j] = green, etc.
;
; OPTIONAL OUTPUTS:
;   	R, G, B:  Color tables from the file. There 16 elements each for
;		  4 bit images, 256 elements each for 8 bit images. Not
;		  defined or used for 16 and 24 bit images.
;  	Ihdr:	  A structure containing BITMAPINFOHEADER from file.
;		  Tag names are as defined in the MS Windows Programmer's
;		  Reference Manual, Chapter 7.
;
; KEYWORDDS:
;	RGB:	If this keyword is supplied, and a 16 or 24-bit image is read,
;		color interleaving of the result is R, G, B, rather than BGR.
;		Result[0,i,j] = red, Result[1,i,j] = green, and
;		Result[2,i,j] = blue.
; SIDE EFFECTS:
;   	IO is performed.
;
; RESTRICTIONS:
;   	DOES NOT HANDLE: 1 bit deep images, or compressed images.
;   	Is not fast for 4 bit images. Works best on images where the
;   	number of bytes in each scan-line is evenly divisible by 4.
;
; PROCEDURE:
;   	Straightforward. Will work on both big endian and little endian
;	machines.
;
; EXAMPLE:
;   	TV, READ_BMP('c:\windows\party.bmp', r, g, b) 	;Read & display image
;   	TVLCT, r, g, b              			;Load it's colors
;
; MODIFICATION HISTORY:
;   DMS, RSI.   March 1993.   	Original version.
;   DMS, RSI.   May, 1993.	Now works on all machines...
;   DMS, RSI.   Nov, 1996	Added support for 16-bit RGB and RGB keyword.
;   CT, RSI, Aug 2003: Fix bug in error code if unable to open file.
;-

on_ioerror, bad
on_error, 2         ;Return on error

openr, unit, file, /GET_LUN, /BLOCK
fhdr = { BITMAPFILEHEADER, $
    bftype: bytarr(2), $        ;A two char string
    bfsize: 0L, $
    bfreserved1: 0, $
    bfreserved2: 0, $
    bfoffbits: 0L $
  }
readu, unit, fhdr           ;Read the bitmapfileheader
if string(fhdr.bftype) ne "BM" then begin
    free_lun,unit
    message, 'File '+file+' is not in bitmap file format'
endif

ihdr = { BITMAPINFOHEADER, $
    bisize: 0L, $
    biwidth: 0L, $
    biheight: 0L, $
    biplanes: 0, $
    bibitcount: 0, $
    bicompression: 0L, $
    bisizeimage: 0L, $
    bixpelspermeter: 0L, $
    biypelspermeter: 0L, $
    biclrused: 0L, $
    biclrimportant: 0L $
  }


readu, unit, ihdr

big_endian = (byte(1,0,2))[0] eq 0b
if big_endian then begin		;Big endian machine?
    fhdr = swap_endian(fhdr)		;Yes, swap it
    ihdr = swap_endian(ihdr)
    endif

if ihdr.bibitcount eq 1 then begin
     free_lun, unit
     message, 'Can''t handle monochrome images'
endif
if ihdr.bicompression ne 0 then begin
    free_lun, unit
    message, 'Can''t handle compressed images'
endif

	;Pseudo color?
if (ihdr.bibitcount lt 16)  then begin
    ncolors = 2L^ihdr.bibitcount
    ; See if we have less than the maximum number of colors.
    if (ihdr.biclrused gt 0 && ihdr.biclrused lt ncolors) then $
        ncolors = ihdr.biclrused
    colors = bytarr(4, ncolors)
    readu, unit, colors             ;Read colors
    red = reform(colors[2, *])        ;Decommutate colors
    green = reform(colors[1, *])
    blue = reform(colors[0, *])
endif

nx = ihdr.biwidth		;Columns
ny = ihdr.biheight		;Rows

point_lun, unit, fhdr.bfoffbits     ;Point to data...

case ihdr.bibitcount of			;How many bits/pixel?
4: begin
    a = bytarr(nx, ny, /nozero)
    buff = bytarr(nx/2, /nozero)   ;Line buffer
    even = lindgen(nx/2) * 2
    odd = even + 1
    if nx and 1 then pad = 0B       ;interbyte padding
    i = (n_elements(buff) + n_elements(pad)) and 3  ;bytes we have
    if i ne 0 then pad = bytarr(4-i+n_elements(pad))
    for i=0, ny-1 do begin
        if n_elements(pad) ne 0 then readu, unit, buff, pad $
        else readu, unit, buff
        a[even, i] = ishft(buff, -4)
        a[odd, i] = buff and 15b
        if nx and 1 then a[nx-1, i] = ishft(pad[0], -4) ;Last odd byte?
        endfor
    endcase

8:  begin
    a = bytarr(nx, ny, /nozero)
    if (nx and 3) eq 0 then readu, unit, a $          ;Slam dunk it
    else begin                      ;Must read line by line...
       pad = bytarr(4 - (nx and 3))
       buff = bytarr(nx, /nozero)
       for i=0, ny-1 do begin       ;Each line
           readu, unit, buff, pad
           a[0,i] = buff
           endfor
       endelse
    endcase			;8 bits/pixel

16: begin			;16 bits/pixel
;		bits(0:4) = blue
;		bits(5:9) = green
;		bits(10:14) = red
    a = intarr(nx * ny, /nozero)	;Read as a 1D array
    if  (nx and 1) eq 0 then readu, unit, a $  ;If even # of cols, no padding
    else begin
        pad = 0			;Pad 1 16 bit word
        buff = intarr(nx, /nozero)
        for i=0, ny-1 do begin
            readu, unit, buff, pad
            a[i * nx] = buff		;Insert line
            endfor
    endelse
    if big_endian then byteorder, a, /sswap
    r = byte(ishft(a,-7) and 248)	;Shift down 10 and up 3
    g = byte(ishft(a,-2) and 248)	;down 5 and up 3
    a = byte(ishft(a, 3) and 248)	;up 3, really blue
    if keyword_set(RGB) then a = [r,g,a] $  ;Unswitch it?
    else a = [a,g,r]

    a = reform(a, nx * ny, 3, /overwrite)	;Diddle to 3,nx,ny
    a = transpose(temporary(a))		;Color interleave in 1st dimension
    a = reform(a,3,nx,ny,/overwrite)
    endcase			;16 bits

24: begin                    ;24 bits / pixel....
    a = bytarr(3, nx, ny, /nozero)
    if ((3 * nx) and 3) eq 0 then readu, unit, a $  ;Again, dunk it.
    else begin
        pad = bytarr(4 - ((3 * nx) and 3))
        buff = bytarr(3, nx, /nozero)
        for i=0, ny-1 do begin
            readu, unit, buff, pad
            a[0,0, i] = buff            ;Insert line
        endfor
    endelse
    if keyword_set(RGB) then begin	;Unswitch it?
    	buff = a[0,*,*]
    	a[0,0,0] = a[2,*,*]
    	a[2,0,0] = buff
	endif
    endcase			;24bits

else: begin
       free_lun,unit
       Message,'Can not handle '+strtrim(ihdr.bibitcount,2)+' bits/pixel'
      endcase
endcase

free_lun, unit
return, a

bad:
if n_elements(unit) gt 0 then $
    if (unit ne 0) then free_lun, unit
Message, 'Can''t open (or read)' + file
return, 0
end

