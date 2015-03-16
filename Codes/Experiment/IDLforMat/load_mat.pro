;+
; NAME:
;
;   LOAD_MAT
;
; PURPOSE:
;
;   Read MATLAB MAT-files in IDL (see README for more information).
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;   PRO load_mat, <filename>, <path>, STORE_LEVEL=store_level, $
;                 VERBOSE=verbose, DEBUG=debug
;
; MODIFICATION HISTORY:
;
;   See changelog.
;
; COPYRIGHT:
;
;   Copyright (C) 2009 Gordon Farquharson <gordonfarquharson@gmail.com>
;
;   This program is free software: you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, either version 3 of the License, or
;   (at your option) any later version.
;
;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.
;      
;   You should have received a copy of the GNU General Public License
;   along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
;-

FUNCTION size_of_data_type, data_symbol

    SWITCH data_symbol OF
        'miINT8'   :
        'miUINT8'  :
        'miUTF8'   : return, 1
        'miINT16'  :
        'miUINT16' :
        'miUTF16'  : return, 2
        'miINT32'  :
        'miUINT32' :
        'miUTF32'  :
        'miSINGLE' : return, 4
        'miINT64'  :
        'miUINT64' :
        'miDOUBLE' : return, 8
    ENDSWITCH

END

PRO skip_padding_bytes, lun, DEBUG=debug

    ;; All data elements are aligned on a 64 bit boundary. Calculate
    ;; how many padding bytes exist, and advance the file pointer
    ;; appropriately.

    point_lun, -lun, position

    IF (position MOD 8) NE 0 THEN BEGIN

        number_OF_padding_bytes = 8 - (position MOD 8)

        IF keyword_set(debug) THEN $
            print, 'Skipping ', number_of_padding_bytes, ' bytes'

        padding_bytes = bytarr(number_of_padding_bytes)
        readu, lun, padding_bytes

    ENDIF

END

PRO read_int8_data, lun, element_tag, data

    ;; FIXME: Not sure how to represent signed 8-bit data in IDL.

    number_of_elements = element_tag.number_of_bytes / $
                         size_of_data_type(element_tag.data_symbol)
    data = bytarr(number_of_elements)
    readu, lun, data

END

PRO read_uint8_data, lun, element_tag, data

    number_of_elements = element_tag.number_of_bytes / $
                         size_of_data_type(element_tag.data_symbol)
    data = bytarr(number_of_elements)
    readu, lun, data

END

PRO read_int16_data, lun, element_tag, data

    number_of_elements = element_tag.number_of_bytes / $
                         size_of_data_type(element_tag.data_symbol)
    data = intarr(number_of_elements)
    readu, lun, data

END

PRO read_uint16_data, lun, element_tag, data

    number_of_elements = element_tag.number_of_bytes / $
                         size_of_data_type(element_tag.data_symbol)
    data = uintarr(number_of_elements)
    readu, lun, data

END

PRO read_int32_data, lun, element_tag, data

    number_of_elements = element_tag.number_of_bytes / $
                         size_of_data_type(element_tag.data_symbol)
    data = lonarr(number_of_elements)
    readu, lun, data

END

PRO read_uint32_data, lun, element_tag, data

    number_of_elements = element_tag.number_of_bytes / $
                         size_of_data_type(element_tag.data_symbol)
    data = ulonarr(number_of_elements)
    readu, lun, data

END

PRO read_single_data, lun, element_tag, data

    number_of_elements = element_tag.number_of_bytes / $
                         size_of_data_type(element_tag.data_symbol)
    data = fltarr(number_of_elements)
    readu, lun, data

END

PRO read_double_data, lun, element_tag, data

    number_of_elements = element_tag.number_of_bytes / $
                         size_of_data_type(element_tag.data_symbol)
    data = dblarr(number_of_elements)
    readu, lun, data

END

PRO read_int64_data, lun, element_tag, data

    number_of_elements = element_tag.number_of_bytes / $
                         size_of_data_type(element_tag.data_symbol)
    data = lon64arr(number_of_elements)
    readu, lun, data

