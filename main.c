/**
 ******************************************************************************
 * @project        : EE2028 Assignment 1 Program Template
 * @file           : main.c
 * @author         : Josiah Chua, ECE, NUS
 * @brief          : Main program body
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; Copyright (c) 2021 STMicroelectronics.
 * All rights reserved.</center></h2>
 *
 * This software component is licensed by ST under BSD 3-Clause license,
 * the "License"; You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at:
 *                        opensource.org/licenses/BSD-3-Clause
 *
 ******************************************************************************
 */

#include "stdio.h"
#include "stdlib.h"

#define M 8	 // No. of data points in total
#define N 4  // Max. No. of centroids
#define elbowThreshold100 50 //threshold value for picking elbow point

// Necessary function to enable printf() using semihosting
extern void initialise_monitor_handles(void);

// Functions for KMeans Clustering
extern void classification(int* arg1, int* arg2, int* arg3, int* arg4);
extern void find_new_centroids(int* arg1, int* arg2, int* arg3, int* arg4);
extern int elbow(int* arg1, int* arg2, int* arg3);
extern int optimalCluster(int arg1, int* arg2, int arg3);


int main(void)
{
	// Necessary function to enable printf() using semihosting
	initialise_monitor_handles();

	srand(7);

	double points [M][2]={};
	int points10 [M][2]={};

	// Generate random points and Multiply the coordinates by 10 so that the final answers have 1 decimal point
		for(int r=0; r<M; r++)//row
		{
		    for(int c=0; c<2; c++)
		    {
		        points [r][c] = ( (double)rand() * ( 4.0 - 0.0 ) ) / (double)RAND_MAX + 0.0;
				points10 [r][c] = points [r][c] * 10;
		    }
		    printf("points10[%d] = (%d,%d) \n",r,points10[r][0],points10[r][1]);
	    }
		printf("\n");


	int i,j,k;
	int temp1, temp2, temp3, temp4;
	int class[M] = {0,0,0,0,0,0,0,0};
	int wcss100[N-1];
	int optimal;

	int new_centroids10[N-1][N+1][2];
	int centroids10[N][2];

	for (i = 2; i < N + 1; i++)
	{
		new_centroids10[i-2][0][0] = M;
		new_centroids10[i-2][0][1] = i;
		for (j = 1; j < N + 1; j ++)
		{
			new_centroids10[i-2][j][0] = 0;
			new_centroids10[i-2][j][1] = 0;
		}
	}

	//goal is to generate centroids10 randomly
	for (j = 0; j < N; j ++)
	{
		for(int c=0; c<2; c++) 
		{
			centroids10[j][c] = (int) 10*(( (double)rand() * ( 4.0 - 0.0 ) ) / (double)RAND_MAX + 0.0);
		}
		printf("centroids10[%d] = (%d,%d) \n",j,centroids10[j][0],centroids10[j][1]);
	}
	printf("\n");

	// Perform Classification, Recomputation of Centroids and WCSS computation for k centroids, where 2 <= k <= N
	for (k = 2; k < N+1; k++)
	{
		printf("Performing algorithm for k = %d \n",k);
		// Binary Classification
		classification((int*)points10, (int*)centroids10, (int*)class, (int*)new_centroids10[k-2]);
		printf("Class for each point: \n");
		for (i=0; i<M; i++)
		{
			printf("point %d: class %d \n", i, class[i]);
		}
			
	printf("\n");

	// Re-computation of centroids
	find_new_centroids((int*)points10, (int*)centroids10, (int*)class, (int*)new_centroids10[k-2]);
	printf("New centroids: \n");
	for (i=0; i<k+1; i++)
	{
		temp1 = new_centroids10[k-2][i][0] / 10;
		temp2 = new_centroids10[k-2][i][0] % 10;
		temp3 = new_centroids10[k-2][i][1] / 10;
		temp4 = new_centroids10[k-2][i][1] % 10;
		printf("(%d.%d, %d.%d)\n",temp1, temp2, temp3, temp4);
	}
	printf("\n");

	// Computation of WCSS
	wcss100[k-2] = elbow((int*)points10, (int*)new_centroids10[k-2], (int*)class);
	temp1 = wcss100[k-2] / 100;
	temp2 = wcss100[k-2] % 100;
	printf("wcss: %d.%d \n",temp1,temp2);
	printf("\n");
	}

	optimal = optimalCluster(elbowThreshold100, (int*) wcss100, N);


	printf("Optimal centroid number is %d. \nPerforming algorithm for k = %d \n",optimal,optimal);

	// Binary Classification
	classification((int*)points10, (int*)centroids10, (int*)class, (int*)new_centroids10[optimal-2]);
	printf("Class for each point: \n");
	for (i=0; i<M; i++)
		printf("point %d: class %d \n", i, class[i]);
	printf("\n");

	// Re-computation of centroids
	find_new_centroids((int*)points10, (int*)centroids10, (int*)class, (int*)new_centroids10[optimal-2]);
	printf("New centroids: \n");
	for (i=0; i< optimal+1; i++)
	{
		temp1 = new_centroids10[optimal-2][i][0] / 10;
		temp2 = new_centroids10[optimal-2][i][0] % 10;
		temp3 = new_centroids10[optimal-2][i][1] / 10;
		temp4 = new_centroids10[optimal-2][i][1] % 10;
		printf("(%d.%d, %d.%d)\n",temp1, temp2, temp3, temp4);
	}
	printf("\n");

	return 0;
}
