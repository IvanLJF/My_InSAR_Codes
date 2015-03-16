;------------------------------------------------------------------------
; RAT - Radar Tools
;------------------------------------------------------------------------
; RAT Module: open_envi
; last revision : 1.October 2003
; written by    : Andreas Reigber
; Reads data in ENVI standard format (at least in most of the cases)              
;------------------------------------------------------------------------
; The contents of this file are subject to the Mozilla Public License
; Version 1.1 (the "License"); you may not use this file except in
; compliance with the License. You may obtain a copy of the License at
; http://www.mozilla.org/MPL/
;
; Software distributed under the License is distributed on an "AS IS"
; basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
; License for the specific language governing rights and limitations
; under the License.
;
; The Initial Developer of the Original Code is the RAT development team.
; All Rights Reserved.
;------------------------------------------------------------------------



pro open_envi,INPUTFILE = inputfile
	common rat, types, file, wid, config
	common channel, channel_names, channel_selec, color_flag, palettes, pnames

	if not keyword_set(inputfile) then begin
		path = config.workdir
		inputfile = cw_rat_dialog_pickfile(TITLE='Open ENVI file', $
		DIALOG_PARENT=wid.base, FILTER = '*.dat', /MUST_EXIST, PATH=path, GET_PATH=path)
		if strlen(inputfile) gt 0 then config.workdir = path
	endif

	if strlen(inputfile) gt 0 then begin

; change mousepointer
	
		WIDGET_CONTROL,/hourglass

; undo function
                undo_prepare,outputfile,finalfile,CALLED=CALLED
                open_rit,/EMPTY ; no parameters are set: delete the old ones!

; analyse HDR file

		hdrfile = inputfile + '.hdr'
		rstr  = ''
		openr,ddd,hdrfile,/get_lun
		readf,ddd,rstr
		if rstr ne 'ENVI' then begin
			error = DIALOG_MESSAGE("This is not an ENVI standard file", DIALOG_PARENT = wid.base, TITLE='Error',/error)
			return
		endif

; set file type

		whatisthis	

; -------------

		repeat begin
			readf,ddd,rstr
			spstr = strsplit(rstr,/extract)
			case spstr[0] of
				'description':  begin
					readf,ddd,rstr
					file.info = strcompress(strmid(rstr,0,strlen(rstr)-1),/remove)
				end
				'samples':  file.xdim = long(spstr[2])
				'lines'  :  file.ydim = long(spstr[2])
				'bands'  :  begin
					if long(spstr[2]) eq 1 then file.dim  = 2l else file.dim = 3l
					if long(spstr[2]) eq 1 then file.zdim = 1l else file.zdim = long(spstr[2])
				end
				'header'  :  offset = long(spstr[3])
				'data'    :  file.var = long(spstr[3])
				'interleave' :  interl = spstr[2]
				'byte'    :  endian = long(spstr[3])
				else: rstr = ''
			endcase
		endrep until eof(ddd)
		free_lun,ddd
		file.vdim = 1l		

; Byte data? If yes convert to integer
		
		invar = file.var	
		if file.var eq 1 then file.var = 2
;  					
; Read and convert data

		if file.dim eq 2 then begin  ; single channel data (no interleave conversion)
			srat,config.tempdir+config.workfile1,eee,header=[2l,file.xdim,file.ydim,file.var],type=file.type
			openr,ddd,inputfile,/get_lun
			point_lun,ddd,offset

			for i=0,file.ydim-1 do begin
				block = make_array([file.vdim,file.zdim,file.xdim,1l],type=invar)
				readu,ddd,block
				if endian eq 1 then block = swap_endian(block) else block = block
				if invar eq 1 then block = fix(block)
				writeu,eee,block
			endfor
		endif
		
		if file.dim eq 3 then begin ; multi channel data
			openr,ddd,inputfile,/get_lun
			srat,config.tempdir+config.workfile1,eee,header=[3l,file.zdim,file.xdim,file.ydim,file.var],type=file.type
			point_lun,ddd,offset
			case interl of

; band interleave				
				'bsq': begin
					block  = make_array([file.xdim,file.ydim],type=invar)
					oblock = make_array([file.zdim,file.xdim,file.ydim],type=file.var)
					for i=0,file.zdim-1 do begin
						readu,ddd,block	
						if endian eq 1 then block = swap_endian(block)
						oblock[i,*,*] = block
					endfor
					if invar eq 1 then oblock = fix(oblock)
					writeu,eee,oblock
				end
				
; pixel interleave				
				'bip': begin 
					for i=0,file.ydim-1 do begin
						block  = make_array([file.zdim,file.xdim],type=invar)
						readu,ddd,block	
						if endian eq 1 then block = swap_endian(block)
						if invar eq 1 then block = fix(block)
						writeu,eee,block
					endfor

				end
				
; line interleave				
				'bil': begin 
					error = DIALOG_MESSAGE("line interleave not yet supported", DIALOG_PARENT = wid.base, TITLE='Error',/error)
					return
				end
				else: begin
					error = DIALOG_MESSAGE("No valid interleave found", DIALOG_PARENT = wid.base, TITLE='Error',/error)
					return
				end
			endcase
		endif
		free_lun,ddd,eee
		file.name = config.tempdir+config.workfile1

; update file generation history (evolution)
	
	evolute,'Import SAR data from ENVI.'

; read palette information
	
	palettes[0,*,*] = palettes[2,*,*] ; set variable palette to b/w linear
	palettes[1,*,*] = palettes[2,*,*] ; set variable palette to b/w linear

; generate preview

	file.window_name = 'Untitled.rat'
	generate_preview
	update_info_box
	
	endif	
end
