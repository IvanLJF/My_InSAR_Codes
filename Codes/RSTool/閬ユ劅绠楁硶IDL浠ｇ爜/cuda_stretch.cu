#include <stdio.h>  
#include <time.h>
#include "export.h"
#include <cuda.h>
#include <cutil.h>

#define FUNCTION 1 // set to 0 for a DLM procedure
#define NN 16 // block dimension

/*  DLM for image contrast stretching on CUDA, called from IDL as   
	  CUDA_STRETCH, LUT, IMIN, IMOUT  (procedure)
	  IMOUT = CUDA_STRETCH(LUT, IMIN) (function)
    where 
	  LUT is a byte lookup table, 
      IMIN is an image band (byte format),
      IMOUT is the contrast stetched result.

    Mort Canty (2010) (with thanks to Jia Tse, 
	          University of Nevada, Las Vegas)

The kernel 
*/
	__global__ void cu_stretch(unsigned char *lut, unsigned char *imin, 
		                       unsigned char *imout, int width, int height)
	{
		int col = blockIdx.x * blockDim.x + threadIdx.x;
		int row = blockIdx.y * blockDim.y + threadIdx.y;
		if (row < 0 || col < 0 || row > height -1 || col > width -1 )
			return;
    // contrast stretch
        long idx = row * width + col;
		imout[idx] = lut[ imin[idx] ];	
	}

/*
The host routine
*/
#if FUNCTION
	IDL_VPTR IDL_CDECL cuda_stretch(int argc, IDL_VPTR argv[]) 
#else
	void IDL_CDECL cuda_stretch(int argc, IDL_VPTR argv[]) 
#endif
	{	 
		FILE *fp;
		fp=fopen("d:\\idl\\projects\\development\\stretch\\cuda_stretch.txt", "a");	
		fprintf (fp, "cuda_stretch ---------------------\n");

	// get the input image byte pointers
		unsigned char * img0Ptr = (unsigned char * ) argv[0]->value.arr->data;
		unsigned char * img1Ptr = (unsigned char * ) argv[1]->value.arr->data;

    // get the dimensions of input image band
		long ndim = argv[1]->value.arr->n_dim;
        long * dim = argv[1]->value.arr->dim;
        long cols = dim[0];
		long rows = dim[1];
    // create the output array
        IDL_VPTR ivOutArray;
		unsigned char * imgOutPtr = (unsigned char * ) IDL_MakeTempArray( (int) IDL_TYP_BYTE, ndim, 
			dim, IDL_ARR_INI_ZERO, &ivOutArray);	

		cudaEvent_t start,stop;
		float elapsedTime;

        fprintf (fp, "transferring arrays to device ...\ncols = %i rows = %i\n",cols,rows);
		cudaEventCreate(&start);
        cudaEventCreate(&stop);

		cudaEventRecord(start,0);
	// set up the device variables to hold the data from the host
		unsigned char *a0_d;		// Pointer to device array for LUT
		unsigned char *a1_d;		// Pointer to device array for image band
		unsigned char *a2_d;	    // Pointer to device array for image output
		const long N = cols * rows;	// Number of elements in arrays
		size_t size0 = 256;
		size_t size1 = N * sizeof(unsigned char);
		cudaMalloc((void **) &a0_d, size0);   // Allocate LUT array on device
		cudaMalloc((void **) &a1_d, size1);   // Allocate image band array on device
		cudaMalloc((void **) &a2_d, size1);   // Allocate output array on device

		cudaMemcpy(a0_d, img0Ptr, size0, cudaMemcpyHostToDevice);
		cudaMemcpy(a1_d, img1Ptr, size1, cudaMemcpyHostToDevice);

		cudaEventRecord(stop,0);
		cudaEventElapsedTime(&elapsedTime,start,stop);
		fprintf (fp, "time required   %3.1f ms\n", elapsedTime );

	// set up device configurations
		dim3 block(NN,NN);		
		dim3 grid (cols/NN +(cols%NN == 0 ? 0:1), rows/NN + (rows%NN == 0 ? 0:1));	

        fprintf (fp, "launching kernel ...\n");	     
    // launch the kernel
        cudaEventRecord(start,0);	
		cu_stretch <<< grid, block >>> (a0_d, a1_d, a2_d, cols, rows);
	// synchronize the threads 
		cudaThreadSynchronize();
		cudaEventRecord(stop,0);
		cudaEventSynchronize(stop);
		cudaEventElapsedTime(&elapsedTime,start,stop);
		fprintf (fp, "time required   %3.1f ms\n", elapsedTime );

        fprintf (fp, "transferring result to host ...\n");	
    // return result to the host
		cudaEventRecord(start,0);
		cudaMemcpy(imgOutPtr, a2_d, size1, cudaMemcpyDeviceToHost);
		cudaEventRecord(stop,0);
		cudaEventElapsedTime(&elapsedTime,start,stop);
		fprintf (fp, "time required   %3.1f ms\n", elapsedTime );
    // clean up
		cudaEventDestroy(start);
		cudaEventDestroy(stop);
		cudaFree(a0_d);
		cudaFree(a1_d);
		cudaFree(a2_d);
		fclose(fp);

#if FUNCTION 
        return ivOutArray;  
#else
		IDL_VarCopy(ivOutArray,argv[2]);
#endif
	}
	
// the entry point, which loads the routine into IDL 
        int IDL_Load(void) 
		{
#if FUNCTION 
        static IDL_SYSFUN_DEF2 function_addr[] = { 
        { (IDL_SYSRTN_GENERIC) cuda_stretch, "CUDA_STRETCH", 2, 2, 0, 0 } 
		}; 
        return IDL_SysRtnAdd(function_addr, IDL_TRUE, 1);  
#else 
        static IDL_SYSFUN_DEF2 procedure_addr[] = { 
        { (IDL_SYSRTN_GENERIC) cuda_stretch, "CUDA_STRETCH", 3, 3, 0, 0 } 
        }; 
        return IDL_SysRtnAdd(procedure_addr, IDL_FALSE, 1); 
#endif
        }
