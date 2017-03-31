#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "tree23_array_help.cu"

int offsetTotal_h = 0;
int numNodes = 0;

__host__ int createNode_arr(int *arr, int offset, int data)
{
  arr[offset]   = offset;
  arr[offset+1] = data;
  arr[offset+2] = -1;
  arr[offset+3] = -2;
  arr[offset+4] = -2;
  arr[offset+5] = -2;
  arr[offset+6] = -2;
  
  numNodes++;
  offsetTotal_h += 7;

  return offset;
}

__host__ void insert_help_arr(int *arr, int index, int newChild, int newSmallest);

// Insert into a node with 1 child
__host__ void insert1Siblings_arr(int* arr, int index, int newChild, int newSmallest)
{
  //printf("1sib, index: %d, newchilde: %d, newSmallest: %d\n", index, newChild, newSmallest);
  int newKey = getKey0(arr, newChild);
  arr[parentIndex(newChild)] = index; //newChild->parent = node;

  if (newKey < getKey0(arr, getChild0(arr, index))) { //node->child[0]->key[0]
	// newNode is inserted as first child of root
	arr[child1Index(index)] = getChild0(arr,index); //node->child[1] = node->child[0];
	arr[child0Index(index)] = newChild; //node->child[0] = newChild;
	arr[key0Index(index)] = getSmallest_arr(arr, getChild1(arr, index)); //node->key[0] = getSmallest_d(node->child[1]);
  }
  else {
	// newNode is iserted as second child of root
	arr[child1Index(index)] = newChild; //node->child[1] = newChild;
	arr[key0Index(index)] = newSmallest; //node->key[0] = newSmallest;
  }
}


// Insert into a node with 2 children
__host__ void insert2Siblings_arr(int* arr, int index, int newChild, int newSmallest)
{
  //printf("2sibs\n");
  int newKey = getKey0(arr, newChild); //newChild->key[0];
  arr[parentIndex(newChild)] = index; //newChild->parent = node;

  if (newKey < getKey0(arr, getChild0(arr, index)) ) { //node->child[0]->key[0]) {
    arr[child2Index(index)] = getChild1(arr,index);  //node->child[2] = node->child[1];
	arr[child1Index(index)] = getChild0(arr,index); //node->child[1] = node->child[0];
	arr[child0Index(index)] = newChild; //node->child[0] = newChild;

	arr[key1Index(index)] = getKey0(arr, index); //node->key[1] = node->key[0];
	arr[key0Index(index)] = getSmallest_arr(arr, getChild1(arr, index));  //node->key[0] = getSmallest_d(node->child[1]);
	updateParentSmallest_arr(arr, index, newSmallest); //updateParentSmallest_d(node, newSmallest);
  }
  else if ( newKey < getKey0(arr, getChild1(arr, index)) ) {//(newKey < node->child[1]->key[0]) {
	arr[child2Index(index)] = getChild1(arr, index); //node->child[2] = node->child[1];
    arr[child1Index(index)] = newChild;  //node->child[1] = newChild;

	arr[key1Index(index)] = getKey0(arr, index); //node->key[1] = node->key[0];
	arr[key0Index(index)] = newSmallest; //node->key[0] = newSmallest;
  }
  else {
	arr[child2Index(index)] = newChild; //node->child[2] = newChild;
	arr[key1Index(index)] = newSmallest; //node->key[1] = newSmallest;
  }
}