END

PRO read_uint64_data, lun, element_tag, data

    number_of_elements = element_tag.number_of_bytes / $
                         size_of_data_type(element_tag.data_symbol)
    data = ulon64arr(number_of_elements)
    readu, lun, data

END

PRO read_utf8_data, lun, element_tag, data

    data = bytarr(element_tag.number_of_bytes)
    readu, lun, data

END

PRO read_utf16_data, lun, element_tag, data

    data = intarr(element_tag.number_of_bytes)
    readu, lun, data

END

PRO read_utf32_data, lun, element_tag, data

    data = lonarr(element_tag.number_of_bytes)
    readu, lun, data

END

PRO skip_unknown_data, lun, element_tag

    data_bytes = bytarr(element_tag.number_of_bytes)
    readu, lun, data_bytes

END

FUNCTION element_tag_struct

    return, { mat_v5_element_tag, $
              data_type             : 0UL, $
              data_type_description : '', $
              data_symbol           : '', $
              number_of_bytes       : 0UL, $
              small_element_format  : 0B $
            }

END

PRO read_element_tag, lun, element_struct, DEBUG=debug

    data_type = 0UL
    number_of_bytes = 0UL

    readu, lun, data_type

    IF (data_type AND 'FFFF0000'XUL) EQ 0UL THEN BEGIN

        readu, lun, number_of_bytes

        element_struct.data_type = data_type
        element_struct.number_of_bytes = number_of_bytes
        element_struct.small_element_format = 0B

    ENDIF ELSE BEGIN

        ;; Small data element format

        element_struct.number_of_bytes = $
            ishft(data_type AND 'FFFF0000'XUL, -16)
        element_struct.data_type = data_type AND '0000FFFF'XUL
        element_struct.small_element_format = 1B

    ENDELSE

    data_type_description = ''
    data_symbol = ''

    CASE element_struct.data_type OF
        1  : BEGIN
            data_type_description = '8 bit, signed'
            data_symbol = 'miINT8'
        END
        2  : BEGIN
            data_type_description = '8 bit, unsigned'
            data_symbol = 'miUINT8'
        END
        3  : BEGIN
            data_type_description = '16 bit, signed'
            data_symbol = 'miINT16'
        END
        4  : BEGIN
            data_type_description = '16 bit, unsigned'
            data_symbol = 'miUINT16'
        END
        5  : BEGIN
            data_type_description = '32 bit, signed'
            data_symbol = 'miINT32'
        END
        6  : BEGIN
            data_type_description = '32 bit, unsigned'
            data_symbol = 'miUINT32'
        END
        7  : BEGIN
            data_type_description = 'IEEE 754 single format'
            data_symbol = 'miSINGLE'
        END
        8  : BEGIN
            data_type_description = 'Reserved (8)'
            data_symbol = ''
        END
        9  : BEGIN
            data_type_description = 'IEEE 754 double format'
            data_symbol = 'miDOUBLE'
        END
        10 : BEGIN
            data_type_description = 'Reserved'
            data_symbol = ''
        END
        11 : BEGIN
            data_type_description = 'Reserved'
            data_symbol = ''
        END
        12 : BEGIN
            data_type_description = '64 bit, signed'
            data_symbol = 'miINT64'
        END
        13 : BEGIN
            data_type_description = '64 bit, unsigned'
            data_symbol = 'miUINT64'
        END
        14 : BEGIN
            data_type_description = 'MATLAB array'
            data_symbol = 'miMATRIX'
        END
        15 : BEGIN
            data_type_description = 'Compressed data'
            data_symbol = 'miCOMPRESSED'
        END
        16 : BEGIN
            data_type_description = 'Unicode UTF-8 encoded character data'
            data_symbol = 'miUTF8'
        END
        17 : BEGIN
            data_type_description = 'Unicode UTF-16 encoded character data'
            data_symbol = 'miUTF16'
        END
        18 : BEGIN
            data_type_description = 'Unicode UTF-32 encoded character data'
            data_symbol = 'miUTF32'
        END
    ENDCASE

    element_struct.data_type_description = data_type_description
    element_struct.data_symbol = data_symbol

    IF element_struct.small_element_format THEN $
        small_element_text = 'True' $
    ELSE $
        small_element_text = 'False'

    IF keyword_set(DEBUG) THEN BEGIN
        print, 'Data type       : ', element_struct.data_type_description
        print, 'Data symbol     : ', element_struct.data_symbol
        print, 'Number of bytes : ', element_struct.number_of_bytes
        print, 'Small element   : ', small_element_text
    ENDIF

