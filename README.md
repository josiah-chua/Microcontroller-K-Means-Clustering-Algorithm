# Microcontroller-K-Means-Clustering-Algorithm

This alogrithm was written for a school project using the STM32L475VG board with an ARM Cortex M4 processor.
To test out this alogrithm, it is recommended to run it using the STM32 IDE. The workspace zip folder is in the repo and the project to open is EE2028_AY2122S1_Assign1.

Program Logic:
classification.s
![image](https://user-images.githubusercontent.com/81459293/184146267-12e206a6-df99-4c14-b5ab-f6281bc90254.png)
Figure 1: Control Flow diagram of classification.s
The classification of each point involved a nested loop, looping through each point and for each point looping through each centroid.. For each point, the squared euclidean distance to each centroid is computed and compared against the smallest squared distance computed so far. The smallest squared distance and associated centroid class is updated to that of the minimum and argmin, and stored in the memory address of class.

Find_new_centroids.s
![image](https://user-images.githubusercontent.com/81459293/184146501-d88b3969-d716-4102-b556-c4034577e4f4.png)
Figure 2: Control Flow Diagram of Find_new_centroids.s

For each centroid, the x-coordinates and y-coordinates of points matched to the centroid are aggregated through a loop, alongside a counter for the amount of points associated with the centroid. Unsigned Integer Division is performed if the amount of points > 0, to obtain a new estimate for the new centroid position, which is updated to the new_centroids array, else the old centroid position is updated to the new_centroids array. This is repeated for all the classes. The algorithm is performed with a 10x multiplicative factor on the coordinates, as unsigned division produces integers. This is corrected for in the main.c code.
elbow.s

Figure 3: Control Flow Diagram for Elbow.s
![image](https://user-images.githubusercontent.com/81459293/184146623-2d30de23-dbc8-4170-848f-130ba1907f33.png)
Elbow computes all  the squared euclidean distance between each point and the centroid  for its class and accumulates them into a final output. As the initial entries are 10 * coordinates of points or centroids, the final WCSS value is scaled by 100. This scaling is removed in the main.c code. Refer to the control flow diagram below.

optimalCluster.s
![image](https://user-images.githubusercontent.com/81459293/184146873-2cefafc5-1558-406d-891e-5f5aa91eff68.png)
Figure 4: Control Flow Diagram for optimalCluster.s

Taking in the WCSS estimates (with 100x multiplicative factor) for different amount of centroids used, a threshold value (with 100x multiplicative factor), the maximum centroid count as inputs, optimalCluster.s determines the first point at which the absolute difference of gradients (wcss[i]-wcss[i+1])-(wcss[i+1]-wcss[i+2]) drops below the threshold value. This serves as a proxy for finding the inflection point. It then identifies point [i] as the optimal point. If no point meets the threshold, the max centroid no. is chosen as optimal as the elbow point has not been reached. For edge cases N = 2 or 3, a trivial solution is given.

Discussion & Future Works
Having produced stable subroutines and a flexible main.c program that operates on arbitrary positive integer values of M and N > 1, it is possible in the future to improve the code in three directions. Firstly, K-means clustering algorithms typically decide on the proper point classifications and final centroid coordinates by iterating the algorithm until the WCSS value stabilises or a stop condition is reached. This can be implemented with slight modification to the main.c code. Secondly, one can look to generalise the algorithm to k-dimensions. This is significantly harder due to the limited amount of registers to perform computations. Finally, one could also perform the algorithm multiple times with different starting centroid values, for the program to ‘learn’ an optimal threshold value for computing the optimal amount of centroids..