// Insert into a node with 3 children
__host__ void insert3Siblings_arr(int *arr, int index, int newChild, int newSmallest) {
  //printf("3sibs\n");
  int newKey = getKey0(arr, newChild); //int newKey = newChild->key[0];
  int splitSmallest = -1;
  int splitNode = createNode_arr(arr, offsetTotal_h, -1);
  arr[parentIndex(splitNode)] = getParent(arr, index); //splitNode->parent = node->parent;

  if (newKey < getKey0(arr, getChild0(arr, index)) || newKey < getKey0(arr, getChild1(arr,index)) ) { //(newKey < node->child[0]->key[0] || newKey < node->child[1]->key[0]) {
	// newChild is inserted in current node
	splitSmallest = getKey0(arr,index); //splitSmallest = node->key[0];
	arr[child0Index(splitNode)] = getChild1(arr, index); //splitNode->child[0] = node->child[1];
	arr[child1Index(splitNode)] = getChild2(arr, index); //splitNode->child[1] = node->child[2];
	arr[key0Index(splitNode)] = getKey1(arr, index); //splitNode->key[0] = node->key[1];

	arr[parentIndex(getChild1(arr, index))] = splitNode; //node->child[1]->parent = splitNode;
	arr[parentIndex(getChild2(arr, index))] = splitNode; //node->child[2]->parent = splitNode;
	arr[parentIndex(newChild)] = index; //newChild->parent = node;

	if (newKey < getKey0(arr, getChild0(arr, index))) {//(newKey < node->child[0]->key[0]) {
	  // newChild is inserted as first child
	  arr[child1Index(index)] = getChild0(arr, index); //node->child[1] = node->child[0];
	  arr[child0Index(index)] = newChild; //node->child[0] = newChild;

	  arr[key0Index(index)] = getSmallest_arr(arr, getChild1(arr, index)); //node->key[0] = getSmallest_d(node->child[1]);
	  updateParentSmallest_arr(arr, index, newSmallest); //updateParentSmallest_d(node, newSmallest);
	}
	else {
	  // newChild is inserted as second child
	  arr[child1Index(index)] = newChild; //node->child[1] = newChild;
	  arr[key0Index(index)] = newSmallest; //node->key[0] = newSmallest;
	}
  }
  else {
	// newChild is inserted in split node
	arr[parentIndex(getChild2(arr, index))] = splitNode; //node->child[2]->parent = splitNode;
	arr[parentIndex(newChild)] = splitNode; //newChild->parent = splitNode;

	if (newKey < getKey0(arr, getChild2(arr, index)) ) { //(newKey < node->child[2]->key[0]) {
	  // newChild is inserted as first child
	  splitSmallest = newSmallest;
	  arr[child0Index(splitNode)] = newChild; //splitNode->child[0] = newChild;
	  arr[child1Index(splitNode)] = getChild2(arr, index); //splitNode->child[1] = node->child[2];
	  arr[key0Index(splitNode)] = getKey1(arr, index); //splitNode->key[0] = node->key[1];
	}
	else {
	  // newChild is inserted as second child
	  splitSmallest = getKey1(arr, index); //splitSmallest = node->key[1];
	  arr[child0Index(splitNode)] = getChild2(arr, index); //splitNode->child[0] = node->child[2];
	  arr[child1Index(splitNode)] = newChild; //splitNode->child[1] = newChild;
	  arr[key0Index(splitNode)] = newSmallest; //splitNode->key[0] = newSmallest;
	}
  }

  arr[child2Index(index)] = -2; //node->child[2] = NULL;
  arr[key1Index(index)] = -1; //node->key[1] = -1;

  if (getParent(arr, getParent(arr, index)) == -2) { //(node->parent->parent == NULL) {
	// At root, so new root needs to be created
	int newNode = createNode_arr(arr, offsetTotal_h, -1);
	//printf("new root: %d", newNode);
	//root = newNode;
	arr[child0Index(getParent(arr, index))] = newNode; //node->parent->child[0] = newNode;
	arr[parentIndex(newNode)] = getParent(arr, index); //newNode->parent = node->parent;
	arr[child0Index(newNode)] = index; //newNode->child[0] = node;
	arr[parentIndex(index)] = newNode; //node->parent = newNode;
  }
  
  insert_help_arr(arr, getParent(arr, index), splitNode, splitSmallest); //insert_help_d(node->parent, splitNode, splitSmallest);
}