END

FUNCTION subelement_array_flags_struct

    return, { mat_v5_subelement_array_flags, $
              flag_word_1 : 0UL, $
              flag_word_2 : 0UL, $
              complex     : 0B, $
              global      : 0B, $
              logical     : 0B, $
              class       : 0B, $
              class_description : '', $
              class_symbol      : '' $
            }

END

PRO read_subelement_array_flags, lun, subelement_tag, subelement_struct, $
                                 DEBUG=debug

    flags1 = 0UL
    flags2 = 0UL

    readu, lun, flags1, flags2

    subelement_struct.flag_word_1 = flags1
    subelement_struct.flag_word_2 = flags2
    subelement_struct.complex = flags1 AND '00000800'XL
    subelement_struct.global = flags1 AND '00000400'XL
    subelement_struct.logical = flags1 AND '00000200'XL
    subelement_struct.class = flags1 AND '000000FF'XL

    IF keyword_set(debug) THEN BEGIN
        print, 'Complex           : ', subelement_struct.complex
        print, 'Global            : ', subelement_struct.global
        print, 'Logical           : ', subelement_struct.logical
    ENDIF

    class_description = ''
    class_symbol = ''

    CASE subelement_struct.class OF
        1 : BEGIN
            class_description = 'Cell array'
            class_symbol = 'mxCELL_CLASS'
        END
        2 : BEGIN
            class_description = 'Structure'
            class_symbol = 'mxSTRUCT_CLASS'
        END
        3 : BEGIN
            class_description = 'Object'
            class_symbol = 'mxOBJECT_CLASS'
        END
        4 : BEGIN
            class_description = 'Character array'
            class_symbol = 'mxCHAR_CLASS'
        END
        5 : BEGIN
            class_description = 'Sparse array'
            class_symbol = 'mxSPARSE_CLASS'
        END
        6 : BEGIN
            class_description = 'Double precision array'
            class_symbol = 'mxDOUBLE_CLASS'
        END
        7 : BEGIN
            class_description = 'Single precision array'
            class_symbol = 'mxSINGLE_CLASS'
        END
        8 : BEGIN
            class_description = '8-bit, signed integer'
            class_symbol = 'mxINT8_CLASS'
        END
        9 : BEGIN
            class_description = '8-bit, unsigned integer'
            class_symbol = 'mxUINT8_CLASS'
        END
        10 : BEGIN
            class_description = '16-bit, signed integer'
            class_symbol = 'mxINT16_CLASS'
        END
        11 : BEGIN
            class_description = '16-bit, unsigned integer'
            class_symbol = 'mxUINT16_CLASS'
        END
        12 : BEGIN
            class_description = '32-bit, signed integer'
            class_symbol = 'mxINT32_CLASS'
        END
        13 : BEGIN
            class_description = '32-bit, unsigned integer'
            class_symbol = 'mxUINT32_CLASS'
        END
    ENDCASE

    subelement_struct.class_description = class_description
    subelement_struct.class_symbol = class_symbol

    IF keyword_set(debug) THEN BEGIN
        print, 'Class description : ', subelement_struct.class_description
        print, 'Class symbol      : ', subelement_struct.class_symbol
    ENDIF

END

FUNCTION subelement_dimensions_array_struct

    ;; I think that IDL allows a maximum of 8 dimensions.

    return, { mat_v5_subelement_dimensions_array, $
              number_of_dimensions : 0L, $
              dimensions           : lonarr(8) $
            }

END

