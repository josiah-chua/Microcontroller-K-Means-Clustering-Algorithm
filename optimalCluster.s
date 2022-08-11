/*
 * optimalCluster.s
 *
 *  Created on: 2021/8/26
 *      Author: Teoh Jing Yang
 */
   .syntax unified
	.cpu cortex-m4
	.fpu softvfp
	.thumb

		.global optimalCluster

@ Start of executable code
.section .text

@ EE2028 Assignment 1, Sem 1, AY 2021/22
@ (c) ECE NUS, 2021

@ Josiah Chua A0238950X
@ Teoh Jing Yang A0164524H

@ You could create a look-up table of registers here:
@ R0: threshold value
@ R1: first address of wcss
@ R2: N - 1 - 2 computations needed. This is decremented til 0
@ R3: address of wcss[i], then wcss[i+1], then wcss[i+2], then decrement back
@ R4: value of wcss[i], then wcss[i] - 2* wcss[i+1] + wcss[i+2]
@ R5: Value of wcss[i+1]
@ R6: value of wcss[i+2]
@ R7: candidate for the optimal value


@ write your program from here:
optimalCluster:
	PUSH {R1-R12,R14} @saves register values and link back to main()
	MOV R7, #2 @updates R7 with the first candidate for the answer
	CMP R2, #2 @edge case: N = 2
	BEQ Escape

	SUBS R2, #3 @initialise R2 to the countdown counter
	BEQ EdgeCase3
	MOV R3, R1 @updates R3 with address of wcss[0]


GradientLoop:
	LDR R4, [R3], #4 @R4 = wcss[i], i++
	LDR R5, [R3], #4 @R5 = wcss[i+1], i++
	LDR R6, [R3], #-4 @R6 = wcss[i+2], i--, now i is at the next value
	SUB R4, R5 @R4 = wcss[i] - wcss[i+1]
	SUB R5, R6 @R5 = wcss [i+1] - wcss[i+2]
	CMP R4,R5
	ITE PL @check if there is an increase or decrease in gradient
	SUBPL R4, R5 @R4 = wcss[i] - 2*wcss[i+1] + wcss[i+2] if decrease
	SUBMI R4, R5, R4 @R4 = - (wcss[i] - 2*wcss[i+1] + wcss[i+2]) if increase
	CMP R4, R0 @check if R4 is less than threshold
	BMI Escape @escape and complete program if less than threshold. Otherwise, continue.
	ADD R7, #1 @else, look at next best solution
	SUBS R2, #1 @decrement counter by 1.
	ITT EQ
	ADDEQ R7, #1 @ no elbow point. Hence, best point is the last point
	BEQ Escape @if counter is 0, escape. We achieve best solution
	B GradientLoop @otherwise, perform the gradient computation again

EdgeCase3:
	LDR R4, [R3], #4 @R4 = wcss[i], i++
	LDR R5, [R3] @R5 = wcss[i+1]
	SUBS R4, R5 @R4 = wcss[i] - wcss[i+1]
	ITE EQ
	MOVEQ R7, #2 @zero gradient
	MOVNE R7, #3 @choose last point

Escape:
	MOV R0, R7 @update R0 to the solution
	POP {R1-R12,R14}
	BX LR
