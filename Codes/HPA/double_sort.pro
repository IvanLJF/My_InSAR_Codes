

;+

; :Description:

;    Double Sort

;

; :Input:

;    arr: input array format: 2*N

;    idx: 0 - Sort by column one firstly

;          1 - Sort by column two firstly

;

; :Output:

;    output array: 2*N;

;   

; :Example:

;    arr = [[2,4],[3,4],[7,1],[6,6],[9,6],[2,5],[5,4]]

;    arrNew = double_sort(arr, 1)

;

; :Author: duhj@esrichina.com.cn

;-

 

FUNCTION DOUBLE_SORT, arr, idx

 

  COMPILE_OPT idl2

  ;

  ;判断输入数组是否为2*N

  IF N_ELEMENTS(arr) LT 1 THEN BEGIN

    MESSAGE, 'Incorrect number of arguments', /continue

    RETURN, 0

  ENDIF ELSE BEGIN

    IF (SIZE(arr,/DIMENSIONS))[0] NE 2 THEN BEGIN

      MESSAGE, 'Please input array with 2*N dimensions', /continue

      RETURN, 0

    ENDIF

  ENDELSE
 

  ;判断按第几列排序，默认为0

  ;0 --- 按第一列先排序

  ;1 --- 按第二列先排序

  IF N_ELEMENTS(idx) LT 1 THEN BEGIN

    idx = 0

  ENDIF ELSE BEGIN

    IF idx NE 0 AND idx NE 1 THEN BEGIN

      MESSAGE, 'Input index must be one of the value:0,1', /continue

      RETURN, 0

    ENDIF

  ENDELSE

 

  arr1 = arr[1-idx,*]

  arr2 = arr[idx,*]

 

  arr1sort = arr1[SORT(arr2)]

  arr2sort = arr2[SORT(arr2)]

 

  R = HISTOGRAM(arr2[SORT(arr2)], location = loc)

 

  eValue = loc[WHERE(HISTOGRAM(arr2[SORT(arr2)]) GT 1)]

 
  FOR i=0, n_ELEMENTS(evalue)-1 DO BEGIN
    
;    IF ~ (i MOD 10000) THEN Print, STRCOMPRESS(i)+'/'+STRCOMPRESS(N_ELEMENTS(evalue)-1)
    Print, i, N_ELEMENTS(evalue)
    element=evalue[i]
    eIdx = WHERE(arr2[SORT(arr2)] EQ element)

    arr1sort[eIdx] = (arr1sort[eIdx])[SORT(arr1sort[eIdx])]

  ENDFOR

 

  arrNew = arr

  arrNew[1-idx,*] = arr1sort

  arrNew[idx,*] = arr2sort

 

  RETURN, arrNew

END