PRO read_subelement_dimensions_array, lun, subelement_tag, subelement_struct, $
                                      DEBUG=debug

    number_of_dimensions = subelement_tag.number_of_bytes / $
                           size_of_data_type(subelement_tag.data_symbol)

    subelement_struct.number_of_dimensions = number_of_dimensions
    
    ;; I don't know if this case statement is necessary. The
    ;; documentation is not clear on whether the dimensions array type
    ;; is always miINT32.

    dimensions = lonarr(number_of_dimensions)

    CASE size_of_data_type(subelement_tag.data_symbol) OF
        1 : BEGIN
            dimension = 0B
            FOR i = 0, number_of_dimensions-1 DO BEGIN
                readu, lun, dimension
                dimensions[i] = dimension
            ENDFOR
        END
        2 : BEGIN
            dimension = 0
            FOR i = 0, number_of_dimensions-1 DO BEGIN
                readu, lun, dimension
                dimensions[i] = dimension
            ENDFOR
        END
        4 : BEGIN
            dimension = 0L
            FOR i = 0, number_of_dimensions-1 DO BEGIN
                readu, lun, dimension
                dimensions[i] = dimension
            ENDFOR
        END
    ENDCASE

    subelement_struct.dimensions = dimensions

    IF keyword_set(debug) THEN BEGIN
        print, 'Number of dimensions : ', subelement_struct.number_of_dimensions
        print, 'Dimensions           : ', subelement_struct.dimensions
    ENDIF

    skip_padding_bytes, lun, DEBUG=debug

END

PRO read_subelement_array_name, lun, subelement_tag, array_name, DEBUG=debug

    ;; Assume that data type is always miINT8.

    array_name_bytes = bytarr(subelement_tag.number_of_bytes)
    readu, lun, array_name_bytes
    array_name = string(array_name_bytes)

    IF keyword_set(debug) THEN print, 'Array name : ', array_name

    skip_padding_bytes, lun, DEBUG=debug

END

PRO read_element_data, lun, element_tag, data, DEBUG=debug

    data_recognized = 1

    SWITCH element_tag.data_symbol OF

        'miINT8'       : BEGIN
            read_int8_data, lun, element_tag, data
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END

        'miUINT8'      : BEGIN
            read_uint8_data, lun, element_tag, data
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END

        'miINT16'      : BEGIN
            read_int16_data, lun, element_tag, data
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END

        'miUINT16'     : BEGIN
            read_uint16_data, lun, element_tag, data
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END

        'miINT32'      : BEGIN
            read_int32_data, lun, element_tag, data
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END

        'miUINT32'     : BEGIN
            read_uint32_data, lun, element_tag, data
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END

        'miSINGLE'     : BEGIN
            read_single_data, lun, element_tag, data
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END

        'miDOUBLE'     : BEGIN
            read_double_data, lun, element_tag, data
            BREAK
        END

        'miINT64'      : BEGIN
            read_int64_data, lun, element_tag, data
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END

        'miUINT64'     : BEGIN
            read_uint64_data, lun, element_tag, data
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END

        'miMATRIX'     :
        'miCOMPRESSED' : BEGIN
            print, '*** ', element_tag.data_symbol, ' NOT IMPLEMENTED ***'
            skip_unknown_data, lun, element_tag
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END

        'miUTF8'       : BEGIN
            read_utf8_data, lun, element_tag, data
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END

        'miUTF16'      : BEGIN
            read_utf8_data, lun, element_tag, data
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END

        'miUTF32'      : BEGIN
            read_utf8_data, lun, element_tag, data
            skip_padding_bytes, lun, DEBUG=debug
            BREAK
        END
        
        ELSE           : BEGIN
            skip_unknown_data, lun, element_tag
            skip_padding_bytes, lun, DEBUG=debug
            data_recognized = 0
        END

    ENDSWITCH

    skip_padding_bytes, lun, DEBUG=debug

    IF keyword_set(debug) THEN BEGIN
        IF data_recognized THEN $
            print, 'Data : ', data $
        ELSE $
            print, 'UNKNOWN DATA ELEMENT'
    ENDIF

