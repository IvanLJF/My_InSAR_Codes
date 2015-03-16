#include <stdio.h>  
#include "export.h"
#include <cula.h>
#define min(a,b) (((a) < (b)) ? (a) : (b))

/*  DLM for single precision SVD on CUDA, called from IDL as   
	  CUDA_SVD, A, W, U, VT 
    where 
       A is an M rows by N cols IDL array (input)
       S is a min(M,N) array of singular values (output)
       U is an N by min(M,N) array (output)      
       VT is an min(M,N) by M array (output)
       such that A = U diag(S) VT
    This DLM encapsulates the CULA basic function culaSgesvd
	It is programmed, unnecessarily since there is no device 
	code (yet), as a CUDA C project.  
	NOTE: The input is an n by m IDL array representing AT
	      in column major form as required by culaSgesvd.
		  Since AT = V diag(S) UT CULA will return S, V, UT.
		  Therefore, switching the last two, the output 
		  IDL arrays are S, UT, V which represent the matrices
		  S, U VT.

	                                 Mort Canty (2010) 
*/
	void IDL_CDECL cuda_svd(int argc, IDL_VPTR argv[]) 
	{
    // output array pointers 
		float * w, * u, * vt;
	// get the input matrix 
		float * a = (float *) argv[0]->value.arr->data;
    // get its dimensions
		long ndim_a = argv[0]->value.arr->n_dim;
        long * dim_a = argv[0]->value.arr->dim;
        int m = (int) dim_a[0];
		int n = (int) dim_a[1];

    // IDL output arrays
		IDL_VPTR ivWptr;
		long ndim_w = 1;
		long  dim_w[] = {min(m,n)};
		w = (float * ) IDL_MakeTempArray( (int) IDL_TYP_FLOAT, ndim_w, 
			dim_w, IDL_ARR_INI_ZERO, &ivWptr);

        IDL_VPTR ivUptr;
		long dim_u[] = {m,min(m,n)};
		u = (float * ) IDL_MakeTempArray( (int) IDL_TYP_FLOAT, ndim_a, 
			dim_u, IDL_ARR_INI_ZERO, &ivUptr);

		IDL_VPTR ivVTptr;
		long dim_v[] = {min(m,n),n};
		vt = (float * ) IDL_MakeTempArray( (int) IDL_TYP_FLOAT, ndim_a, 
			dim_v, IDL_ARR_INI_ZERO, &ivVTptr);

    // CULA general single precision SVD with host pointers
		culaStatus s = culaInitialize();
		if(s == culaNoError) 
		{
		    s = culaSgesvd('S','S',m,n,a,m,w,u,m,vt,min(m,n));
            culaShutdown();
		} 
	// return results to IDL (all zeroes if CULA failed to initialize)
        IDL_VarCopy(ivWptr,argv[1]);
        IDL_VarCopy(ivVTptr,argv[2]);
        IDL_VarCopy(ivUptr,argv[3]);	
	}
	
// the entry point, which loads the routine into IDL 
    int IDL_Load(void) 
		{
           static IDL_SYSFUN_DEF2 procedure_addr[] = { 
            { (IDL_SYSRTN_GENERIC) cuda_svd, "CUDA_SVD", 4, 4, 0, 0 } 
           }; 
        return IDL_SysRtnAdd(procedure_addr, IDL_FALSE, 1); 
        }
