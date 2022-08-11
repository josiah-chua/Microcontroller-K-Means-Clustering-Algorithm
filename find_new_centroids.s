/*
 * find_new_centroids.s
 *
 *  Created on: 2021/8/26
 *      Author: Gu Jing
 */
   .syntax unified
	.cpu cortex-m4
	.fpu softvfp
	.thumb

		.global find_new_centroids

@ Start of executable code
.section .text

@ EE2028 Assignment 1, Sem 1, AY 2021/22
@ (c) ECE NUS, 2021

@ Josiah Chua A0238950X
@ Teoh Jing Yang A0164524H

@ You could create a look-up table of registers here:
@R0: pointer j for points10, initialised at j = 0
@R1: Address 0 of centroids10
@R2: Address 0 of class
@R3: Address 0 of new_centroids10
@R4: counter to count number of points that matches the class of R9
@R5: x-coordinates of points10[j] -> y-coordinates of points10[j] -> x-coordinate of points10[j+1]
@R6: new_centroids10[i][0], where 1 <= i < ...
@R7: Accumulator for x-coordinate
@R8: Accumulator for y-coordinate
@R9: Counter that points at current class (that we are accumulating on)
@R10: Value of class[i], i++
@R11: N
@R12: Number of points M, that counts down to 0

@ write your program from here:
find_new_centroids:
	PUSH {R1-R12,R14}
	@ create a duplicate of R3 to point at new centroid first address
	MOV R6,R3
	@ Move R6 to point at the address of the first new centriod space
	ADD R6,#8
	LDR R11,[R3,#4]
	@initalize register that tracks current class
	MOV R9,#0
	BL Loop_Centroid
	POP {R1-R12,R14}
	BX LR

Loop_Centroid:
	CMP R11,#0
	@ if reach the end of class array exit
	IT EQ
	BXEQ LR
	@ save the current LR to escape this loop later and the first address of centriod and
	@R0 and R2 so that everytime it loops through the points the first address to the class and points array can be restored
	PUSH {R0,R2,R14}
	@ Initalze counter to count the number of points in class that correspond to R9
	MOV R4,#0
	@ Initalize number of points
	LDR R12,[R3]
	@ set up accumulator for X and Y coordinates
	MOV R7,#0
	MOV R8,#0
	@ Loop through each point to add the coordinates of X and Y respectively if the points matches the class of R9
	BL Loop_Points
	@ Divide the total sum of X and Y respectively with the total numebr of points in that class to get XY coordinates of new centroid
	CMP R4,#0
	ITTEE NE
	UDIVNE R7,R4
	UDIVNE R8,R4
	@if centroid is not linked store previous address
	LDREQ R7,[R1]
	LDREQ R8,[R1,#4]
	@store the new centroids in the new_centroid array
	STR R7,[R6],#4
	STR R8,[R6],#4
	@ Restore R0,R2,R14 saved in the stack
	POP {R0,R2,R14}
	@ decrement R11 for the loop
	SUB R11,#1
	@ increment R9 to the next class
	ADD R9,#1
	@decrement to next centroid
	ADD R1,#8
	B Loop_Centroid

Loop_Points:
	CMP R12,#0
	@ if reach the end of points array exit
	IT EQ
	BXEQ LR
	@ Load the class of current point
	LDR R10,[R2],#4
	@ If current point class is the same as the class in R9 accumulate X and Y
	CMP R10,R9
	ITTTT EQ
	LDREQ R5,[R0],#4
	ADDEQ R7,R5
	LDREQ R5,[R0],#4
	ADDEQ R8,R5
	CMP R10,R9
	ITE EQ
	@increment count of same class
	ADDEQ R4,#1
	@ if class of current point doesnt match R9 shift R0 to point to next point
	ADDNE R0,#8
	@ decrement R12 for the loop
	SUB R12,#1
	B Loop_Points

