#include <stdio.h>

typedef struct Node{
  int index;
  int key0;
  int key1;
  int parent;
  int child0;
  int child1;
  int child2;
} Node;

Node createNode(int offset)
{
  Node n;
  n->index=offset;
  n->key0=offset+1;
  n->key1=offset+2;
  n->parent=offset+3;
  n->child0=offset+4;
  n->child1=offset+5;
  n->child2=offset+6;

  return n;
}
  

int getKey0 (int *arr, int index){
  return arr[ index + 1 ];
}
int getKey1 (int *arr, int index){
  return arr[ index + 2 ];
}
int getParent (int *arr, int index){
  return arr[ index + 3 ];
}
int getChild0 (int *arr, int index){
  return arr[ index + 4 ];
}
int getChild1 (int *arr, int index){
  return arr[ index + 5 ];
}
int getChild2 (int *arr, int index){
  return arr[ index + 6 ];
}


// Check if node is a leaf
bool isLeaf_arr(int *arr, int index)
{
  return getChild0(arr,index) != -1;
}


int getSmallest_arr(int *arr, int index)
{
  while (!isLeaf_arr(arr, index)) index += offset;
  return getChild0(arr,index);
}


// Get which sibling the node is
int sibNumber_arr(int *arr, int index)
{
  int parent = getParent(arr, index);
  int child0 = getChild0(arr, parent);
  for (int i = 0; i < 3; ++i) {
	int check = arr[child0+i]; //arr[index+3] is index of parent, +4 gives index of first child, i iterates through 2nd/3rd children indicies 
	if (index == check) return i;
  }
  return -1;
}


// Update the parent nods efor the smallest child value
void updateParentSmallest_arr(int* arr, int index, int data)
{
  int sibs = sibNumber_arr(arr, index);
  int p1 = getParent(arr, index);
  if(sibs == 0){
	int p2 = getParent(arr, p1);
	if ( arr[p2] != -1 ) updateParentSmallest_arr(arr, p1, data); break; 
  }
  if(sibs == 1){
	int k0 = getKey0(arr, p1);
	arr[k0] = data;
	break;
  }
  if(sibs == 2){
	int k1 = getKey1(arr, p1);
	arr[k1] = data;
	break;
  }
}


// Insert into a node with 1 child
void insert1Siblings_arr(int* arr, int index, int newChild, int newSmallest)
{
  int newKey = getKey0(arr, newChild);
  int newChildParent = getParent(arr, index);
  arr[newChildParent] = index; //newChild->parent = node;

  if (newKey < ) { //node->child[0]->key[0]
	// newNode is inserted as first child of root
	node->child[1] = node->child[0];
	node->child[0] = newChild;
	node->key[0] = getSmallest_d(node->child[1]);
  }
  else {
	// newNode is iserted as second child of root
	node->child[1] = newChild;
	node->key[0] = newSmallest;
  }
}

// Insert into a node with 2 children
__device__ void insert2Siblings_d(Node *node, Node *newChild, int newSmallest)
{
  int newKey = newChild->key[0];
  newChild->parent = node;

  if (newKey < node->child[0]->key[0]) {
	node->child[2] = node->child[1];
	node->child[1] = node->child[0];
	node->child[0] = newChild;

	node->key[1] = node->key[0];
	node->key[0] = getSmallest_d(node->child[1]);
	updateParentSmallest_d(node, newSmallest);
  }
  else if (newKey < node->child[1]->key[0]) {
	node->child[2] = node->child[1];
	node->child[1] = newChild;

	node->key[1] = node->key[0];
	node->key[0] = newSmallest;
  }
  else {
	node->child[2] = newChild;
	node->key[1] = newSmallest;
  }
}

