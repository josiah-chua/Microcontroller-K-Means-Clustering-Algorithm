@ EE2028 Assignment 1, Sem 1, AY 2021/22
@ (c) ECE NUS, 2021
@ Josiah Chua A0238950X
@ Teoh Jing Yang A0164524H

   .syntax unified
	.cpu cortex-m4
	.fpu softvfp
	.thumb

		.global optimalCluster

@ Start of executable code
.section .text

@ Look-up table of registers:
@ R0: threshold value
@ R1: first address of wcss
@ R2: N - 1 - 2 computations needed. This is decremented til 0
@ R3: address of wcss[i], then wcss[i+1], then wcss[i+2], then decrement back
@ R4: value of wcss[i], then wcss[i] - 2* wcss[i+1] + wcss[i+2]
@ R5: Value of wcss[i+1]
@ R6: value of wcss[i+2]
@ R7: candidate for the optimal value

optimalCluster:

	@saves register values and link back to main()
	PUSH {R1-R12,R14}

	@updates R7 with the first candidate for the answer
	MOV R7, #2 

	@edge case: N = 2
	CMP R2, #2
	BEQ Escape

	@initialise R2 to the countdown counter
	SUBS R2, #3 
	BEQ EdgeCase3

	@updates R3 with address of wcss[0]
	MOV R3, R1

GradientLoop:
	@R4 = wcss[i], i++
	LDR R4, [R3], #4

	@R5 = wcss[i+1], i++
	LDR R5, [R3], #4

	@R6 = wcss[i+2], i--, now i is at the next value
	LDR R6, [R3], #-4

	@R4 = wcss[i] - wcss[i+1]
	SUB R4, R5

	@R5 = wcss [i+1] - wcss[i+2]
	SUB R5, R6
	CMP R4,R5

	@check if there is an increase or decrease in gradient
	ITE PL

	@R4 = wcss[i] - 2*wcss[i+1] + wcss[i+2] if decrease
	SUBPL R4, R5

	@R4 = - (wcss[i] - 2*wcss[i+1] + wcss[i+2]) if increase
	SUBMI R4, R5, R4

	@check if R4 is less than threshold
	CMP R4, R0

	@escape and complete program if less than threshold. Otherwise, continue.
	BMI Escape

	@ else, look at next best solution
	ADD R7, #1

	@decrement counter by 1.
	SUBS R2, #1 

	ITT EQ
	@ no elbow point. Hence, best point is the last point
	ADDEQ R7, #1

	@ if counter is 0, escape. We achieve best solution
	BEQ Escape

	@ otherwise, perform the gradient computation again
	B GradientLoop

EdgeCase3:
	@R4 = wcss[i], i++
	LDR R4, [R3], #4

	@R5 = wcss[i+1]
	LDR R5, [R3]

	@R4 = wcss[i] - wcss[i+1]
	SUBS R4, R5

	ITE EQ
	@zero gradient
	MOVEQ R7, #2

	@choose last point
	MOVNE R7, #3

Escape:

	@update R0 to the solution
	MOV R0, R7
	POP {R1-R12,R14}
	BX LR
