;IF IT'S INCREASING (R5 = 0), AT THE END R7 IS THE MEAN 
;IF IT'S DECREASING (R5 = 1), AT THE R6 IS THE MAXIMUM DIFFERENCE 
;IF IT'S NON MONOTONE (R5 = 2), AT THE ENF R6 IS THE MAXIMUM AND R7 IS THE MINIMUM
	
	
		AREA reset, CODE, READWRITE	

		ENTRY

		B reset_handler 

pool DCD  8, 7, 4, 3, 2, 2, 1, 4 	
		
reset_handler

		LDR R0, =pool		;initialize R0
		LDR R1, =6 			;define the counter, it's 6 because i don't count the first TWO element
		
		LDR R3, [R0], #4 	;FIRST NUMBER AND INCREMENT OF 4 THE INDEX OF THE POOL
		LDR R4, [R0], #0 	;SECOND NUMBER AND INCREMENT OF 0 (that's why the counter is 6)

		ADD R2, R3, R4		;R2 is to STORE THE SUM OF ALL THE VALUES, so I ADD THE FIRST 2 VALUES
		
		LDR R5, =2			;2 NO MONOTONE, 0 INCREASING, 2 DECREASING, default value is 2
		
		CMP R3, R4

		BLT increasing

		SUBGT R6, R3, R4		;R6 contains the initial value of the maximum difference (and the only one) for the case of a decreasing sequence
		BGT decreasing

		B reset_handler
	
		
increasing
		
		LDR R5, =0				;we are in the case of a increasing sequence, so R5=0
		LDR R3, [R0], #4		;second value of the pool (that's way we didn't increment in the last pool access)
		LDR R4, [R0], #0		;third value and NO increase the index, because I need this value again in the next cycle (and it will be stored in R3) 
		ADD R2, R2, R4			;R2 contains the sum of all the values of the pool

		CMP R3, R4				;;;;ho bisogno di questo confronto perchè se per caso l'ultimo numero rende la funzione non monotona, se questo fosse dopo non verrebbe valutato l'ultimo confronto, uguale per decreasing
		LDRGT R5, =2 	  		;if not it's no monotone and R5=2
		BGT finish_no

		SUB R1, R1, #1		   	;loop decrementing
		CMP R1, #0
		BEQ finish_inc		 	;if R1=0 I finished to check all the sequence and I can compute the mean
		
		CMP R3, R4		
		BLE increasing	  		;if R3 <= R4 is still increasing
		

decreasing
		
		LDR R5, =1		   	;we are in the case of a decreasing sequence, so R5=1
		LDR R3, [R0], #4   	;first value
		LDR R4, [R0], #0   	;second value
		SUB R7, R3, R4		;I COMPUTE THE DIFFERENCE between the two values
		CMP R7, R6
		MOVGT R6, R7  		;IF IS GREATER THAN THE PRECEDENT STORED IN R6, I SUBSTITUTE IT
		
		CMP R3, R4	
		LDRLT R5, =2 	  	;if not it's no monotone and R5=2
		BLT finish_no
		
		SUB R1, R1, #1		;loop decrementing
		CMP R1, #0
		MOVEQ R7, #0		;clean the value of r7
		BEQ ended
			  	
		CMP R3, R4
		BGE decreasing		;if R3 >= R4 is still decreasing
		

finish_inc

		;COMPUTE THE MEAN
		SUB R2, R2, #8		 ;R2 = R2 - 8 to check how much time the 8 fits in R2, that is the sum
		CMP R2, #0			  
		ADDGE R7, R7, #1	 ;if r2 >= 0 R7++, if <0 no (arrotondamento per difetto)
		BLE ended			 ;if r2 <= 0 end of the cycle
		BGT finish_inc
		

finish_no

		LDR R0, =pool			;re-initilize to compute the max and min
		LDR R1, =7			  	;counter, this time is 7 cause i load only the first value and not the second one
		LDR R6, [R0], #0 		;STORE THE MAXIMUM	(max e min are the same at the beginning)
		LDR R7, [R0], #4	  	;STORE THE MINIMUM

loop
		SUB R1, R1, #1		    ;loop decrementing
		LDR R8, [R0], #4		;load the next value in the pool
		CMP R8, R6
		MOVGT R6, R8		    ;if R8>R6(maximum) the new maximum is R8
		CMP R8, R7
		MOVLT R7, R8		  	;if R8<R7(minimum) the new minimum is R8

	   	CMP R1, #0				;loop check
		BEQ ended
		BNE	loop

ended
 		MOV R0, #0
		MOV R1, #0
		MOV R2, #0
		MOV R3, #0
 		MOV R4, #0
		MOV R8, #0

		END

	
		