END

FUNCTION format_array_element_data, data, array_flags, dimensions_array

    dimensions = $
        dimensions_array.dimensions[0:dimensions_array.number_of_dimensions-1]

    ;; Prevent 1x1 arrays from being created.

    IF size(data, /N_ELEMENTS) NE 1 THEN $
        _data = reform(reform(data, dimensions)) $
    ELSE $
        _data = data[0]

    CASE array_flags.class_symbol OF

        'mxCELL_CLASS'   : BEGIN
            print, '*** Formatting ', array_flags.class_symbol, $
                   ' not supported ***'
        END

        'mxSTRUCT_CLASS' : BEGIN
            print, '*** Formatting ', array_flags.class_symbol, $
                   ' not supported ***'
        END

        'mxOBJECT_CLASS' : BEGIN
            print, '*** Formatting ', array_flags.class_symbol, $
                   ' not supported ***'
        END

        'mxCHAR_CLASS'   : BEGIN
            data = string(_data)
        END

        'mxSPARSE_CLASS' : BEGIN
            print, '*** Formatting ', array_flags.class_symbol, $
                   ' not supported ***'
        END

        'mxDOUBLE_CLASS' : BEGIN
            IF array_flags.complex THEN $
                data = dcomplex(_data) $
            ELSE $
                data = double(_data)
        END

        'mxSINGLE_CLASS' : BEGIN
            IF array_flags.complex THEN $
                data = complex(_data) $
            ELSE $
                data = float(_data)
        END

        'mxINT8_CLASS'   : BEGIN
            print, '*** Formatting ', array_flags.class_symbol, $
                   ' not supported ***'
        END

        'mx_UINT8_CLASS' : BEGIN
            data = byte(_data)
        END

        'mxINT16_CLASS'  : BEGIN
            data = fix(_data, TYPE=2)
        END

        'mxUINT16_CLASS' : BEGIN
            data = uint(_data)
        END

        'mxINT32_CLASS'  : BEGIN
            data = long(_data)
        END

        'mxUINT32_CLASS' : BEGIN
            data = ulong(_data)
        END

    ENDCASE

    ;; Todo: transpose the data ?

    return, data

END

PRO load_mat, filename, path, STORE_LEVEL=store_level, $
              VERBOSE=verbose, DEBUG=debug

    header = { mat_v5_header, $
               description: "", $
               subsys_data_offset: 0ULL, $
               version: 0U, $
               endian_indicator: "" $
             }
