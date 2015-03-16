#include <stdio.h>  
#include "export.h"
#include <cuda.h>
#include <cutil.h>

/* 
DLM for calculating NDVI on CUDA, called from IDL as   

	  CUDA_NDVI, NIR, RED, NDVI 

where NIR and RED are input spectral bands (byte) and ndvi is output (can be undefined)
*/

// the kernel 
	__global__ void cu_ndvi(unsigned char *a, unsigned char *b, float *out, int width, int height)
	{
		int col = blockIdx.x * blockDim.x + threadIdx.x;
		int row = blockIdx.y * blockDim.y + threadIdx.y;
		if (row < 0 || col < 0 || row > height -1 || col > width -1 )
			return;
		
		long idx = row * width + col;
		if (((float)a[idx] + (float)b[idx]) == 0) 
			out[idx] = 0.0;
		else
			out[idx] = ((float)a[idx] - (float)b[idx])/((float)a[idx] + (float)b[idx]);
	}

// the host (DLM) routine
	void IDL_CDECL cuda_ndvi(int argc, IDL_VPTR argv[]) 
	{	 
	// grab the input image byte pointers
		unsigned char * img0Ptr = (unsigned char * ) argv[0]->value.arr->data;
		unsigned char * img1Ptr = (unsigned char * ) argv[1]->value.arr->data;

    // get the dimensions (same for all three arrays)
		IDL_LONG ndim = argv[0]->value.arr->n_dim;
        IDL_LONG * dim = argv[0]->value.arr->dim;
        IDL_LONG cols = dim[0];
		IDL_LONG rows = dim[1];
    // create the output array
        IDL_VPTR ivOutArray;
		float * imgOutPtr = (float * ) IDL_MakeTempArray( (int) IDL_TYP_FLOAT, ndim, 
			dim, IDL_ARR_INI_ZERO, &ivOutArray);				

	//Setting up the device variables to hold the data from the host
		unsigned char * a0_d;		// Pointer to device array for image 0
		unsigned char * a1_d;		// Pointer to device array for image 1
		float * a2_d;		        // Pointer to device array for image output
		const long N = cols * rows;	// Number of elements in arrays
		size_t size = N * sizeof(unsigned char);
		cudaMalloc((void **) &a0_d, size);   // Allocate array on device
		cudaMalloc((void **) &a1_d, size);   // Allocate array on device
		cudaMalloc((void **) &a2_d, N * sizeof(float));   // Allocate array on device, can be left blank

		cudaMemcpy(a0_d, img0Ptr, size, cudaMemcpyHostToDevice);
		cudaMemcpy(a1_d, img1Ptr, size, cudaMemcpyHostToDevice);

	// Setting up device configurations
		dim3 block(16,16);		//16 X 16 blocks for a total of 256 threads
		dim3 grid (cols/16 +(cols%16 == 0 ? 0:1), rows/16 + (rows%16 == 0 ? 0:1));	

    //Actual call to the device for processing.
		cu_ndvi <<< grid, block >>> (a0_d, a1_d, a2_d, cols, rows);
	//Synchronize the threads and stop the timer
		cudaThreadSynchronize();

		cudaMemcpy(imgOutPtr, a2_d, sizeof(float)*N, cudaMemcpyDeviceToHost);

	//	copy the temporary array to the IDL output parameter
		IDL_VarCopy(ivOutArray,argv[2]);

		cudaFree(a0_d);
		cudaFree(a1_d);
		cudaFree(a2_d);
	}
	
// the entry point, which loads the routine into IDL 
	    int IDL_Load(void) 
    { 
       static IDL_SYSFUN_DEF2 procedure_addr[] = { 
        { (IDL_SYSRTN_GENERIC) cuda_ndvi, "CUDA_NDVI", 0, 3, 0, 0 } 
       }; 
       return IDL_SysRtnAdd(procedure_addr, IDL_FALSE, 1); 
    }  