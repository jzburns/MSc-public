#include <iostream>
#include <ctime>
#include <chrono>

using namespace std;

/**
	The OpenMP directives include
 */
#include <omp.h>
#include <cmath>

void demoST();
void demo();
void demoOpenMP();
void initialize(int [], int);

const int arraySize = 90000000;

int a [arraySize];
int b [arraySize];
int c [arraySize];

int main (int argc, char** argv) {

	// master thread executes sequentially
	initialize(a, arraySize);
	initialize(b, arraySize);
	initialize(c, arraySize);

	std::cout << "Hello there!" << std::endl;
	using clock = std::chrono::system_clock;
	using sec = std::chrono::duration<double>;
	
	auto before = clock::now();
	demoST();
	sec duration = clock::now() - before;
	std::cout << "Single Thread - It took " << duration.count() << "s" << std::endl;

	before = clock::now();
	demoOpenMP();
	duration = clock::now() - before;
	std::cout << "Parallel Threads - It took " << duration.count() << "s" << std::endl;

	return 0;
}

void demoST() {
	// master thread executes sequentially
	for (int i = 0; i < arraySize; i++)
 		c[i] = sqrt(a[i] + b[i]);
}

void demoOpenMP() {
	// launch OpenMP
	// Fork-Join Model
	int n = arraySize;
	#pragma omp parallel for
	for (int i = 0; i < arraySize; i++) {
 		c[i] = sqrt(a[i] + b[i]);
	}
}

void initialize(int arr[], int size){
    srand(time(0));
    int random = (rand() % 9);
    for(int i = 0; i < size; i++){
        arr[i] = random;
    }
}
