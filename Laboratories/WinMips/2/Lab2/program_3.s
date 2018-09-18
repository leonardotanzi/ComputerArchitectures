		.data

values: .byte 13, 29    ; 00001101 00011101	


	.text
MAIN:
daddui	R1, R0, 2 		;first loop delimiter
daddui 	R2, R0, 8		;second loop delimiter
dadd 	R3, R0, R0 		;counter1 for loop1
dadd	R8, R0, R0 		;counter2 for loop2
dadd 	R4, R0, R0  	;value to store the vector(i)
daddui	R5, R0, 1 		;shifting value
dadd	R6, R0, R0  	;temporary value where store the shifted number
dadd	R7, R0, R0		;value where store the "and" result
dadd	R9, R0, R0 		;value for the counter of 1 in the number
dadd 	R10, R0, R0 	;value to define if its even or odd
dadd 	R11, R0, R0 	;value1 modified
dadd	R12, R0, R0 	;value2 modified

LOOP1:
beq 	R1, R3, EXIT 		;if r1 != r3 continue
lb 		R4, values(R3)		;load values(r3) in r4
dadd	R8, R0, R0			;re-initialize r8 to zero
j 		LOOP2				;jump to loop2
RETURN1:						;Return after loop2 finish
andi	R10, R9, 0x01		;if R10 is 1 is odd, else is even
dadd 	R9, R0, R0 			;re-initialize the '1' counter
beqz	R10, EvenAction 	;if =0 EvenAction, else continue for the odd action
ori 	R11, R4, 128		;if it is odd the code continue here
sb		R11, values(R3)		;store the new value in the vector
RETURN2:						;Return after EvenAction
daddui	R3, R3, 1			;R3++
j		LOOP1				;Restart Loop1
halt

LOOP2:
beq		R2, R8, RETURN1   	;if (R8 = R2) back to loop1
and		R7, R4, R5			;anding R4 with R5 the result is =R5 if it was a '1' at that position: 00001101 and 00000001 = 00000001
beq		R7, R5, COUNT		;for every '1' found increment the counter
return_here:
dsll	R6, R5, 1			;shift ex: from 00000001 to 00000010
dadd 	R5, R0, R6			;assign the shifted num to R5
daddi	R8, R8, 1			;R8++
j 		LOOP2
halt

COUNT:
daddui	R9, R9, 1
j 		return_here

EvenAction:
andi 	R12, R4, 127		;if i want always zero to the first position I and with 01111111
sb		R12, values(R3)		;store the new value in the vector
j 		RETURN2

EXIT: