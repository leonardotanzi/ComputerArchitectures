DIM    EQU 50

       .MODEL small
       .STACK
       .DATA  
            
COEFF_A     DB  ?
COEFF_B     DB  ?
COEFF_C     DB  ?
COEFF_D     DB  ?
COEFF_E     DB  ?
COEFF_F     DB  ? 

X_INT       DB  ?
Y_INT       DB  ?
X_INT_DEF   DB  ?
Y_INT_DEF   DB  ?
RESULT      DB  ?

DELTA       DB  ?
DELTA_X     DB  ?
DELTA_Y     DB  ?

GAMMA       DW  ?
RES_GAMMA1  DW  ?
RES_GAMMA2  DW  ?
FIRST       DW  ?
SECOND      DW  ?
THIRD       DW  ?
GAMMA_MIN   DW  ? 

NEGF        DB  ?

BUFFER     DB  8  DUP(0) 

JUMP_T      DW  C0, C1, C2, C3, C4

MENU0   DB '[0] Exit $'                           
MENU1   DB '[1] Insert coefficients $' 
MENU2   DB '[2] Solve system $' 
MENU3   DB '[3] Calculate overall squared error $'
MENU4   DB '[4] Minimize overall squared error (ONLY AFTER COMPUTING OVERALL) $'  
 
INSERTa DB 'Insert coefficient a: $'
INSERTb DB 'Insert coefficient b: $'
INSERTc DB 'Insert coefficient c: $'
INSERTd DB 'Insert coefficient d: $'
INSERTe DB 'Insert coefficient e: $'
INSERTf DB 'Insert coefficient f: $'              

Xmsg    DB 'x_int = $'
Ymsg    DB 'y_int = $'
        
         .CODE
       .STARTUP
        
        
for:    

        CALL emptyRow    
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET MENU0
        INT 21H 
        
        CALL emptyRow
        
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET MENU1
        INT 21H
        
        CALL emptyRow
        
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET MENU2
        INT 21H 
       
        CALL emptyRow
        
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET MENU3
        INT 21H             
        
        CALL emptyRow
        
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET MENU4
        INT 21H      
        
        CALL emptyRow       
        
        XOR AX, AX
        MOV AX, 1
        PUSH AX
        CALL readDecimal
        POP AX
        
        MOV DI, AX
        SHL DI, 1
        CALL JUMP_T[DI]
        JMP for 
        

C0 PROC
        JMP end
        RET
C0 ENDP        
        
        
        
C1 PROC
        
        
        CALL emptyRow
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET INSERTa
        INT 21H 
        XOR AX, AX
        MOV AX, 2
        PUSH AX
        CALL readDecimal
        POP AX      
        CALL checkSign   
        MOV COEFF_A, AL  
        CALL emptyRow
        
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET INSERTb
        INT 21H 
        XOR AX, AX
        MOV AX, 2
        PUSH AX
        CALL readDecimal
        POP AX      
        CALL checkSign   
        MOV COEFF_B, AL 
        CALL emptyRow
        
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET INSERTc
        INT 21H 
        XOR AX, AX
        MOV AX, 2
        PUSH AX
        CALL readDecimal
        POP AX      
        CALL checkSign   
        MOV COEFF_C, AL  
        CALL emptyRow
        
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET INSERTd
        INT 21H 
        XOR AX, AX
        MOV AX, 2
        PUSH AX
        CALL readDecimal
        POP AX      
        CALL checkSign   
        MOV COEFF_D, AL
        CALL emptyRow
        
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET INSERTe
        INT 21H 
        XOR AX, AX
        MOV AX, 2
        PUSH AX
        CALL readDecimal
        POP AX      
        CALL checkSign   
        MOV COEFF_E, AL  
        CALL emptyRow
                       
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET INSERTf
        INT 21H 
        XOR AX, AX
        MOV AX, 2
        PUSH AX
        CALL readDecimal
        POP AX      
        CALL checkSign   
        MOV COEFF_F, AL 
        CALL emptyRow
        
        RET
C1 ENDP        
                       
        
        
C2 PROC        
        XOR AX, AX
        XOR BX, BX
        XOR CX, CX
        XOR DX, DX
        
        MOV AL, COEFF_A
        MOV BL, COEFF_B
        MOV CL, COEFF_D
        MOV DL, COEFF_E
        
        CALL COMPUTE_DELTA
        XOR AX, AX
        MOV AL, RESULT
        MOV DELTA, AL
        
        XOR AX, AX
        XOR BX, BX
        XOR CX, CX
        XOR DX, DX
        
        MOV AL, COEFF_C
        MOV BL, COEFF_B
        MOV CL, COEFF_F
        MOV DL, COEFF_E
        
        CALL COMPUTE_DELTA
        XOR AX, AX
        MOV AL, RESULT
        MOV DELTA_X, AL
        
        XOR AX, AX
        XOR BX, BX
        XOR CX, CX
        XOR DX, DX
        
        MOV AL, COEFF_A
        MOV BL, COEFF_C
        MOV CL, COEFF_D
        MOV DL, COEFF_F
        
        CALL COMPUTE_DELTA 
        XOR AX, AX
        MOV AL, RESULT 
        MOV DELTA_Y, AL
        
        XOR AX, AX
        XOR BX, BX
        
        CMP DELTA_X, 0
        JL  low1
        JMP maj1
low1:
        MOV AH, 11111111B
maj1:                
        MOV AL, DELTA_X
        CMP DELTA, 0
        JL  low2
        JMP maj2
low2:
        MOV BH, 11111111B          
maj2:        
        MOV BL, DELTA
        IDIV BL
        
        MOV X_INT, AL
        
        XOR AX, AX
        XOR BX, BX 
        
        CMP DELTA_Y, 0
        JL  low3
        JMP maj3
low3:
        MOV AH, 11111111B
maj3:                   
        MOV AL, DELTA_Y
        
        CMP DELTA, 0
        JL  low4
        JMP maj4
low4:
        MOV BH, 11111111B
maj4:                
        MOV BL, DELTA
        
        IDIV BL
        MOV Y_INT, AL
        
        
        CALL emptyRow
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET Xmsg  
        INT 21H
        
        XOR AX, AX
        MOV AL, X_INT
        CMP X_INT, 0
        JE printsign1
        JMP nosign1
printsign1:
        XOR AX, AX
        MOV AH, 2
        MOV DL, 45
        INT 21H
nosign1:        
        
        LEA AX, BUFFER          
        PUSH AX  
        MOV AL, X_INT
        PUSH AX
        CALL printDecimal
        POP AX
        POP AX 
        
        
        CALL emptyRow
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET Ymsg  
        INT 21H
        
        XOR AX, AX
        MOV AL, Y_INT
        CMP Y_INT, 0
        JE printsign2
        JMP nosign2
printsign2:
        XOR AX, AX
        MOV AH, 2
        MOV DL, 45
        INT 21H
nosign2:        
        
        LEA AX, BUFFER          
        PUSH AX  
        MOV AL, Y_INT
        PUSH AX
        CALL printDecimal
        POP AX
        POP AX
        
        
        RET
C2 ENDP

        ;FEATURE B

C3 PROC        
        CALL GAMMA_P
        RET
C3 ENDP        
        
        ;FEATURE C

        ; x = x, y = y

C4 PROC
        
        XOR AX, AX
        MOV AX, GAMMA
        MOV GAMMA_MIN, AX

        
        ;x - 1, y - 1
        
        XOR AX, AX
        XOR BX, BX 
        MOV AL, X_INT
        MOV BL, Y_INT  
        MOV X_INT_DEF, AL
        MOV Y_INT_DEF, BL
        DEC AL
        DEC BL
        MOV X_INT, AL
        MOV Y_INT, BL
        CALL GAMMA_P
        CALL MIN 
         
        ; x + 1, y
        
        XOR AX, AX
        XOR BX, BX  
        MOV AL, X_INT_DEF
        MOV BL, Y_INT_DEF  
        INC AL
        MOV X_INT, AL
        MOV Y_INT, BL
        CALL GAMMA_P
        CALL MIN
        
        
        ;x, y = y + 1
        
        XOR AX, AX
        XOR BX, BX  
        MOV AL, X_INT_DEF
        MOV BL, Y_INT_DEF  
        INC BL
        MOV X_INT, AL
        MOV Y_INT, BL
        CALL GAMMA_P
        CALL MIN
        
        
        ;x = x + 1, y = y + 1
        
        XOR AX, AX
        XOR BX, BX  
        MOV AL, X_INT_DEF
        MOV BL, Y_INT_DEF  
        INC AL
        INC BL
        MOV X_INT, AL
        MOV Y_INT, BL
        CALL GAMMA_P
        CALL MIN
        
        
        ;x = x, y = y - 1
        
        XOR AX, AX
        XOR BX, BX  
        MOV AL, X_INT_DEF
        MOV BL, Y_INT_DEF  
        DEC BL
        MOV X_INT, AL
        MOV Y_INT, BL
        CALL GAMMA_P
        CALL MIN
        
        
        ;x = x - 1, y
        
        XOR AX, AX
        XOR BX, BX  
        MOV AL, X_INT_DEF
        MOV BL, Y_INT_DEF  
        DEC AL
        MOV X_INT, AL
        MOV Y_INT, BL
        CALL GAMMA_P
        CALL MIN
        
        
        
        ;x = x + 1, y = y - 1
        
        XOR AX, AX
        XOR BX, BX  
        MOV AL, X_INT_DEF
        MOV BL, Y_INT_DEF  
        INC AL
        DEC BL
        MOV X_INT, AL
        MOV Y_INT, BL
        CALL GAMMA_P
        CALL MIN
        
        
        ;x = x - 1, y = y + 1
        XOR AX, AX
        XOR BX, BX  
        MOV AL, X_INT_DEF
        MOV BL, Y_INT_DEF  
        DEC AL
        INC BL
        MOV X_INT, AL
        MOV Y_INT, BL
        CALL GAMMA_P
        CALL MIN
        
        
        JMP end       
        
        RET
        