__host__ int findSpot_arr(int *arr, int index, int data) {
  if (arr[index] == -2) return -2;

  //printf("findSpot index: %d, data: %d", index, data);
  int ind = index;
  int count = 0;
  while (!isLeaf_arr(arr,ind)) {
	//printf("findSpot ind: %d", ind);
	count++;
	if(count == 10)
	  break;
	if (getKey0(arr, ind) == data || getKey1(arr, ind) == data) //(node->key[0] == data || node->key[1] == data)
	  return -2;
	if (getKey0(arr,ind) == -1 || data < getKey0(arr,ind)) //(node->key[0] == -1 || data < node->key[0])
	  ind = getChild0(arr, ind);
	  //arr[index] = getChild0(arr, index); //node = node->child[0];
	else if (getKey1(arr,ind) == -1 || data < getKey1(arr,ind)) //(node->key[1] == -1 || data < node->key[1])
	  ind = getChild1(arr,ind); //node = node->child[1];
	else
	  ind = getChild2(arr,ind); //node = node->child[2];
  }

  if (getKey0(arr, ind) == data)//(node->key[0] == data)
	return -2;

  //printf("spot found: %d\n", getParent(arr,ind));
  return getParent(arr, ind); //node->parent;
}

// Insertion
__host__ void insert_help_arr(int *arr, int index, int newChild, int newSmallest)
{
  if (getChild1(arr,index) == -2) insert1Siblings_arr(arr, index, newChild, newSmallest); //(node->child[1] == NULL) insert1Siblings_d(node, newChild, newSmallest);
  else if (getChild2(arr, index) == -2) insert2Siblings_arr(arr, index, newChild, newSmallest); //else if (node->child[2] == NULL) insert2Siblings_d(node, newChild, newSmallest);
  else insert3Siblings_arr(arr, index, newChild, newSmallest);
}


__host__ void insert_arr(int *arr, int index, int data)
{
  int newNode = createNode_arr(arr, offsetTotal_h, data);
  int spot = getChild0(arr, index); //node->child[0];

  if (getChild0(arr,spot) == -2) { //spot->child[0] == NULL) {
	// First insertion
	arr[parentIndex(newNode)] = spot;//newNode->parent = spot;
	arr[child0Index(spot)] = newNode;//spot->child[0] = newNode;
  }
  else {
	spot = findSpot_arr(arr, spot, data);
	if (spot == -2) return;
	insert_help_arr(arr, spot, newNode, data);
  }

  return;
}


__host__ int insert_arr_d_index(int *arr, int index, int data)
{
  int newNode = createNode_arr(arr, offsetTotal_h, data);
  int spot = getChild0(arr, index); //node->child[0];

  if (getChild0(arr,spot) == -2) { //spot->child[0] == NULL) {
	// First insertion
	arr[parentIndex(newNode)] = spot;//newNode->parent = spot;
	arr[child0Index(spot)] = newNode;//spot->child[0] = newNode;
  }
  else {
	spot = findSpot_arr(arr, spot, data);
	if (spot == -2) return -2;
	insert_help_arr(arr, spot, newNode, data);
  }

  return spot;
}


__host__ void createRoot_arr(int* arr)
{
  int n = createNode_arr(arr, offsetTotal_h, -1); //Node *n = new Node;
  int n1 = createNode_arr(arr, offsetTotal_h, -1); //Node *n1 = createNode_d();
  arr[parentIndex(n1)] = n; //n1->parent = n;
  arr[child0Index(n)] = n1;
}

void print_tree(int *tree) {
  for(int i = 0; i < numNodes*7; i+=7){
	printf("Index = %d\n\t Key[0] = %d \n\t Key[1] = %d \n\t Parent = %d \n\t Child0 = %d \n\t Child1 = %d \n\t Child2 = %d \n\n", tree[i],tree[i+1],tree[i+2],tree[i+3],tree[i+4],tree[i+5],tree[i+6]);
  }
}

__host__ void print_keys(int *tree, int index) {
  if (getKey1(tree,index) == -1)
	  printf("%d, ", getKey0(tree,index));
  else
	  printf("%d, %d ", getKey0(tree,index), getKey1(tree,index));
}

__host__ void print_inorder(int *tree, int index) {

  if(index == -2)
	return;

  if(isLeaf_arr(tree, index))
	print_keys(tree,index);

  else if(getChild2(tree,index) == -2){
	print_inorder(tree, getChild0(tree, index));
	//printf("%d, ", getKey0(tree,index));
	print_inorder(tree, getChild1(tree, index));
  }

  else {
	print_inorder(tree, getChild0(tree, index));
	//printf("%d, ", getKey0(tree,index));
	print_inorder(tree, getChild1(tree, index));
	//printf("%d, ", getKey1(tree,index));
	print_inorder(tree, getChild2(tree, index));
  }

}
