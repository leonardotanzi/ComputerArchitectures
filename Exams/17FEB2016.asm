LOWER_SCORE    EQU  18
MAX_SCORE      EQU  30
MAX_STUDENTS   EQU  30
BASE_SCORE     EQU  6
TOT_CARDS      EQU  208  
Y              EQU  89
N              EQU  78

       .MODEL small
       .STACK
       .DATA  

DECKS           DB  TOT_CARDS DUP(?)
BUFFER          DB  8  DUP(0)
CARD            DB  ?
COUNTER_STUD    DB  ?
N_TOKENS        DB  ?
SENIORITY       DB  ?
DECK_COUNTER    DW  ?
MARK            DB  ?
ACES            DB  ?
KQJS            DB  ?

StartMSG        DB  'Student, insert your number of token (1 - 3): $'
SeniorityMSG    DB  'Insert your seniority (1 - 5): $'
PickUpMSG       DB  'Do you want to pick up a card? (Y/N)$' 
AcesMSG         DB  'Do you wanna change axes from 1 to 14? (Y/N) $'
kqjMSG          DB  'Do you wanna change KQJ to 10?(Y/N) $'
ScoreMSG        DB  'You final score is: $'
RejMSG          DB  'You have been Rejected! $'
        
         .CODE
       .STARTUP      
        
        
        MOV DECKS[0], 00001101B   ;K 
        MOV DECKS[1], 00000100B   ;4
        MOV DECKS[2], 00001100B   ;Q
        MOV DECKS[3], 00000010B   ;2
        MOV DECKS[4], 00001101B   ;K
        MOV DECKS[5], 00001011B   ;J
        MOV DECKS[6], 00000001B   ;1
        
        
        MOV COUNTER_STUD, 0
begin:
        CMP COUNTER_STUD, MAX_STUDENTS               
        JE end 
        INC COUNTER_STUD
        
        MOV MARK, 6
        MOV ACES, 0
        MOV KQJS, 0
        XOR DI, DI
        
        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET StartMSG
        INT 21H 
        XOR AX, AX
        MOV AX, 1
        PUSH AX
        CALL readDecimal
        POP AX
        MOV N_TOKENS, AL
        
        CALL emptyRow
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET SeniorityMSG
        INT 21H 
        XOR AX, AX
        MOV AX, 1
        PUSH AX
        CALL readDecimal
        POP AX
        MOV SENIORITY, AL
        
pick:
        CMP N_TOKENS, 0
        JE  stop
        CALL emptyRow
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET PickUpMSG
        INT 21H 
        XOR AX, AX
        MOV AH, 1
        INT 21H
        CMP AL, Y
        JNE stop
        MOV DI, DECK_COUNTER 
        INC DECK_COUNTER
        MOV AL, DECKS[DI]
        AND AL, 00001111B
        ADD MARK, AL
        CMP AL, 11   ;JACK, QUEEN, KING
        JGE kqj 
        JMP no1
kqj:
        MOV BL, AL
        SUB BL, 10
        ADD KQJS, BL
no1:
        CMP AL, 1
        JE  ace
        JMP no2
ace:
        INC ACES
no2:
                        
        DEC N_TOKENS
        JMP pick
                 
                 
stop:
        CMP SENIORITY, 3
        JGE extrarule
        CMP SENIORITY, 2
        JGE addendumrule
        JMP basicrule
extrarule:
        CMP ACES, 0
        JE addendumrule 
        CALL emptyRow
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET AcesMSG
        INT 21H 
        XOR AX, AX
        MOV AH, 1
        INT 21H
        CMP AL, Y
        JNE addendumrule
        XOR AX, AX
        MOV AL, ACES 
        MOV BL, 13 ;(14 - 1)
        MUL BL  ;MAX IS 13*3 = 39 SO 8 BIT 
        ADD MARK, AL
addendumrule:
        CMP KQJS, 0
        JE basicrule
        CALL emptyRow
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET kqjMSG
        INT 21H 
        XOR AX, AX
        MOV AH, 1
        INT 21H
        CMP AL, Y 
        JNE basicrule
        MOV AL, KQJS
        SUB MARK, AL
basicrule:
        CALL emptyRow
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET ScoreMSG
        INT 21H 
        XOR AX, AX
        LEA AX, BUFFER          
        PUSH AX
        XOR AX, AX
        MOV AL, MARK
        PUSH AX
        CALL printDecimal
        POP AX
        POP AX
        
        CMP MARK, 18
        JL  rejected
        CMP MARK, 30
        JG  rejected 
        JMP endstud
        
rejected:
        CALL emptyRow 
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET rejMSG
        INT 21H 
                                                
endstud:
        INC COUNTER_STUD
        JMP begin                
        

;---------------------------------------------------------------

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


;---------------------------------------------------------------



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

;---------------------------------------------------------------------

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

;----------------------------------------------------------------------

end:       
       .EXIT
       END