C4 ENDP        

;---------------------------------------------------------------

COMPUTE_DELTA PROC
        
            
        IMUL DL      ;AX = A*E
        MOV DX, AX
        XOR AX, AX
        MOV AL, BL
        IMUL CL      ;AX = B*D
        SUB DX, AX
        MOV RESULT, DL
       
        RET
    
COMPUTE_DELTA ENDP    

;------------------------------------------------------------------

GAMMA_P PROC
        
        XOR AX, AX
        XOR BX, BX
        XOR CX, CX
        XOR DX, DX
        MOV AL, COEFF_A 
        MOV BL, COEFF_B
        MOV CL, COEFF_C
        CALL COMPUTE_GAMMA
        MOV RES_GAMMA1, AX
        
        XOR AX, AX
        XOR BX, BX
        XOR CX, CX
        XOR DX, DX
        MOV AL, COEFF_D 
        MOV BL, COEFF_E
        MOV CL, COEFF_F
        CALL COMPUTE_GAMMA
        MOV RES_GAMMA2, AX   
        
        
        XOR AX, AX
        XOR BX, BX
        XOR CX, CX
        XOR DX, DX
        
        MOV AX, RES_GAMMA1
        ADD AX, RES_GAMMA2
        MOV GAMMA, AX
            
        RET
            
GAMMA_P ENDP       
       
;-------------------------------------------------------------------

COMPUTE_GAMMA PROC
        
        MOV DL, X_INT
        IMUL DL
        MOV FIRST, AX
        
        XOR AX, AX
        XOR DX, DX
        
        MOV DL, Y_INT
        MOV AL, BL
        IMUL DL
        MOV SECOND, AX
        
        XOR AX, AX
        XOR BX, BX
        
        CMP CL, 0
        JL  low5         
        JMP maj5
low5:
        MOV CH, 11111111B
maj5:                
        
        MOV AX, FIRST
        MOV BX, SECOND
        ADD AX, BX          ;64 + 64 = 128 --> 16 BIT IN 2'S
        SUB AX, CX
        MOV BX, AX
        IMUL BX             ;FIT IN 16 BIT, MAX 17.000 AND IT'S NOT 2'S
               
        RET

COMPUTE_GAMMA ENDP        

;-----------------------------------------------------------

MIN PROC
        
        XOR AX, AX
        MOV AX, GAMMA
        CMP AX, GAMMA_MIN
        JL  lower
        JMP greater
lower:   
        MOV GAMMA_MIN, AX
greater:
        RET
        
MIN ENDP                        
        
        
;-------------------------------------------------------------


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

;-----------------------------------------------------------

checkSign PROC		
        CMP NEGF, 1
        JE  readneg
        JMP readpos
readneg:
        NEG AL
readpos:                 
        RET
checkSign ENDP



readDecimal PROC 
    
        PUSH BP
        MOV BP, SP
    
        PUSH AX
        PUSH CX
        PUSH DX
        
        MOV CX, [BP + 4]  ;max number of digits to be read
        MOV DX, 0 
        MOV NEGF, 0 
        
readLoop:  
    
        MOV AH, 1
        INT 21H
        CMP AL, 13  ; l'a-capo
        JE endReadLoop
        
        CMP AL, 45
        JE negative
        JMP positive
negative:
        MOV NEGF, 1
        INC CX
        LOOP readLoop        
positive:
        
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


;-------------------------------------------------------------

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