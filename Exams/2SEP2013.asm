N_EMPLOYEES                    EQU 30
N_MAX_WORKING_DAY_PER_MONTH    EQU 23
N_MAX_RECORDS_PER_MONTH        EQU N_EMPLOYEES * N_MAX_WORKING_DAY_PER_MONTH
N_MONTHS                       EQU 12
N_RECORDS                      EQU N_MAX_RECORDS_PER_MONTH * N_MONTHS
N_BYTES_PER_RECORD             EQU 3
N_BYTES_OF_RECORD              EQU N_BYTES_PER_RECORD * N_RECORDS


       .MODEL small
       .STACK
       .DATA  

CC_DATABASE             DB N_BYTES_OF_RECORD DUP(?) 

TOTAL_CHARGE            DB  3   DUP(?)
TOTAL_CHARGE_EMP        DB  3   DUP(?)
TOTAL_CHARGE_MONTH      DB  3   DUP(?)

CODE_EMP                DB  ?
EFF_REC                 DW  ?
MONTH                   DB  ?
DAY                     DB  ?
TOTAL_CHARGE_CODEMONTH  DW  ?
TOTAL_CHARGE_MONTHDAY   DW  ?                               

JUMP_T                  DW  C0, C1, C2, C3 
BUFFER                  DB  8  DUP(0)


Item1output             DB  'The grand total is: $'
Item2input              DB  'Insert the code of one employee: $' 
Item2output             DB  'The total of this employee is: $'
Item3input              DB  'Insert the month: $'
Item3output             DB  'The total of this month is: $' 

MENU0                   DB '[0] Exit $'                           
MENU1                   DB '[1] Compute the grand total $' 
MENU2                   DB '[2] Compute the total for an employee $' 
MENU3                   DB '[3] Compute the total for a month $'
MENU4                   DB '[4]  $'
       
         .CODE
       .STARTUP
       
       
       
        ; Record 1: date = January 4TH, employee = 7, amount charged = 10
        MOV CC_DATABASE[0], 00010010B 
        MOV CC_DATABASE[1], 00011100B 
        MOV CC_DATABASE[2], 00001010B 
        
        ; Record 2: date = October 7th, employee = 7, amount charged = 1000
        MOV CC_DATABASE[3], 10100011B ; first 8 bits
        MOV CC_DATABASE[4], 10011111B ; last 8 bits
        MOV CC_DATABASE[5], 11101000B ; middle 8 bits                      
        
        ; Record 2: date = January 10th, employee = 3, amount charged = 50
        MOV CC_DATABASE[6], 00010101B ; first 8 bits
        MOV CC_DATABASE[7], 00001101B ; last 8 bits
        MOV CC_DATABASE[8], 11110100B ; middle 8 bits
        
        
        ; Record 3: invalid
        MOV CC_DATABASE[9], 00000000B
        MOV CC_DATABASE[10], 00000000B
        MOV CC_DATABASE[11], 00000000B 
        
        
        MOV CX, N_RECORDS
        XOR DI, DI
        
cyclecount:
        XOR AX, AX
        XOR BX, BX
        MOV AL, CC_DATABASE[DI]
        AND AL, 11110000B
        SHR AL, 4
        CMP AL, 0 
        JE endcycle
        ADD DI, 3
        LOOP cyclecount
endcycle:
        XOR AX, AX
        MOV AX, N_RECORDS
        SUB AX, CX  ;X CICLI + Y CICLI FATTI (NON FACCIO + 1 PERCH' L'ULTIMO E' 0000)
        MOV EFF_REC, AX         
        
        
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

;----------------------------------------

C0 PROC
        JMP end 
        RET
C0 ENDP        

;----------------------------------------

C1 PROC
            
        MOV CX, EFF_REC
        XOR DI, DI
        
cycle1:
        XOR AX, AX
        MOV AH, CC_DATABASE[DI + 1]
        MOV AL, CC_DATABASE[DI + 2]
        AND AH, 00000011B
        ADD TOTAL_CHARGE, AL
        ADC TOTAL_CHARGE + 1, AH
        ADC TOTAL_CHARGE + 2, 0
        ADD DI, 3
        LOOP cycle1
        
        
        MOV AL, TOTAL_CHARGE
        MOV AH, TOTAL_CHARGE + 1
        
        RET
        
C1 ENDP


;----------------------------------------


C2 PROC
    
        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET Item2input
        INT 21H
        
        XOR AX, AX
        MOV AX, 2
        PUSH AX
        CALL readDecimal
        POP AX
        MOV CODE_EMP, AL
        
        XOR DI, DI
        MOV CX, EFF_REC
        
cycle2:

        XOR AX, AX
        XOR BX, BX
        MOV AL, CC_DATABASE[DI + 1]
        AND AL, 01111100B
        SHR AL, 2
        CMP AL, CODE_EMP
        JE  equalcode
        JMP notequalcode
equalcode:
        MOV BH, CC_DATABASE[DI + 1]
        MOV BL, CC_DATABASE[DI + 2]
        AND BH, 00000011B
        ADD TOTAL_CHARGE_EMP, BL
        ADC TOTAL_CHARGE_EMP + 1, BH
        ADC TOTAL_CHARGE_EMP + 2, 0
notequalcode:
        ADD DI, 3
        LOOP cycle2
        
        RET
        
C2 ENDP                
        

;----------------------------------------

        
C3 PROC        

        XOR AX, AX
        XOR DX, DX
        MOV AH, 9
        MOV DX, OFFSET Item3input
        INT 21H
        
        XOR AX, AX
        MOV AX, 2
        PUSH AX
        CALL readDecimal
        POP AX
        MOV MONTH, AL
        
        XOR DI, DI
        MOV CX, EFF_REC
                                
                 
cycle3:
        XOR AX, AX
        XOR BX, BX
        MOV AL, CC_DATABASE[DI]
        AND AL, 11110000B
        SHR AL, 4
        CMP AL, MONTH
        JE  equalmonth
        JMP notequalmonth
equalmonth:
        MOV BH, CC_DATABASE[DI + 1]
        MOV BL, CC_DATABASE[DI + 2]
        AND BH, 00000011B
        ADD TOTAL_CHARGE_MONTH, BL
        ADC TOTAL_CHARGE_MONTH + 1, BH
        ADC TOTAL_CHARGE_MONTH + 2, 0
notequalmonth:
        ADD DI, 3
        LOOP cycle3
                                            
        RET
        
C3 ENDP                    
                    
                    
;----------------------------------------                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                            
                    
                
         
;-----------------------------------------------------------------------------        
                      
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


;-----------------------------------------------------------------------------

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



;-----------------------------------------------------------------------------              

end:
       
       .EXIT
        END 
             