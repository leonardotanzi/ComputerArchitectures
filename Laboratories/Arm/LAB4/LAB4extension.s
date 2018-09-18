;R0 is the list
;R8 is the pool
;R1 is the 'last' variable
;R2 is the 'j' variable
;R3 is the 'pairs' variable
;R4, R5, R6, R7 are used to load the couples from the list and pool
;R9 is used as temporary register for the swapping
;R12 is needed to check if we are in the first while cycle


;RO AND R1 ARE USED TO ACCESS THE POOLS
;R3 IS THE ITEM WE ARE SEARCHING IN THE PRICE LIST
;R4 FIRST, R5 MIDDLE, R6 LAST
;R7 IS THE MIDDLE INDEX TO COMPUTE IF IT'S ODD OR EVEN, R8 IS THE MIDDLE INDEX * 4 TO ACCESS THE POOL IN THAT POSITION
;R9 IS THE NUMBER FOUND AD MIDDLE INDEX (R8)
;R10 IS THE AMOUNT OF EXPANSE
;R11 IS THE PRICE OF THE ITEM
;R12 IS THE QUANTITY I WANNA BUY


Pool_size       EQU     640 	;cause we have a vector of 20 elements, each element is 32 bits so it's 
								;32bits * 20elements = 640bits 

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3

Pool_mem        SPACE   Pool_size

		


		AREA reset, CODE, READWRITE	

		ENTRY

		B reset_handler	 


Price_list 	DCD 0x001, 6, 0x003, 7, 0x004, 10, 0x005, 9, 0x002, 8	 		;Code and price
     		DCD 0x016, 7, 0x012, 22, 0x017, 17, 0x006, 8, 0x01A, 22
			
Item_list 	DCD 0x006, 1, 0x012, 2, 0x017, 3	 							;Code and quantity


reset_handler

		LDR R0, =Price_list			
		LDR R8, =Pool_mem
		LDR R1, =10					;last = num	(not 20 cause i consider only the code not the price)
		LDR R4, [R0], #4			;load the first couple to the pool
		STR R4, [R8], #4
		LDR R4, [R0], #0
		STR R4, [R8], #0
		LDR R12, =0 				;counter for while cycles, because in the first cycle we access both the list 
									;and the pool, from the second cycle we modify only the pool

while

		ADD R12, R12, #1
		LDR R0, =Price_list			;re-initialize R0 and R8 at every while cycle
		ADD R0, #8					;move 8 in order to access the second couple of the list to confront 
		LDR R8, =Pool_mem			;it with the first couple of the pool

		CMP R1, #0			  		;while() check 
		LDR R2, =0					;j = 0 (counter)
			
		BLE end_first				

		SUB R3, R1, #1				;pairs = last - 1
		CMP R3, #9					;SE E' IL PRIMO WHILE DEVO SOTTRARRE ANCORA 1, SE NO SE PER ESEMPIO HO UN VETTORE DI
		SUBEQ R3, R3, #1			;6 ELEMENTI, PAIRS ANDREBBE DA 0 A 5 COMPRESO. QUINDI ANDREBBE A CONFRONTARE
									;LIST[5] CON LIST[5 + 1] CHE E' FUORI DAL VETTORE! NEI CICLI SUCCESSIVI INVECE
									;FUNZIONA REGOLARMENTE

		LDR R1, =0					;need to re-initialize to zero the variable LAST in order to exit the while cycle when
									;i have no more swap to do 
									;QUESTO AZZERAMENTO NON ERA PRESENTE NEL TESTO DELL'ESERCIZIO, MA E' NECESSARIO
									;PERCHE' L'ALGORITMO POSSA FUNZIONARE. SE NON LO METTO IL VALORE DI last VIENE SETTATO A
									;0 SOLO NEL CASO IN CUI SIANO LE PRIME DUE COPPIE A NON ESSERE IN ORDINE. PER ESEMPIO
									;IN UN VETTORE GIA' ORDINATO IL VALORE DI last NON VIENE MAI MODIFICATO PERCHE' NON SI
									;ENTRA MAI NELL'IF
for

		CMP R12, #1
		
		LDR R4, [R8], #4 			;pool[j]
		LDREQ R5, [R8], #-4			;price of pool[j] (TORNO ALL'INIZIO PERCHE' POI DEVO RISCRIVERE IL VETTORE
									;PARTENDO DALL'INIZIO)
		LDRNE R5, [R8], #4			;(SE INVECE NON SONO NEL PRIMO WHILE, SCALO DI 4 PERCHE' DEVO LEGGERE
									;ANCHE LA SECONDA COPPIA DAL POOL E NON DALLA LISTA)
		
		LDREQ R6, [R0], #4			;list[j + 1]  			;ANCHE QUA SE E' IL PRIMO ACCEDO ALLA LISTA, SE NO 
		LDREQ R7, [R0], #4			;price of list[j + 1]	;AL POOL E POI TORNO INDIETRO DI 12 PER RITROVARMI ALL'INIZIO
		LDRNE R6, [R8], #4			;pool[j + 1]
		LDRNE R7, [R8], #-12		;price of pool[j + 1]
		
		CMP R4, R6					 ;i do the comparison between the two number and i order them
		BGT greater
		BLE lower


