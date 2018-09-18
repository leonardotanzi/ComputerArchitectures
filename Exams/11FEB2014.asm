A   EQU 1 
B   EQU 2
C   EQU 3
D   EQU 4
E   EQU 5

       .MODEL small
       .STACK
       .DATA  

DATABASE    DD    00000001011100101000000000000110B
            DD    00000001011101001000000100000010B
            DD    00000001011100101000001001000000B
            DD    00000001011101101000001111001110B
            DD    00000001011110001000010110111010B
            DD    00000001011101001000100011010110B
            DD    00000000000000000000000000000000B
            
LIFTDESC    DB  81  DUP(?)

STATION1    DB  ?
HOURS1      DB  ?
MINUTES1    DB  ?
SECONDS1    DB  ?
STATION2    DB  ?
HOURS2      DB  ?
MINUTES2    DB  ?
SECONDS2    DB  ?

FIRST16     DW  ?
SECOND16    DW  ?

DESCINC_F   DB  ?
MINUTES_F   DB  ?
SECONDS_F   DB  ?
FIRSTDB     DB  ?

N_REC       DW  ?
N_LIFT      DB  ?
N_DESC      DB  ?
TYPE        DB  ?
MIN_LIFT    DW  ?
MIN_DESC    DW  ?
        
         .CODE
       .STARTUP
       
        MOV CX, 149
        XOR DI, DI
        XOR SI, SI
        
        
cycle1:

        MOV BX, DATABASE[DI]   ;ricordarsi che in memoria sono
        ADD DI, 2
        MOV AX, DATABASE[DI]
        ADD DI, 2
        MOV FIRST16, AX
        MOV SECOND16, BX
        AND AX, 0000000000001111B
        SHR AX, 1
        RCR BX, 12
        MOV STATION1, AL
        AND BX, 0000000000011111B
        MOV HOURS1, BL
        MOV BX, SECOND16
        AND BX, 0000111111000000B
        SHR BX, 6
        MOV MINUTES1, BL
        MOV BX, SECOND16
        AND BX, 0000000000111111B
        MOV SECONDS1, BL
        
        MOV BX, DATABASE[DI]
        ADD DI, 2
        MOV AX, DATABASE[DI]
        SUB DI, 2
        CMP AX, 0
        JE  zero
        JMP nonzero
zero:
        CMP BX, 0
        JE  endcycle1           
nonzero:
                
        MOV FIRST16, AX
        MOV SECOND16, BX
        AND AX, 0000000000001111B
        SHR AX, 1
        ROR BX, 12
        MOV STATION2, AL
        AND BX, 0000000000011111B
        MOV HOURS2, BL
        MOV BX, SECOND16
        AND BX, 0000111111000000B
        SHR BX, 6
        MOV MINUTES2, BL
        MOV BX, SECOND16
        AND BX, 0000000000111111B
        MOV SECONDS2, BL
        
        XOR AX, AX
        MOV AL, STATION1
        CMP AL, STATION2
        JG  descend
        MOV DESCINC_F, 1
        JMP lifting
descend:
        MOV DESCINC_F, 0
lifting:
        XOR AX, AX
        XOR BX, BX
        MOV AL, MINUTES1
        MOV BL, MINUTES2
        SUB BL, AL      
        MOV MINUTES_F, BL
        XOR AX, AX
        XOR BX, BX
        MOV AL, SECONDS1
        MOV BL, SECONDS2
        SUB BL, AL
        CMP BL, 0
        JL  negative
        JMP positive
negative:
        ADD BL, 60
        DEC MINUTES_F
positive:
        MOV SECONDS_F, BL
        
        ;WRITE TO DATABASE
        
        XOR AX, AX
        XOR BX, BX
        XOR DX, DX
        MOV AL, DESCINC_F
        SHL AL, 6
        MOV FIRSTDB, AL
        MOV BL, STATION1
        SHL BL, 3
        ADD FIRSTDB, BL
        MOV DL, STATION2
        ADD FIRSTDB, DL
        XOR AX, AX
        MOV AL, FIRSTDB
        MOV LIFTDESC[SI], AL
        INC SI
        XOR AX, AX
        MOV AL, MINUTES_F
        MOV LIFTDESC[SI], AL
        INC SI
        XOR AX, AX
        MOV AL, SECONDS_F
        MOV LIFTDESC[SI], AL
        INC SI
        
        LOOP cycle1      

endcycle1:
    
        ;ITEM 1
        
        MOV AX, 149
        SUB AX, CX
        MOV N_REC, AX
        
        MOV CX, N_REC
        XOR DI, DI
        
cycle2: 

        XOR AX, AX
        XOR BX, BX
        MOV AL, LIFTDESC[DI]
        ADD DI, 3
        AND AL, 01000000B
        SHR AL, 6
        CMP AL, 1
        JE  liftplus
        INC N_DESC
        JMP descplus
liftplus:
        INC N_LIFT
descplus:
        LOOP cycle2
        
        
        ;ITEM 2
        
        MOV CX, N_REC
        XOR DI, DI
        MOV AL, 0
        MOV AH, 30
        MOV MIN_LIFT, AX
        MOV MIN_DESC, AX
        
cycle3: 

        XOR AX, AX
        XOR BX, BX
        MOV AL, LIFTDESC[DI]
        INC DI
        AND AL, 01000000B
        SHR AL, 6
        CMP AL, 1
        JE  lift
        XOR AX, AX
        MOV AH, LIFTDESC[DI]
        INC DI
        MOV AL, LIFTDESC[DI]
        INC DI
        CMP AX, MIN_DESC
        JL  mind
        JMP nomind
mind:
        MOV MIN_DESC, AX
nomind:             
        JMP end3
        
lift:
        XOR AX, AX
        MOV AH, LIFTDESC[DI]
        INC DI
        MOV AL, LIFTDESC[DI]
        INC DI
        CMP AX, MIN_LIFT
        JL  minl
        JMP end3
minl:
        MOV MIN_LIFT, AX

end3:
        LOOP cycle3                    
        
            
                                                       
       
       .EXIT
        END 