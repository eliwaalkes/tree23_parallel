#include <stdio.h>


__device__ void insert_help_d(Node *node, Node *newChild, int newSmallest);

__device__ Node *createNode_d(int data = -1)
{
  Node *n = new Node;

  n->key[0] = data;
  n->key[1] = -1;

  n->child[0] = NULL;
  n->child[1] = NULL;
  n->child[2] = NULL;

  n->parent = NULL;

  return n;
}


__device__ Node *createRoot_d()
{
  Node *n = new Node;
  Node *n1 = createNode_d();
  n1->parent = n;
  
  n->key[0] = -1;
  n->key[1] = -1;

  n->child[0] = n1;
  n->child[1] = NULL;
  n->child[2] = NULL;

  n->parent = NULL;

  return n;
}

// Check if node is a leaf
__device__ bool isLeaf_d(Node *node)
{
  return (node->child[0] == NULL);
}


__device__ int getSmallest_d(Node *node)
{
  while (!isLeaf_d(node)) node = node->child[0];
  return node->key[0];
}


// Get which sibling the node is
__device__ int sibNumber_d(Node *node)
{
  for (int i = 0; i < 3; ++i) {
	Node *check = node->parent->child[i];
	if (node == check) return i;
  }
  return -1;
}


// Update the parent nods efor the smallest child value
__device__ void updateParentSmallest_d(Node *node, int data)
{
  switch (sibNumber_d(node)) {
  case 0: if (node->parent->parent != NULL) updateParentSmallest_d(node->parent, data); break;
  case 1: node->parent->key[0] = data; break;
  case 2: node->parent->key[1] = data; break;
  }
}


// Insert into a node with 1 child
__device__ void insert1Siblings_d(Node *node, Node *newChild, int newSmallest)
{
  int newKey = newChild->key[0];
  newChild->parent = node;

  if (newKey < node->child[0]->key[0]) {
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


/*
int main(){

  Node *root = createRoot();
  insert(root, 2);
  insert(root, 4);
  insert(root, 6);
  insert(root, 8);
  insert(root, 10);

  print(root);
  
  return 0;
}
*/
