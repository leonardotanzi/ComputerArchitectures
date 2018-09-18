STRIKE  EQU   83
SPARE   EQU   69
NONE    EQU   78
MINUS   EQU   45

       .MODEL small
       .STACK
       .DATA  

ROLLS       DB  17  DUP(?)
MATRIX      DB  56  DUP(?) 
BUFFER      DB  8   DUP(0)  ;è probabile che sia 8 perchè si scrivono 8 decimali in questo programma
  
POINT_FRAME DB  0
TOTAL       DB  ?
FLAG        DB  ? 
QM          DB  ?

HitMSG          DB  'How much pin you hit? $' 
FrameMSG        DB  'Frame number: $'
FirstHitMSG     DB  'First hit: $'   
SecondHitMSG    DB  'Second hit: $'
TypeMSG         DB  'Type: $'
FramePointsMSG  DB  'Frame points: $'
TotalPointsMSG  DB  'Total points: $'
QuestionMarkMSG DB  '? $'

        
         .CODE
       .STARTUP
        
        XOR SI, SI
        XOR DI, DI
        XOR CX, CX

frames:
        CMP CX, 8
        JE  endprogram
        XOR BX, BX 
        INC CX
        MOV MATRIX[DI], CL
        INC DI 
        MOV POINT_FRAME, 0
        
hit:
          
        XOR AX, AX 
        ;CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET HitMSG
        INT 21H
        
        XOR AX, AX
        MOV AX, 1 ;numero di cifre da leggere
        PUSH AX
        CALL readDecimal
        POP AX 
        
        ADD POINT_FRAME, AL
        MOV ROLLS[SI], AL
        INC SI
        ADD TOTAL, AL
        CMP POINT_FRAME, 8
        JE  strikespare
        MOV MATRIX[DI], AL
        INC DI
        INC BX
        CMP BX, 2
        JE  nothing
        JMP hit                
       
nothing:
        MOV MATRIX[DI], NONE
        INC DI
        PUSH AX 
        XOR AX, AX
        MOV AL , POINT_FRAME
        MOV MATRIX[DI],  AL
        POP AX
        INC DI
        MOV MATRIX[DI], 0 ;QUEST
        INC DI
        MOV MATRIX[DI], 0 ;INDEX
        INC DI
        
        JMP print
        
strikespare:
        
        CMP CX, 7
        JE  last
        JMP not_last
last:
        MOV FLAG, 1
not_last:
        CMP BX, 0
        JE  strike
        ;SPARE
        MOV MATRIX[DI], AL
        INC DI            
        MOV MATRIX[DI], SPARE
        INC DI 
        PUSH AX
        XOR AX, AX
        MOV AL, POINT_FRAME
        MOV MATRIX[DI], AL
        POP AX
        INC DI
        MOV MATRIX[DI], 1 ;QUEST
        INC DI
        PUSH CX
        XOR CX, CX
        MOV CX, SI
        DEC CX
        MOV MATRIX[DI], CL ;INDEX  
        POP CX
        INC DI
        JMP print

strike: 

        MOV MATRIX[DI], 8
        INC DI
        PUSH AX
        XOR AX, AX
        MOV AL, MINUS            
        MOV MATRIX[DI], AL
        POP AX
        INC DI 
        PUSH AX
        XOR AX, AX
        MOV AL, STRIKE
        MOV MATRIX[DI], AL
        POP AX
        INC DI
        MOV MATRIX[DI], 8
        INC DI
        MOV MATRIX[DI], 2 ;QUEST
        INC DI
        PUSH CX
        XOR CX, CX
        MOV CX, SI 
        DEC CX
        MOV MATRIX[DI], CL ;INDEX  
        POP CX
        INC DI
       
print:
        PUSH SI 
        XOR DX, DX
        XOR BX, BX
        
edit:
        MOV AX, CX
        DEC AX
        CMP BX, AX  ;CX IS THE FRAME COUNTER
        JE  printall
        XOR AX, AX
        MOV AL, 7
        MUL BL
        ADD AL, 5
        MOV DI, AX
        XOR AX, AX
        MOV AL, MATRIX[DI]
        CMP AL, 0
        JE  printall
        INC DI
        MOV DL, MATRIX[DI] ;INDEX
        DEC DI
        DEC DI
        XOR SI, SI
        MOV SI, DX 
        INC SI
        MOV DH, ROLLS[SI]
        ADD MATRIX[DI], DH ;TOTAL
        INC DI
        DEC MATRIX[DI] ;QUEST
        ADD TOTAL, DH
        INC BX
        JMP edit

printall: 
              
        XOR BX, BX ;non serve piu
        XOR SI, SI
        XOR DI, DI
        
for:    
        PUSH BX
        CMP BX, CX 
        JE stopprint
       
        PUSH DI
        PUSH CX
        MOV DI, 6 
        MOV CL, MATRIX[DI]
        MOV QM, CL
        POP CX
        POP DI
        
        ;PRINT N FRAME
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET FrameMSG 
        INT 21H
        LEA AX, BUFFER         
        PUSH AX
        XOR AX, AX
        MOV AL, MATRIX[DI]
        PUSH AX
        CALL printDecimal
        POP AX    
        POP AX
        INC DI
        
        ;PRINT 1 HIT
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET FirstHitMSG 
        INT 21H
        LEA AX, BUFFER         
        PUSH AX
        XOR AX, AX
        MOV AL, MATRIX[DI]
        PUSH AX
        CALL printDecimal
        POP AX    
        POP AX
        INC DI
        
        ;PRINT 2 HIT
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET SecondHitMSG 
        INT 21H
        LEA AX, BUFFER         
        PUSH AX
        XOR AX, AX
        MOV AL, MATRIX[DI]
        PUSH AX
        CALL printDecimal
        POP AX    
        POP AX
        INC DI
        
        ;PRINT type
        
        
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET TypeMSG 
        INT 21H
        XOR AX, AX 
        PUSH DX
        MOV AH, 2
        MOV DL, MATRIX[DI] 
        INT 21H
        POP DX
        INC DI
        
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET FramePointsMSG 
        INT 21H
        LEA AX, BUFFER         
        PUSH AX
        XOR AX, AX
        MOV AL, MATRIX[DI]
        PUSH AX
        CALL printDecimal
        POP AX    
        POP AX
        INC DI
        
        ;PRINT ????
        CMP QM, 0
        JG  printqm
        JMP continue
printqm:
        PUSH CX 
        PUSH AX
        XOR CX, CX
cycle:        
        XOR AX, AX
        CMP CL, QM
        JE  endcycle 
        MOV AH, 9
        MOV DX, OFFSET QuestionMarkMSG
        INT 21H 
        INC CX 
        JMP cycle
endcycle:        
        POP AX
        POP CX 

continue:        
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET TotalPointsMSG 
        INT 21H
        LEA AX, BUFFER         
        PUSH AX
        XOR AX, AX
        MOV AL, TOTAL
        PUSH AX
        CALL printDecimal
        POP AX    
        POP AX 
        
        INC DI
        INC DI
        
        POP BX
        INC BX
        JMP for

stopprint: 
        POP SI
       
        
        CMP FLAG, 1
        JE  lastframe 
        ;INC CX gia fatto all'inizio
        JMP frames
        
        
lastframe:        
        
        
        
    
                                     


;-----------------------------------------------------------

       
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
       
       
       

;READ DECIMAL----------------------------------------------------------------



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




;PRINT DECIMAL ---------------------------------------------------------------


        
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



endprogram:       
       .EXIT
        END 