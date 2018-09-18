		AREA reset, CODE, READONLY

		ENTRY
		
reset_handler
		LDR R0, =3	
		LDR R1, =8
		LDR R2, =6
		
		CMP R0, R1

		MOVLT R3, R0		  ;if R0 < R1 --> R3 = R0
		MOVGE R4, R0		  ;if R0 >= R1 --> R4 = R0
		
		MOVGE R3, R1		  ;if R0 >= R1 --> R3 = R1
		MOVLT R4, R1		  ;if R0 < R1 --> R4 = R1

		;at the end of this R3 contains the lowest number and R4 the highest

		CMP R2, R3

		MOVLT R5, R3			;if R2 < R3 -> R5 = R3 and R3 = R2
		MOVLT R3, R2
		MOVGE R5, R2		  	;if R2 >= R3 -> R5 = R2
		
		;at the end of this R3 contains the lowest, R4 and R5 the two highests

		CMP R4, R5

		;MOVLT R5, R3			;if R4 < R5 it's fine
		
		MOVGE R6, R5		  	;if R4 >= R5 -> swap R5 and R4
		MOVGE R5, R4	        ;R5 = R4
		MOVGE R4, R6		  	;R4 = R6

		;rewrite
		MOV R0, R3
		MOV R1, R4
		MOV R2, R5
		MOV R3, #0
		MOV R4, #0
		MOV R5, #0
		MOV R6, #0
		
		;;;;;;;;;;2ND PART;;;;;;;;;;;

		STMFD SP!, {R1, R2}	  	  ;push the value of R1, R2


begin_cycle_R1

		SUBS R3, R1, R0		  ;R3 = R1 - R0
		CMP R3, #0			  
		MOVEQ R4, #1		  ;if R3 = 0 --> R4 = 1 and out
		MOVGT R1, R3          ;R1 is now R3, aka the value after the subtraction
		ADDGE R7, R7, #1		  ;increment the counter
		BLE out_R1
		BGT begin_cycle_R1
		

out_R1

		CMP R4, #1			  ;if R4 = 1 I load the number of the counter in R4
		MOVEQ R4, R7
		MOV R7, #0	          ;re-initialize the counter


begin_cycle_R2

		SUBS R3, R2, R0
		CMP R3, #0
		MOVEQ R5, #1		 
		MOVGT R2, R3         
		ADDGE R7, R7, #1
		BLE out_R2
		BGT begin_cycle_R2
		

out_R2

		CMP R5, #1
		MOVEQ R5, R7
		LDMFD SP!, {R1, R2}		  ;pop the value of R2
		MOV R3, #0
		MOV R7, #0
		
		B reset_handler ;otherwise the debugger would continue to execute instructions
		END