// Insert into a node with 3 children
__device__ void insert3Siblings_d(Node *node, Node *newChild, int newSmallest) {
  int newKey = newChild->key[0];
  int splitSmallest = -1;
  Node *splitNode = createNode_d();
  splitNode->parent = node->parent;

  if (newKey < node->child[0]->key[0] || newKey < node->child[1]->key[0]) {
	// newChild is inserted in current node
	splitSmallest = node->key[0];
	splitNode->child[0] = node->child[1];
	splitNode->child[1] = node->child[2];
	splitNode->key[0] = node->key[1];

	node->child[1]->parent = splitNode;
	node->child[2]->parent = splitNode;
	newChild->parent = node;

	if (newKey < node->child[0]->key[0]) {
	  // newChild is inserted as first child
	  node->child[1] = node->child[0];
	  node->child[0] = newChild;

	  node->key[0] = getSmallest_d(node->child[1]);
	  updateParentSmallest_d(node, newSmallest);
	}
	else {
	  // newChild is inserted as second child
	  node->child[1] = newChild;
	  node->key[0] = newSmallest;
	}
  }
  else {
	// newChild is inserted in split node
	node->child[2]->parent = splitNode;
	newChild->parent = splitNode;

	if (newKey < node->child[2]->key[0]) {
	  // newChild is inserted as first child
	  splitSmallest = newSmallest;
	  splitNode->child[0] = newChild;
	  splitNode->child[1] = node->child[2];
	  splitNode->key[0] = node->key[1];
	}
	else {
	  // newChild is inserted as second child
	  splitSmallest = node->key[1];
	  splitNode->child[0] = node->child[2];
	  splitNode->child[1] = newChild;
	  splitNode->key[0] = newSmallest;
	}
  }

  node->child[2] = NULL;
  node->key[1] = -1;

  if (node->parent->parent == NULL) {
	// At root, so new root needs to be created
	Node *newNode = createNode_d();;

	node->parent->child[0] = newNode;
	newNode->parent = node->parent;
	newNode->child[0] = node;
	node->parent = newNode;
  }
  
  insert_help_d(node->parent, splitNode, splitSmallest);
}

__device__ Node* findSpot_d(Node *node, int data) {
  if (node == NULL) return NULL;

  while (!isLeaf_d(node)) {
	if (node->key[0] == data || node->key[1] == data)
	  return NULL;
	if (node->key[0] == -1 || data < node->key[0])
	  node = node->child[0];
	else if (node->key[1] == -1 || data < node->key[1])
	  node = node->child[1];
	else
	  node = node->child[2];
  }

  if (node->key[0] == data) return NULL;
  return node->parent;
}


// Insertion
__device__ void insert_help_d(Node *node, Node *newChild, int newSmallest)
{
  if (node->child[1] == NULL) insert1Siblings_d(node, newChild, newSmallest);
  else if (node->child[2] == NULL) insert2Siblings_d(node, newChild, newSmallest);
  else insert3Siblings_d(node, newChild, newSmallest);
}


__device__ void insert_d(Node *node, int data)
{
  Node *newNode = createNode_d(data);
  Node *spot = node->child[0];

  if (spot->child[0] == NULL) {
	// First insertion
	newNode->parent = spot;
	spot->child[0] = newNode;
  }
  else {
	spot = findSpot_d(spot, data);
	if (spot == NULL) return;
	insert_help_d(spot, createNode_d(data), data);
  }

  return;
}


__device__ void print_d(Node *node, int tabs = 0)
{
  for (int i = 0; i < tabs; ++i) {
	printf("\t");
  }

  if (node == NULL) {
	printf("`--> NULL\n");
	return;
  }

  printf("`--> : ( %d, %d )\n ", node->key[0], node->key[1]);

  if (!isLeaf_d(node)) {
	++tabs;
	print_d(node->child[0], tabs);
	print_d(node->child[1], tabs);
	print_d(node->child[2], tabs);
  }
}


int main() {
  int treeSize = 1000;
  int insertSize = 10;
  int *tree = (int *) malloc( (treeSize+insertSize)*sizeof(int) );


}
