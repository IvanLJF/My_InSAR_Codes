; Procedure: MEMTEST
;
; Syntax: memtest
;
; Purpose:
; This procedure was designed primarily to test the impacts of Windows OS
; memory fragmentation behavior on IDL memory allocation.
;
; The procedure attempts to allocate 10 coexisting memory blocks of 2 GB size.
; If there is not enough memory to accomplish this, it allocates the 10
; largest coexisting blocks that it can. It stops allocating new memory blocks
; either:
;
; - when it has allocated full 10 blocks.
; - when it cannot allocate any additional block of more than 1 MB in size
; (i.e. when the application has run out of available memory).
;
; Postcondition:
; This program outputs a log of its successful allocations that may look like:
;
; Memory block # 1: 1168 Mb (total: 1168 Mb)
; Memory block # 2: 206 Mb (total: 1374 Mb)
; Memory block # 3: 143 Mb (total: 1517 Mb)
; Memory block # 4: 118 Mb (total: 1635 Mb)
; Memory block # 5: 79 Mb (total: 1714 Mb)
; Memory block # 6: 54 Mb (total: 1768 Mb)
; Memory block # 7: 41 Mb (total: 1809 Mb)
; Memory block # 8: 39 Mb (total: 1848 Mb)
; Memory block # 9: 31 Mb (total: 1879 Mb)
; Memory block #10: 16 Mb (total: 1895 Mb)
;
; (Note that the output may have fewer than 10 blocks of memory) 
;-
pro memtest
  compile_opt idl2 ; set default integers to 32-bit and enforce [] for indexing

  MB = 2^20
  currentBlockSize = MB * 2047   ; 2 GB
  maxIterations = 10             ; Max loop iterations
  memPtrs = ptrarr(maxIterations)
  memBlockSizes = ulonarr(maxIterations)

  for i=0, maxIterations-1 do begin
  ; Error handler
    catch, err

    ; Sepcifically designed for "Failure to allocate memory..." error
    if (err ne 0) then begin
      currentBlockSize = currentBlockSize - MB     ; ...try 1 MB smaller allocation
      if (currentBlockSize lt MB) then break  ; Give up, if currentBlockSize < 1 MB
    endif

  ; This 'wait' enables Ctrl-Break to interrupt if necessary (Windows).
    wait, 0.0001

  ; Allocate memory (if possible)
    memPtrs[i] = ptr_new(bytarr(currentBlockSize, /nozero), /no_copy)
    memBlockSizes[i] = currentBlockSize   ; Store the latest successful allocation size

  ; Print the current allocated block size and the running total, in Mb
    print, format='(%"Memory block #%2d: %4d Mb (total: %4d Mb)")', $
      i + 1, ishft(currentBlockSize, -20), ishft(ulong(total(memBlockSizes)), -20)
  endfor

  ptr_free,memPtrs
end