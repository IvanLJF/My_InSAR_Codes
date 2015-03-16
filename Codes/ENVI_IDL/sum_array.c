/*
 * $Id: //depot/idl/releases/IDL_80/idldir/external/call_external/C/sum_array.c#1 $
 *	
 *
 * NAME:
 * 	sum_array.c
 *
 * PURPOSE:
 *	This C function is used to demonstrate how to read an IDL vector.
 *      It calculates the sum of the array elements passed in.
 *
 *      this is equivalent to the IDL statement:
 *      IDL>r = TOTAL(arr)
 *
 * CATEGORY:
 *	Dynamic Linking Examples
 *
 * CALLING SEQUENCE:
 *	This function is called in IDL by using the following commands:
 *
 *      IDL>arr =  FINDGEN(10)
 *      IDL>r = CALL_EXTERNAL(library_file, 'sum_array', arr, /F_VALUE,
 *                            VALUE=[0,1])
 *
 *      See sum_array.pro for a more complete calling sequence.
 *
 * INPUTS:
 *      arr - an IDL array (type is float)
 *
 * OUTPUTS:
 *	The function returns the sum of all of the elements of the
 *      subsection of the array.
 *
 * SIDE EFFECTS:
 *	None.
 *
 * RESTRICTIONS:
 *
 *      None.
 *
 * MODIFICATION HISTORY:
 *	Written May, 1998 JJG
 *	AB, 11 April 2002, Updated for MAKE_DLL and general cleanup.
*/

#include <stdio.h>
#include "idl_export.h"



float sum_array_natural(float *fp, IDL_LONG n)
/*
 * Version with natural C interface. This version can be called directly
 * by IDL using the AUTO_GLUE keyword to CALL_EXTERNAL.
 *
 * entry:
 *	arr - Pointer to array of floating values
 *	n - # of elements in arr.
 *
 * exit:
 *	Return sum of indicated array elements.
 */     
{
  float s = 0.0;
  
  while (n--) s += *fp++;
  return(s);
}







float sum_array(int argc, void *argv[])
/* 
 * Version with IDL portable calling convension.
 *
 * entry:
 *	argc - Must be 2.
 *	argv[0] - Address of array of float values.
 *	argv[1] - # of data elements
 *
 * exit:
 *	Return sum of indicated array elements.
 */
{
  return sum_array_natural((float *) argv[0], (IDL_LONG) argv[1]);
}
