@ EE2028 Assignment 1, Sem 1, AY 2021/22
@ (c) ECE NUS, 2021
@ Josiah Chua A0238950X
@ Teoh Jing Yang A0164524H

   .syntax unified
	.cpu cortex-m4
	.fpu softvfp
	.thumb

		.global classification

@ Start of executable code
.section .text

@ Look-up table of registers:
@ R0 points array
@ R1 centroid array
@ R2 class array
@ R3 new centroid array
@ R4 Point X coordinate
@ R5 Point Y coordinate
@ R6 Store the eucledian distance of X coordinate
@ R7 Store the eucledian distance of Y coordinate
@ R9 store current class with the smalllest eucledian distance to the point
@ R10 store current smallest distance between point and centroid
@ R11 store the number of points
@ R12 store the number of centroids

classification:
	PUSH {R1-R12,R14}
	LDR R11,[R3]
	BL Loop_Points
	POP {R1-R12,R14}
	BX LR

Loop_Points:
	CMP R11,#0
	@ if reach the end of points array exit
	IT EQ
	BXEQ LR

	@ save the current LR to escape this loop later and the first address of centriod and
	@ R1 so that after you loop through the centroids the first address in the centriods can be restored.
	PUSH {R1,R14}

	@ Get length of centriod for loop
	LDR R12,[R3,#4]
	MOV R10, #0x7FFFFFFF

	@ Get Px and Py
	LDR R4,[R0],#4
	LDR R5,[R0],#4

	@ Loop to calculate distances.
	BL Loop_Centriods

	@ Store the class of the points
	STR R9,[R2],#4
	POP {R1,R14}
	SUB R11,#1
	B Loop_Points

Loop_Centriods:
	CMP R12,#0
	@ if reach the end of centroid array exit
	IT EQ
	BXEQ LR

	@ Load next Cx and Cy into registers R6 and R7
	LDR R6,[R1],#4
	LDR R7,[R1],#4

	@ calculate elucledian distance
	SUBS R6, R4
	SUBS R7, R5
	MUL R6,R6,R6
	MUL R7,R7,R7
	ADD R7,R6

	@ Compare with current smallest elucaidian distance
	SUBS R6,R10,R7

	@ if new distance is smaller than current smallest
	ITTT PL

	@ update R9 with the current class
	LDRPL R9,[R3,#4]
	SUBPL R9,R12

	@ update new smallest distance
	MOVPL R10,R7
	SUB R12,#1
	B Loop_Centriods