return

		ADD R2, R2, #1			 	 ;increment the for counter
		CMP R2, R3					 ;j <= pairs
		BGT while					 ;if greater end the for cycles and new while cycle
		BLE for						 ;else new for cycle
		

greater

		MOV R9, R4			    ;temp = entry[j]
		MOV R4, R6				;entry[j] = entry[j + 1]
		MOV R6, R9			    ;entry[j + 1] = temp
		MOV R9, R5				;SWAPPING THE TWO COUPLEs
		MOV R5, R7
		MOV R7, R9

		MOV R1, R2  			;last = j, if there is no access, last will be set to zero (as default) and the while end


lower

		STR R4, [R8], #4		;load the couple (swapped or not) in the pool 
		STR R5, [R8], #4		;if i had a vector of 6 element, i modify the first 2 couples, then i go back
		STR R6, [R8], #4		;to the second couple in order to modify it in the next cycle 
		STR R7, [R8], #-4
		
		B return 

end_first

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		LDR R0, =Pool_mem			;initialize R0
		LDR R1, =Item_list 			;initialize R1


loop_outer

		CMP R2, #3 			;TOTAL NUMBER OF ITEM
		BEQ end

		LDR R3, [R1], #4 	;FIRST ITEM IN THE ITEM_LIST AND INCREMENT OF 4 THE INDEX OF THE POOL
		LDR R4, =0 			;FIRST
		LDR R5, =19			;LAST = TOTAL - 1 = 19
		LDR R6, =0;			;INDEX
		B loop_inner	  	


loop_inner
		
		CMP R4, R5			   
		BLT continue
		LDREQ R10, =0		 ;IF THEY ARE EQUAL MEANS THAT I HAVEN'T FOUND A CORRISPONDENCE IN THE PRICE_LIST
		BEQ end				 ;SO I SET R10 = 0 AND I END THE PROGRAM


continue

		LDR R0, =Pool_mem	 ;RE-initialize R0
		LDR R7, =0
		LDR R8, =0

		ADD R7, R4, R5		 ;R7 = FIRST + LAST
		LSR  R7, R7, #1		 ;FIRST DIVIDE BY 2, R7 IS MIDDLE EXPRESSED WITHOUT THE MUL
		LSL R8, R7, #2 		 ;R8 IS MIDDLE*4 TO ACCESS THE INDEX (i do the two operations separately cause i need both r7 and r8)
		
		;I NEED TO CHECK IF R7 IS ODD OR EVEN CAUSE FROM THIS DEPENDS THE BEHAVIOUR OF THE PROGRAM, NEED TO RUN TO UNDERSTAND
		;BUT IT DEPENDS FROM THE FACTS THAT 19/2 IS 9 AND NOT 9.5
		AND	R9, R7, #0x01	 ;IF R9 = 1 --> R7 IS ODD, ELSE IS EVEN
		CMP R9, #1 		  	 
		SUBEQ R8, R8, #4	 ;I SUBTRACT 4 IN ORDER TO READ THE CODE AND NOT THE PRICE
		
		LDR R9, [R0], R8 	 ;R9 here is USELESS, JUST TO MOVE TO R8 POSITION
		LDR R9, [R0], #4  	 ;R9 = TABLE[MIDDLE]; MOVE OF 4 TO READ THE COST ASSOCIATED

		CMP R3, R9			 ;R3 FIRST ITEM ON ITEM LIST, R9 MIDDLE ITEM ON PRICE LIST
		MOVEQ R6, R7 		 ;IF EQUAL --> INDEX = MIDDLE
		SUBLT R5, R7, #1  	 ;IF R3 < R9 LAST=MIDDLE-1 
		ADDGT R4, R7, #1	 ;IF R3 > R9 FIRST=MIDDLE+1

		BGT loop_inner		 ;IF THEY ARE DIFFERENT I RESTART THE CYCLE
		BLT loop_inner

		;IF THEY ARE EQUAL I FOUND THE CODE AND I COMPUTE THE TOTAL AMOUNT
		STMFD SP!, {R3}		 ;PUSH THE BALUE OF R3 TO COMPUTE THE MUL
		LDR R11, [R0], #0 	 ;PRICE OF THE ITEM
		LDR R12, [R1], #4	 ;QUANTITY I WANNA BUY
		MUL R3, R11, R12	 ;PRICE x QUANTITY
		ADD R10, R10, R3	 ;ADD TO R10
		ADD R2, R2, #1		 ;INCREASE THE COUNTER FOR THE OUTER LOOP
		LDMFD SP!, {R3}

		B loop_outer	    ;BREAK
			

end
		B reset_handler
		END

	
		