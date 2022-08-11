@ EE2028 Assignment 1, Sem 1, AY 2021/22
@ (c) ECE NUS, 2021
@ Josiah Chua A0238950X
@ Teoh Jing Yang A0164524H

   .syntax unified
	.cpu cortex-m4
	.fpu softvfp
	.thumb

		.global elbow

@ Start of executable code
.section .text

@ Look-up table of registers:
@ R0 array of points
@ R1 Array of centroids
@ R2 Array of class
@ R3 Number of Classes
@ R4 Duplicate of R1 to point new_centroid first address
@ R5 Used for storing Number of points
@ R6 Load X coordinates of Centroid
@ R7 Load Y coordinates of Centroid
@ R8 Register that tracks current class
@ R9 Load current points class
@ R10 Load X coordinate of point
@ R11 Load Y coordinate of point
@ R12 Accumulator to get WCSS

elbow:
	PUSH {R1-R12,R14}
	LDR R3,[R1,#4]
	
	@ create a dupliace of R1 to point at new_centroid first address
	MOV R4,R1
	
	@ Move R4 to point at the address of the first new centriod space
	ADD R4,#8
	
	@ initalise accumulator to get WCSS
	MOV R12,#0
	
	@initalize register that tracks current class
	MOV R8,#0
	BL Loop_Class
	
	@ store value of WCSS to R0 so it can be returned
	MOV R0,R12
	POP {R1-R12,R14}
	BX LR

Loop_Class:
	CMP R3,#0
	
	@ if reach the end of class array exit
	IT EQ
	BXEQ LR
	
	@R0 and R2 so that everytime it loops through the points the first address to the class and points array can be restored
	PUSH {R0,R2,R14}
	
	@ Initialize number of points into R5
	LDR R5,[R1]
	
	@ Load X and Y coordinates of Centroid into R6 and R7
	LDR R6,[R4],#4
	LDR R7,[R4],#4
	
	@ Loop through the different points and if the point belongs to the class with that centroid calculate accumulate the
	@ distance fom centriod squared
	BL Loop_Points
	
	@ Restore R0,R2,R14 saved in the stack
	POP {R0,R2,R14}
	
	@ decrement R3 for the loop
	SUB R3,#1
	
	@ increment R8 to the next class
	ADD R8,#1
	B Loop_Class

Loop_Points:
	
	CMP R5,#0
	
	@ if reach the end of points array exit
	IT EQ
	BXEQ LR
	
	@ Load the class of current point
	LDR R9,[R2],#4
	
	@ If current point class is the same as the class in R8 find distance fom centriod squared
	CMP R8,R9
	ITTTT EQ
	
	@ Load X and Y coordinate of point in R10 R11
	LDREQ R10,[R0],#4
	LDREQ R11,[R0],#4
	
	@ Find difference of point to centriod
	SUBEQ R10,R6
	SUBEQ R11,R7
	CMP R8,R9
	ITTT EQ
	
	@ Square distance
	MULEQ R10,R10,R10
	MULEQ R11,R11,R11
	ADDEQ R10,R11
	CMP R8,R9
	ITE EQ
	
	@ Add to R12
	ADDEQ R12,R10
	
	@ if class of current point doesnt match R9 shift R0 to point to next point
	ADDNE R0,#8

	SUB R5,#1
	B Loop_Points


