		AREA reset, CODE, READONLY	;it contains code, and it's readonly

		ENTRY
		
reset_handler

		;initialize registers

		LDR R0, =1
		LDR R1, =3
		LDR R2, =5
		LDR R3, =5
		LDR R4, =6
		LDR R5, =6
		LDR R6, =8
		LDR R7, =7
	
		
		CMP R0, R1
		MULEQ R8, R0, R1 	   	;if equal, compute the multiplication
		ADDNE R8, R0, R1		;if different, add the two register and divide by two
		LSRNE  R8, R8, #1

		CMP R2, R3
		MULEQ R9, R2, R3 	   
		ADDNE R9, R2, R3
		LSRNE  R9, R9, #1

		CMP R4, R5
		MULEQ R10, R4, R5 	   
		ADDNE R10, R4, R5
		LSRNE  R10, R10, #1

		CMP R6, R7
		MULEQ R11, R6, R7 	   
		ADDNE R11, R6, R7
		LSRNE  R11, R11, #1

		
;endProgram

		B reset_handler ;otherwise the debugger would continue to execute instructions
		END