filename='x_n.mat'
path='D:\ISEIS\Codes\EXPERIMENT\IDLforMat\'
    file = filepath(filename, ROOT_DIR=path)

    file_information = file_info(file)

    IF file_information.exists EQ 0 THEN BEGIN
        print, "File does not exist (", file, ")"
        return
    ENDIF

    IF file_information.directory EQ 1 THEN BEGIN
        print, "File is a directory (", file, ")"
        return
    ENDIF

    openr, lun, file, /GET_LUN

    ;; By default, create the variables on the $MAIN$ level

    IF NOT keyword_set(store_level) THEN store_level = 1

    IF keyword_set(debug) THEN BEGIN
        print
        print, '* Header'
    ENDIF

    ;; Todo: put this header code into a procedure

    description = bytarr(116)
    subsys_data_offset = 0ULL
    version = 0U
    endian_indicator = 0

    readu, lun, description
    readu, lun, subsys_data_offset
    readu, lun, version
    readu, lun, endian_indicator

    header.description = string(description)
    header.subsys_data_offset = subsys_data_offset
    header.version = version
    header.endian_indicator = $
        string(byte(ISHFT(endian_indicator AND 'FF00'XS, -8))) + $
        string(byte(endian_indicator AND '00FF'XS))

    IF keyword_set(DEBUG) THEN BEGIN
        print, 'Description           : ', header.description
        print, 'Subsystem data offset : ', $
               header.subsys_data_offset, FORMAT='(A,Z016)'
        print, 'Header version        : ', header.version, FORMAT='(A,Z04)'
        print, 'Endian                : ', header.endian_indicator
    ENDIF

    ;; Todo: must implement endian swapping

    data = 0
    data_element_number = 0

    WHILE NOT(eof(lun)) DO BEGIN

        IF keyword_set(debug) THEN BEGIN
            print, '=========================================================='
            print, '* Data Element ', data_element_number++
        ENDIF

        element_tag = element_tag_struct()
        read_element_tag, lun, element_tag, DEBUG=debug

        SWITCH element_tag.data_symbol OF

            'miMATRIX' : BEGIN

                ;; Array flags subelement

                IF keyword_set(debug) THEN BEGIN
                    print
                    print, '* Array flags subelement tag'
                ENDIF

                array_flags_tag = element_tag_struct()
                read_element_tag, lun, array_flags_tag, DEBUG=debug

                IF keyword_set(debug) THEN BEGIN
                    print, '* Array flags subelement data'
                ENDIF

                array_flags = subelement_array_flags_struct()
                read_subelement_array_flags, lun, array_flags_tag, array_flags, $
                                             DEBUG=debug

                ;; Dimensions array subelement

                IF keyword_set(debug) THEN BEGIN
                    print
                    print, '* Dimensions array subelement tag'
                ENDIF

                dimensions_array_tag = element_tag_struct()
                read_element_tag, lun, dimensions_array_tag, DEBUG=debug

                IF keyword_set(debug) THEN BEGIN
                    print, '* Dimensions array subelement data'
                ENDIF

                dimensions_array = subelement_dimensions_array_struct()
                read_subelement_dimensions_array, lun, dimensions_array_tag, $
                                                  dimensions_array, DEBUG=debug

                ;; Array name subelement

                IF keyword_set(debug) THEN BEGIN
                    print
                    print, '* Array name subelement tag'
                ENDIF

                array_name_tag = element_tag_struct()
                read_element_tag, lun, array_name_tag, DEBUG=debug

                IF keyword_set(debug) THEN BEGIN
                    print, '* Array name subelement data'
                ENDIF

                array_name = ''
                read_subelement_array_name, lun, array_name_tag, array_name, $
                                            DEBUG=debug

                IF keyword_set(verbose) THEN print, array_name

                ;; Real part (pr) subelement

                IF keyword_set(debug) THEN BEGIN
                    print
                    print, '* Real part (pr) subelement tag'
                ENDIF

                real_part_tag = element_tag_struct()
                read_element_tag, lun, real_part_tag, DEBUG=debug

                IF keyword_set(debug) THEN BEGIN
                    print, '* Real part (pr) subelement data'
                ENDIF

                read_element_data, lun, real_part_tag, real_data, DEBUG=debug

                data = real_data

                IF array_flags.complex THEN BEGIN

                    ;; Imaginary part (pi) subelement

                    IF keyword_set(debug) THEN BEGIN
                        print
                        print, '* Imaginary part (pi) subelement tag'
                    ENDIF

                    imag_part_tag = element_tag_struct()
                    read_element_tag, lun, imag_part_tag, DEBUG=debug

                    IF keyword_set(debug) THEN BEGIN
                        print, '* Imaginary part (pi) subelement data'
                    ENDIF

                    read_element_data, lun, imag_part_tag, imag_data, $
                                       DEBUG=debug

                    data = complex(real_data, imag_data)

                ENDIF

                data = format_array_element_data(data, array_flags, $
                                                 dimensions_array)
                
            END

        ENDSWITCH

        ;; Create a variable on the main level using the undocumented
        ;; IDL routine ROUTINE_NAMES. This only works for IDL 5.3 and
        ;; higher.

        foo = routine_names(array_name, data, STORE=store_level)

        IF keyword_set(debug) THEN BEGIN
            point_lun, -lun, current_file_position
            print, 'Current file position : ', current_file_position, $
                   FORMAT='(A, Z08)'
        ENDIF

    ENDWHILE

    close, lun
    free_lun, lun

END
