#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>


__host__ __device__int getKey0 (int *arr, int index){
  return arr[ index + 1 ];
}
__host__ __device__ int getKey1 (int *arr, int index){
  return arr[ index + 2 ];
}
__host__ __device__ int getParent (int *arr, int index){
  return arr[ index + 3 ];
}
__host__ __device__ int getChild0 (int *arr, int index){
  return arr[ index + 4 ];
}
__host__ __device__ int getChild1 (int *arr, int index){
  return arr[ index + 5 ];
}
__host__ __device__ int getChild2 (int *arr, int index){
  return arr[ index + 6 ];
}
__host__ __device__ int key0Index(int index){
  return index+1;
}
__host__ __device__ int key1Index(int index){
  return index+2;
}
__host__ __device__ int parentIndex(int index){
  return index+3;
}
__host__ __device__ int child0Index(int index){
  return index+4;
}
__host__ __device__ int child1Index(int index){
  return index+5;
}
__host__ __device__ int child2Index(int index){
  return index+6;
}

// Check if node is a leaf
__host__ __device__ bool isLeaf_arr(int *arr, int index)
{
  //printf("isLeaf\n");
  return (getChild0(arr,index) == -2);
}

__host__ __device__ int getSmallest_arr(int *arr, int index)
{
  //printf("getSmallest\n");
  while (!isLeaf_arr(arr, index)) index += 7;
  return getChild0(arr,index);
}

// Get which sibling the node is
__host__ __device__ int sibNumber_arr(int *arr, int index)
{
  //printf("sibNum\n");
  int parent = getParent(arr, index);
  int child0 = getChild0(arr, parent);
  for (int i = 0; i < 3; ++i) {
	int check = arr[child0+i]; //arr[index+3] is index of parent, +4 gives index of first child, i iterates through 2nd/3rd children indicies 
	if (index == check) return i;
  }
  return -1;
}


// Update the parent nods efor the smallest child value
__host__ __device__ void updateParentSmallest_arr(int* arr, int index, int data)
{
  //printf("updateSmallestParent \n");
  int sibs = sibNumber_arr(arr, index);
  int p1 = getParent(arr, index);
  if(sibs == 0){
	int p2 = getParent(arr, p1);
	if ( p2 != -2 ) updateParentSmallest_arr(arr, p1, data);
	return; 
  }
  if(sibs == 1){
	int k0 = key0Index(p1);
	arr[k0] = data;
	return;
  }
  if(sibs == 2){
	int k1 = key1Index(p1);
	arr[k1] = data;
	return;
  }
}
