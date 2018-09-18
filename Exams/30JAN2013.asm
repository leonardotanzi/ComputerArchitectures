N   EQU 144

       .MODEL small
       .STACK
       .DATA  

CLEAR       DB  N, ?, N   DUP(?)
ENC_E       DB  N-4 DUP(?)
DEC_E       DB  N-4 DUP(?)
ENC_D       DB  N-4 DUP(?)
DEC_D       DB  N-4 DUP(?)           
                           
LAMBDA      DB  ?          
LEN         DW  ?           
                           
LamMSG      DB  'Insert the value of Lambda: $'
PhraseMSG   DB  'Insert the message to decode/encode: $'


        
         .CODE
       .STARTUP
                 
        
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET LamMSG
        INT 21H
        
        XOR AX, AX
        MOV AX, 2  
        PUSH AX
        CALL readDecimal 
        POP AX
        MOV LAMBDA, AL
        
        CALL emptyRow
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET PhraseMSG
        INT 21H
        
        XOR AX, AX
        MOV AH, 10
        MOV DX, OFFSET CLEAR
        INT 21H
        
        MOV SI, OFFSET CLEAR + 1 ;NUMBER OF CHARACTERS ENTERED.
        MOV CL, [ SI ] ;MOVE LENGTH TO CL.
        MOV CH, 0      ;CLEAR CH TO USE CX. 
        INC CX ;TO REACH CHR(13).
        ADD SI, CX ;NOW SI POINTS TO CHR(13).
        MOV AL, '$'
        MOV [ SI ], AL ;REPLACE CHR(13) BY '$'.
        
        XOR AX, AX
        MOV AL, CLEAR[1]   ;i dont' count the last tqo char
        MOV LEN, AX
        MOV DI, 2
        MOV CX, LEN ;the first element is out of the loop 
        DEC CX
        XOR AX, AX
        MOV AL , CLEAR[DI]
        ADD AL, LAMBDA
        CALL Modulo128 
        MOV ENC_E[DI - 2], AL
        INC DI
        
item1loop:

        XOR AX, AX
        XOR BX, BX
        MOV AL, CLEAR[DI]
        MOV BL, ENC_E[DI - 3]
        ADD AL, BL
        CALL Modulo128
        MOV ENC_E[DI - 2], AL
        INC DI
        LOOP item1loop
        
        
        XOR AX, AX
        XOR CX, CX
        XOR DI, DI
        
        MOV AL, ENC_E[DI]
        SUB AL, LAMBDA
        MOV DEC_E[DI], AL
        INC DI
       
item2:
        CMP CX, 3
        JE  enditem2
        XOR AX, AX
        MOV AL, ENC_E[DI] 
        PUSH CX
        AND CX, 1B
        CMP CX, 1
        JE  odd
        ADD AL, 128
odd:    
        POP CX
        SUB AL, ENC_E[DI - 1]
        MOV DEC_E[DI], AL
        INC DI
        INC CX
        JMP item2
        
enditem2: 


        
        
        XOR AX, AX
        MOV AL, CLEAR[1]   ;i dont' count the last tqo char
        MOV DI, 2
        MOV CX, LEN ;the first element is out of the loop 
        DEC CX
        XOR AX, AX
        MOV AL , CLEAR[DI]
        ADD AL, LAMBDA
        CALL Modulo128 
        MOV ENC_D[DI - 2], AL
        INC DI
        
item3:
        XOR AX, AX
        XOR BX, BX
        MOV AL, CLEAR[DI]
        ADD AL, LAMBDA
        XOR DX, DX
loopinner:
      
        MOV BX, DI
        DEC BX
        DEC BX
        CMP DX, BX
        JE endloopinner 
        XOR BX, BX
        PUSH SI
        MOV SI, DI
        SUB SI, 3
        SUB SI, DX
        MOV BL, ENC_D[SI]
        POP SI
        ADD AX, BX
        INC DX
        JMP loopinner
endloopinner:        
        CALL Modulo128
        MOV ENC_D[DI - 2] , AL
        INC DI
        LOOP item3                                              
        
        
        
        XOR AX, AX
        MOV CX, LEN
        DEC CX
        XOR DI, DI
        MOV AL, ENC_D[DI]
        SUB AL, LAMBDA
        MOV DEC_D[DI], AL
        INC DI
item5:
        XOR AX, AX
        XOR BX, BX
        XOR DX, DX
        MOV AL, ENC_D[DI]
        SUB AL, LAMBDA
        SUB AL, ENC_D[DI - 1]
looooop:
        CMP AL, 0
        JL lower
        JMP higher
lower:
        ADD AL, 128
        JMP looooop
higher:
        MOV DEC_D[DI], AL
        INC DI
        LOOP item5
                                        
        
        
        
        
        JMP end        
        
;---------------------------------------------------------------
        
        
Modulo128 PROC
                
begin128:
        CMP AX, 128 
        JL endloop128
        SUB AX, 128
        JMP begin128
endloop128:        
        RET
        
Modulo128 ENDP                                           
        


;-------------------------------------------------------------------                         

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
                                
;-------------------------------------------------------------------

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

                
                    
end:
       
       .EXIT
        END 