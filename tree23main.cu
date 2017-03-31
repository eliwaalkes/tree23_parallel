#include <stdlib.h>
#include <stdio.h>
#include "tree23_array_h.cu"
#include "tree23_array_d.cu"
#include "timerc.h"
#include <iostream>

const int treeSize = 10;
const int insertSize = 4;

#define gpuErrchk(ans) { gpuAssert((ans), __FILE__, __LINE__); }
inline void gpuAssert(cudaError_t code, const char *file, int line, bool abort=true)
{
  if (code != cudaSuccess)
	{
	  fprintf(stderr,"GPUassert: %s %s %d\n", cudaGetErrorString(code), file, line);
	  if (abort) exit(code);
	}
}

__global__ void gpuInsert( int *t, int *insert, int start, int end, int insertPerBlock ){

  //__shared__ int startIndices[gridDim.x];
  // __shared__ int endIndices[gridDim.x];

  int tid = threadIdx.x;
  int bid = blockIdx.x;
  int root = getChild0(t, 0);
  insert = insert + (insertPerBlock*bid);
  /*
  if( tid < insertPerBlock ){
	int spot = findSpot_arr_d(t, root, insert[tid]);
	if(t[getKey0(t, spot)] < insert[tid]){
	  //start[tid] = getChild0(t, spot);
	  //end[tid] = getChild1(t, spot);}
	else{
	  //start[tid] = getChild0(t, spot);
	  //end[tid] = getChild1(t, spot);
	}
  }
  */
  

}


__global__ void findSpots_gpu( int *t, int *insert, int *startInd, int *endInd, int insertPerBlock ){

  //__shared__ int startIndices[insertPerBlock];
  //__shared__ int endIndices[insertPerBlock];

  int tid = threadIdx.x;
  int bid = blockIdx.x;
  int root = getChild0(t, 0);
  insert = insert + (insertPerBlock*bid);
  startInd = startInd + (insertPerBlock*bid);
  endInd = endInd + (insertPerBlock*bid);
  
  if( tid < insertPerBlock ){
	int spot = findSpot_arr_d(t, root, insert[tid]);
	if(t[getKey0(t, spot)] < insert[tid]){
	  startInd[tid] = getChild0(t, spot);
	  endInd[tid] = getChild1(t, spot);}
	else{
	  startInd[tid] = getChild0(t, spot);
	  endInd[tid] = getChild1(t, spot);
	}
  }

}


int main(){


    //INSERT SET
  int *insertSet = (int *) malloc(insertSize*sizeof(int));
  for(int i = 0; i < insertSize; i++)
	insertSet[i] = 2*i+1;

  /*
  //CREATE INITAL TREES
  int *tCPU = (int *) malloc(14*(treeSize+insertSize)*sizeof(int));

  createRoot_arr(tCPU);
  for(int i = 1; i < treeSize; i++){
	insert_arr(tCPU, 0, 2*i);
  }

  //TIMING VARIABLES
  float cputime;
  
  //CPU INSERT
  cstart();
  for(int i = 0; i < insertSize; i++)
	insert_arr(tCPU, 0, insertSet[i]);
  cend(&cputime);

  print_tree(tCPU);
  */
 
 
  //GPU SETUP
  // reset global variables
  float gputime;
  offsetTotal_h = 0;
  numNodes = 0;
  int *tGPU = (int *) malloc(14*(treeSize+insertSize)*sizeof(int));
  createRoot_arr(tGPU);
  for(int i = 1; i < treeSize; i++){
	insert_arr(tGPU, 0, 2*i);
  }
  //int start = insert_arr_index(tGPU, 0, insertArray[0]);
  //int end = insert_arr_index(tGPU, 0, insertArray[insertSize-1]);

  int num_blocks = 1;
  int threads_per_block = 1024;

  
  int *d_t23;
  int *d_insert;
  int *startInd_d;
  int *endInd_d;

  cudaMalloc( (void**)&d_t23, (treeSize+insertSize)*14*sizeof(int));
  cudaMalloc( (void**)&d_insert, insertSize*sizeof(int));
  cudaMalloc( (void**)&startInd_d, insertSize*sizeof(int));
  cudaMalloc( (void**)&endInd_d, insertSize*sizeof(int));  

  cudaMemcpy(  d_t23 , tGPU , (treeSize)*14*sizeof(int) , cudaMemcpyHostToDevice );
  cudaMemcpy(  d_insert , insertSet , (insertSize)*sizeof(int) , cudaMemcpyHostToDevice );


  int insertPerBlock = treeSize/num_blocks;  
  //gpuInsert<<< num_blocks, threads_per_block >>>( d_t23, d_insert, start, end, insertPerBlock );
  findSpots_gpu<<< num_blocks, threads_per_block >>>( d_t23, d_insert, startInd_d, endInd_d, insertPerBlock);
  
  int *startInd_h = (int *) malloc(insertSize*sizeof(int));
  int *endInd_h = (int *) malloc(insertSize*sizeof(int));
  int *t23_out = (int *) malloc((insertSize+treeSize)*14*sizeof(int));
  cudaMemcpy( (void*) t23_out , (void*) d_t23, (treeSize+insertSize)*14*sizeof(int) , cudaMemcpyDeviceToHost );
  cudaMemcpy( (void*) endInd_h , (void*) endInd_d, (insertSize)*sizeof(int) , cudaMemcpyDeviceToHost );
  cudaMemcpy( (void*) startInd_h , (void*) startInd_d, (insertSize)*sizeof(int) , cudaMemcpyDeviceToHost );


  for(int i =0; i < insertSize; i++)
	printf("startInd[%d] = %d, endInd[%d] = %d\n", i, startInd_h[i], i, endInd_h[i]);
  
  //print_tree(tCPU);
  //  print_inorder(tCPU,0);

  //printf("\n-----------------------\n");
  //print_tree(t23_out);
 
  return 0;

}
