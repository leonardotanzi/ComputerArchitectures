N    EQU    4 

       .MODEL small
       .STACK
       .DATA  

A_SCHED                 DW 0000100000001010B, 0000100100000000B, 0000100100101101B, 0000101000011110B
B_SCHED                 DW 0000011100001010B, 0000100000001111B, 0000100100000101B, 0000101000101000B
C_SCHED                 DW 0000100000011110B, 0000100100101000B, 0000101000110010B, 0000110000000000B
D_SCHED                 DW 0000011100000000B, 0000100000101000B, 0000100100101000B, 0000101000101000B
ARRIVE_SWAP_B           DW N DUP(?)
ARRIVE_SWAP_D           DW N DUP(?)
DEP_SWAP_B              DW N DUP(?)
DEP_SWAP_D              DW N DUP(?)
ARRIVAL_FROM_A          DW N DUP(?)
ARRIVAL_FROM_C          DW N DUP(?) 

BUFFER                  DB  8  DUP(0

A_TO_B  DW  16
C_TO_D  DW  4
B_TO_TP DW  29
D_TO_TP DW  45

H_LEAVE DW  0000011100000000B
SAMEDAY DB  ? 
TMP     DW  ?  
CHOICE  DB  ?

INDEX_A DW  ?
INDEX_C DW  ?

HLeaveMSG   DB  'Insert the hours: $'
MLeaveMSG   DB  'Insert the minutes: $'

Sol1MSG     DB  'The fastest solution is the first! $'
Sol2MSG     DB  'The fastest solution is the second! $'

ArrivalSwMSG   DB  'The arrival time to the swap point is: $'
DepartureSwMSG DB  'The departure time from the swap point is: $'
ArrivalMSG     DB  'The arrival time is: $'

AstMSG         DB  '*$' 
TwoPointMSG    DB  ':$'

        
         .CODE
       .STARTUP


        
        XOR DI, DI
        MOV CX, N
        
create_vec1:
    
        MOV SAMEDAY, 0
        XOR AX, AX
        XOR BX, BX
        MOV AX, A_SCHED[DI]
        MOV BX, A_TO_B
        CALL AddHours
        MOV ARRIVE_SWAP_B[DI], AX
        
        XOR DX, DX
        XOR SI, SI
        
loop_search1:

        XOR BX, BX
        CMP DX, N
        JE  end_loop1
        INC DX 
        MOV BX, B_SCHED[SI]
        CMP AX, BX
        JLE found1
        ADD SI, 2
        JMP loop_search1

found1:
        
        MOV DEP_SWAP_B[DI], BX
        MOV SAMEDAY, 1
        
end_loop1:

        CMP SAMEDAY, 0
        JNE same_day1
        MOV BX, B_SCHED[0]
        ADD BX, 1000000000000000B
        MOV DEP_SWAP_B[DI], BX
        
same_day1:

        XOR AX, AX
        MOV AX, DEP_SWAP_B[DI]
        MOV BX, B_TO_TP
        CALL AddHours
        MOV ARRIVAL_FROM_A[DI], AX
        ADD DI, 2
        LOOP create_vec1 
        



        XOR DI, DI
        MOV CX, N
        
create_vec2:
    
        MOV SAMEDAY, 0
        XOR AX, AX
        XOR BX, BX
        MOV AX, C_SCHED[DI]
        MOV BX, C_TO_D
        CALL AddHours
        MOV ARRIVE_SWAP_D[DI], AX
        
        XOR DX, DX
        XOR SI, SI
        
loop_search2:

        XOR BX, BX
        CMP DX, N
        JE  end_loop2
        INC DX
        MOV BX, D_SCHED[SI]
        CMP AX, BX
        JLE found2
        ADD SI, 2
        JMP loop_search2

found2:
        
        MOV DEP_SWAP_D[DI], BX
        MOV SAMEDAY, 1
        
end_loop2:

        CMP SAMEDAY, 0
        JNE same_day2
        MOV BX, D_SCHED[0]
        ADD BX, 1000000000000000B
        MOV DEP_SWAP_D[DI], BX
        
same_day2:

        XOR AX, AX
        MOV AX, DEP_SWAP_D[DI]
        MOV BX, D_TO_TP
        CALL AddHours
        MOV ARRIVAL_FROM_C[DI], AX
        ADD DI, 2
        LOOP create_vec2 


for:        
        
        XOR BX, BX
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET HLeaveMSG
        INT 21H
        
        MOV AX, 2
        PUSH AX 
        CALL readDecimal
        POP AX
        MOV BH, AL
        
        CALL emptyRow
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET MLeaveMSG
        INT 21H 
        
        
        MOV AX, 2
        PUSH AX 
        CALL readDecimal
        POP AX 
        MOV BL, AL
        
        MOV H_LEAVE, BX
        
        
        XOR DI, DI
        MOV CX, N
        
searching1:

        XOR AX, AX
        MOV AX, A_SCHED[DI]
        CMP H_LEAVE, AX
        JLE end_search1
        ADD DI, 2
        LOOP searching1
end_search1:
        MOV INDEX_A, DI                
        
        
        XOR DI, DI
        MOV CX, N
        
searching2:

        XOR AX, AX
        MOV AX, C_SCHED[DI]
        CMP H_LEAVE, AX
        JLE end_search2
        ADD DI, 2
        LOOP searching2
end_search2:
        MOV INDEX_C, DI
        
        
        XOR AX, AX
        XOR BX, BX
        XOR DX, DX
        XOR DI, DI
        XOR SI, SI
        
        MOV DI, INDEX_A
        MOV SI, INDEX_C
        
        MOV AX, ARRIVAL_FROM_A[DI]
        MOV BX, ARRIVAL_FROM_C[SI]
        MOV DX, AX
        AND DX, 1000000000000000B
        CMP DX, 1000000000000000B
        JE  A_nextday
        MOV DX, BX
        AND DX, 1000000000000000B
        CMP DX, 1000000000000000B
        JE  C_nextday
        JMP both_same_day
A_nextday:
        MOV DX, BX
        AND DX, 1000000000000000B
        CMP DX, 1000000000000000B 
        JE  both_same_day ; the next, but the same
        MOV CHOICE, 2
        JMP end_conf
C_nextday:
        MOV CHOICE, 1
        JMP end_conf
both_same_day:
        AND AX, 0111111111111111B
        AND BX, 0111111111111111B
        
        CMP AX, BX
        JL C_nextday
        MOV CHOICE, 2
end_conf:
                        
        
        
        
        CALL emptyRow
        CMP CHOICE, 1
        JNE second_choice
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET Sol1MSG
        INT 21H 
        
        CALL emptyRow
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET ArrivalSwMSG
        INT 21H                
        MOV DI, INDEX_A
        MOV AX, ARRIVE_SWAP_B[DI] 
        CALL printHour          
        
        CALL emptyRow
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET DepartureSwMSG
        INT 21H  
        MOV AX, DEP_SWAP_B[DI]
        CALL printHour          

        CALL emptyRow
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET ArrivalMSG
        INT 21H 
        MOV AX, ARRIVAL_FROM_A[DI]
        CALL printHour
        JMP for    
        
second_choice:
                
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET Sol2MSG
        INT 21H 
                   
        CALL emptyRow
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET ArrivalSwMSG
        INT 21H                
        MOV DI, INDEX_C
        MOV AX, ARRIVE_SWAP_D[DI] 
        CALL printHour          
        
        CALL emptyRow
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET DepartureSwMSG
        INT 21H  
        MOV AX, DEP_SWAP_D[DI]
        CALL printHour          

        CALL emptyRow
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET ArrivalMSG
        INT 21H 
        MOV AX, ARRIVAL_FROM_C[DI]
        CALL printHour
        
        
        
        
        
        JMP for


;------------------------------------------------------------


printHour PROC
        
        MOV TMP, AX
        
        LEA AX, BUFFER          ;NON HO CAPITO A COSA SERVA MA E' FONDAMENTALE
        PUSH AX
        
        MOV AX, TMP
        AND AX, 1000000000000000B
        CMP AX, 1000000000000000B
        JE  ast
        JMP no_ast
ast:
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET AstMSG
        INT 21H 
no_ast:
        MOV AX, TMP
        AND AX, 0001111100000000B
        SHR AX, 8                
        PUSH AX
        CALL printDecimal
        POP AX 
        
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET TwoPointMSG
        INT 21H 
        
        MOV AX, TMP
        AND AX, 0000000000111111B
        PUSH AX 
        CALL printDecimal
        POP AX
        
        POP AX  
                
        RET
        
printHour ENDP        


;--------------------------------------------------------------        
        
AddHours PROC

        ADD AX, BX
        CMP AL, 60
        JGE greatermin
        JMP lowermin
greatermin:
        SUB AL, 60
        ADD AH, 1
lowermin:
        CMP AH, 24
        JGE greaterh
        JMP lowerh
greaterh:
        AND AH, 10000000B
lowerh:
        RET
        
AddHours ENDP                                                                              
        
         
;------------------------------------------------------------


emptyRow PROC
    
        PUSH AX
        PUSH DX
               
        MOV AH, 2
        MOV DL, 10
        INT 21H
        MOV DL, 13
        INT 21H
        
        POP DX
        POP AX
        RET
                         
emptyRow ENDP 


;-------------------------------------------------------------

readDecimal PROC 
    
        PUSH BP
        MOV BP, SP
    
        PUSH AX
        PUSH CX
        PUSH DX
        
        MOV CX, [BP + 4]  ;max number of digits to be read
        MOV DX, 0  
        
readLoop:  
    
        MOV AH, 1
        INT 21H
        CMP AL, 13  ; l'a-capo
        JE endReadLoop
        
        SUB AL, '0' ;per spostarlo nella giusta posizione ascii
        MOV CH, AL
        
        MOV AX, DX
        MOV DX, 10  ;perche' se e' il primo numero moltiplicato per 10, secondo 1
        MUL DX
        MOV DX, AX
        
        ADD DL, CH
        ADC DH, 0
        
        XOR CH, CH
        LOOP readLoop
    
endReadLoop:
    
        MOV [BP + 4], DX
              
        POP DX
        POP CX
        POP AX
        POP BP
        RET
        
readDecimal ENDP 

;--------------------------------------------------------


printDecimal PROC
        
        PUSH BP
        MOV BP, SP
        
        PUSH AX
        PUSH DX
        PUSH DI
        PUSH BX
        
        MOV DI, [BP+6]      ;BUFFER ADDRESS 
        
        MOV AX, [BP+4]      ;NUMBER
        
        
conv:   

        XOR DX, DX
        MOV BX, 10
        
loopDiv:   

        DIV BX
        ADD DL, '0'         ;REMAINDER: BINARY -> ASCII
        MOV [DI], DL
        INC DI
        XOR DX, DX
        CMP AX, 0
        JNE loopDiv
        
loopPrint: 

        DEC DI
        MOV DL, [DI]
        MOV AH, 2
        INT 21H
        CMP DI, [BP+6]
        JNE loopPrint
        
        POP BX
        POP DI
        POP DX
        POP AX
        
        POP BP
        RET      
        
printDecimal ENDP

               
end:       
       
       .EXIT
        END 