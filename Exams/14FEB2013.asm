NUTR    EQU 5
ACT     EQU 5
REC     EQU 4


       .MODEL small
       .STACK
       .DATA  

NUTRITION       DB  101, 20,, 120, 33, 85
TASKS           DB  31, 27, 100, 72, 61
TASKS_COPY      DB  3
BIAS_GENDER     DB  195, 125
PERSON          DW  0, 1000011000000011B, 1100010000000001B, 1000101100000010B
GEN_CAL         DW  2 DUP(?)
LIST            DW  ACT DUP(?)

TMP             DW  ?
M1              DB  ? 
INDEX           DB  ?
TOT_CAL_GOT     DW  ?
TOT_CAL_BUR     DW  ? 
ECCESS          DW  ? 
MIN1            DB  ?
MIN2            DB  ?   
NUMBER_OF_TIMES DB  ?

ErrorMSG        DB  'No possible solution! $'
        
         .CODE
       .STARTUP
       
        MOV CX, REC - 1 
        MOV DI, 2

item1:        
        XOR AX, AX
        MOV AX, PERSON[DI]
        MOV TMP, AX        
        AND AX, 1100000000000000B
        SHR AX, 14
        CMP AX, 10B
        JE  nutrition_item
        JMP end_item1 
        
nutrition_item:
        
        MOV AX, TMP
        AND AX, 0001111100000000B
        MOV M1, AH 
        MOV AX, TMP
        MOV INDEX, AL
        XOR AX, AX
        XOR BX, BX
        XOR DX, DX
        MOV BL, INDEX
        MOV AL, NUTRITION[BX]
        MOV DL, M1
        MUL DL
        ADD TOT_CAL_GOT, AX 

end_item1:
        
        ADD DI, 2
        LOOP item1 
        
        
        
        
        ;item2
        
        MOV CX, REC - 1
        XOR DI, DI
        
        XOR AX, AX
        XOR BX, BX
        MOV AL, BIAS_GENDER[0]
        MOV BL, 8 
        MUL BL
        MOV GEN_CAL[0], AX
        
        XOR AX, AX
        MOV AL, BIAS_GENDER[1]
        MUL BL
        MOV GEN_CAL[2], AX
        
        XOR AX, AX 
        XOR BX, BX
        MOV AX, PERSON[DI]
        AND AX, 1100000000000000B
        SHR AX, 14
        MOV SI, AX
        MOV BX, GEN_CAL[SI] 
        ADD TOT_CAL_BUR, BX
        ADD DI, 2
        
item2:
        XOR AX, AX
        MOV AX, PERSON[DI]
        MOV TMP, AX
        AND AX, 1100000000000000B
        SHR AX, 14
        CMP AX, 11B 
        JE task_item
        JMP end_item2

task_item:

        MOV AX, TMP
        AND AX, 0001111100000000B
        MOV M1, AH
        MOV AX, TMP
        MOV INDEX, AL
        XOR AX, AX
        XOR BX, BX 
        XOR DX, DX
        MOV BL, INDEX
        MOV AL, TASKS[BX]
        MOV DL, M1
        MUL DL
        ADD TOT_CAL_BUR, AX

end_item2:
        
        ADD DI, 2
        LOOP item2
        
        
        
        
        ;item 3
        
        XOR AX, AX
        XOR BX, BX
        MOV AX, TOT_CAL_GOT
        MOV BX, TOT_CAL_BUR
        SUB BX, AX
        MOV ECCESS, BX
        
        
        ;ITEM 4
        
        
        XOR DI, DI
        XOR AX, AX 
        MOV CX, ACT -1
        MOV AL, TASKS[DI]
        MOV MIN1, AL
        MOV SI, DI
        INC DI        
                
search:

        XOR AX, AX
        MOV AL, TASKS[DI]
        CMP AL, MIN1
        JL min
        JMP notmin
min:
        MOV MIN1, AL
        MOV SI, DI        

notmin:
        INC DI
        LOOP search
                  
                  
        XOR AX, AX
        XOR BX, BX
        MOV AL, TASKS[0]
        MOV BL, TASKS[SI]
        MOV TASKS[0], BL
        MOV TASKS[SI], AL
                                       
                
        MOV DI, 1           ;NOW THE DEFAULT MIN IS THE SECOND EL OF THE VEC 
        MOV CX, ACT - 2 
        XOR AX, AX
        MOV AL, TASKS[DI]
        MOV MIN2, AL
        INC DI        
                
search_min2:

        XOR AX, AX
        MOV AL, TASKS[DI]
        CMP AL, MIN1
        JL min_two
        JMP notmin2
min_two:
        MOV MIN2, AL       

notmin2:
        INC DI
        LOOP search_min2
        
        
        ; MIN1 = 27 AND MIN2 = 31
        
        XOR AX, AX
        XOR BX, BX
        MOV AL, MIN1
        MOV BL, MIN2
        ADD AL, BL
        ADC AH, 0
        CMP AX, ECCESS
        JL  compute_list
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET ErrorMSG
        INT 21H
        JMP end_item4

compute_list:

        XOR AX, AX 
        XOR BX, BX
        XOR CX, CX
        MOV AX, 1100000100000000B
        ADD AL, MIN2
        MOV LIST[0], AX
        XOR AX, AX
        MOV AX, ECCESS
        MOV BL, MIN2
        SUB AX, BX
        MOV CL, MIN1
        DIV CL
        MOV NUMBER_OF_TIMES, AL
        
        XOR AX, AX
        XOR BX, BX
        MOV AX, 1100000000000000B
        MOV BL, NUMBER_OF_TIMES
        SHL BX, 8
        ADD AX, BX
        MOV CL, MIN1
        ADD AL, CL
        MOV LIST[2], AX              
                        
end_item4: 


end:

       
       .EXIT
        END 