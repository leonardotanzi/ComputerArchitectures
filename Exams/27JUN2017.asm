NORTH   EQU 78
SUD     EQU 83
CENTRAL EQU 67 
PLUS    EQU 43
MINUS   EQU 45
                                                                                 

       .MODEL small
       .STACK
       .DATA  

DAYLIGHT        DW  4 DUP(?)
MONTHS          DB  12 DUP(?)
J_TABLE         DW  M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12 

MONTH_LOC       DB  ?
DAY_LOC         DB  ?
HOUR_LOC        DB  ?
CITY_LOC        DB  25, ?, 25 DUP(?)
HEMISPHERE_LOC  DB  ?
TIMEZONE_LOC    DB  ?  

MONTH_REM       DB  ?
DAY_REM         DB  ?
HOUR_REM        DB  ?
CITY_REM        DB  25, ?, 25 DUP(?)
HEMISPHERE_REM  DB  ?
TIMEZONE_REM    DB  ?  
                
TMP             DW  ?  

FLAG_LOC        DB  ?    
FLAG_REM        DB  ?
FLAG_FIN        DB  ? 

SIGN_LOC        DB  ? 
SIGN_REM        DB  ?

Jan    DB  'January $'
Feb    DB  'Febrary $'
Mar    DB  'March $'
Apr    DB  'April $'
May    DB  'May $'
Jun    DB  'June $'
Jul    DB  'July $'
Aug    DB  'August $'
Sep    DB  'September $'
Oct    DB  'October $'
Nov    DB  'November $'
Dcb    DB  'December $'

MonthT      DB  'Insert the month: $'
DayT        DB  'Insert the day: $'
HourT       DB  'Insert the hour: $' 
CityT       DB  'Insert the city: $'
HemisphereT DB  'Insert the emishpere (N for north, S for south, C for central): $'
TimeZoneT   DB  'Insert the timezone (with + or -): $' 

CityR       DB  'Insert the remote city: $'
HemisphereR DB  'Insert the remote emishpere (N for north, S for south, C for central): $'
TimeZoneR   DB  'Insert the remote timezone(woth + or -): $'
        
       .CODE
       .STARTUP
       
       
        MOV DAYLIGHT[0], 0000111101000010B
        MOV DAYLIGHT[1], 0110101110100010B
        MOV DAYLIGHT[2], 1001000001000010B
        MOV DAYLIGHT[3], 1110100000100010B
        
        MOV MONTHS[0],  OFFSET Jan        ;per stampare, ma alla fine non ho fatto output
        MOV MONTHS[1],  OFFSET Feb
        MOV MONTHS[2],  OFFSET Mar
        MOV MONTHS[3],  OFFSET Apr
        MOV MONTHS[4],  OFFSET May
        MOV MONTHS[5],  OFFSET Jun
        MOV MONTHS[6],  OFFSET Jul
        MOV MONTHS[7],  OFFSET Aug
        MOV MONTHS[8],  OFFSET Sep
        MOV MONTHS[9],  OFFSET Oct
        MOV MONTHS[10], OFFSET Nov
        MOV MONTHS[11], OFFSET Dcb
        
        
        ;----------------INPUT BEGIN----------------------------
        
        
        MOV AH, 9
        MOV DX, OFFSET CityT
        INT 21H  
        
        XOR AX, AX
        MOV AH, 10
        MOV DX, OFFSET CITY_LOC
        INT 21H
        
        MOV SI, OFFSET CITY_LOC + 1 ;NUMBER OF CHARACTERS ENTERED.
        MOV CL, [ SI ] ;MOVE LENGTH TO CL.
        MOV CH, 0      ;CLEAR CH TO USE CX. 
        INC CX ;TO REACH CHR(13).
        ADD SI, CX ;NOW SI POINTS TO CHR(13).
        MOV AL, '$'
        MOV [ SI ], AL ;REPLACE CHR(13) BY '$'.
        
        ;MOV AH, 9 ;SERVICE TO DISPLAY STRING.
        ;MOV DX, OFFSET CITY_LOC + 2 ;MUST END WITH '$'.
        ;INT 21H
        
        CALL emptyRow
        
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET HemisphereT
        INT 21H
        XOR AX, AX 
        MOV AH, 1
        INT 21H
        MOV HEMISPHERE_LOC, AL
        CALL emptyRow
        
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET TimeZoneT
        INT 21H
        XOR AX, AX
        MOV AH, 1
        INT 21H
        MOV SIGN_LOC, AL           ;prima leggo il segno, che se e' meno inverto
        XOR AX, AX
        MOV AX, 2
        PUSH AX    
        CALL readDecimal
        POP AX  
        MOV TIMEZONE_LOC, AL 
        CMP SIGN_LOC, MINUS
        JE  negative
        JMP positive   
negative: 
        NEG TIMEZONE_LOC        
positive:                     
        CALL emptyRow
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET MonthT
        INT 21H
        XOR AX, AX
        MOV AX, 2
        PUSH AX    
        CALL readDecimal
        POP AX   
        MOV MONTH_LOC, AL
        CALL emptyRow
        
        
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET DayT
        INT 21H
        XOR AX, AX
        MOV AX, 2
        PUSH AX    
        CALL readDecimal
        POP AX   
        MOV DAY_LOC, AL
        CALL emptyRow
        
        
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET HourT
        INT 21H
        XOR AX, AX
        MOV AX, 2
        PUSH AX    
        CALL readDecimal
        POP AX   
        MOV HOUR_LOC, AL
        CALL emptyRow
        
        
        ;;;PRINT LOCAL INPUT                                 
        
        
        PUSH AX
        
        XOR AX, AX
        MOV AL, MONTH_LOC           ;metto mese giorno ora su 16 bit per fare 
        SHL AX, 10                  ;confronto con DAYLIGHT[]
        ADD TMP, AX
        XOR AX, AX  
        MOV AL, DAY_LOC 
        SHL AX, 5
        ADD TMP, AX 
        XOR AX, AX
        MOV AL, HOUR_LOC
        ADD TMP, AX
        
        POP AX
        
        ;------------INPUT END--------------------------------------
        
        
        ;------------INPUT REMOTE BEGIN-----------------------------      
        
        MOV AH, 9
        MOV DX, OFFSET CityR
        INT 21H  
        
        XOR AX, AX
        MOV AH, 10
        MOV DX, OFFSET CITY_REM
        INT 21H
        
        MOV SI, OFFSET CITY_REM + 1 ;NUMBER OF CHARACTERS ENTERED.
        MOV CL, [ SI ] ;MOVE LENGTH TO CL.
        MOV CH, 0      ;CLEAR CH TO USE CX. 
        INC CX ;TO REACH CHR(13).
        ADD SI, CX ;NOW SI POINTS TO CHR(13).
        MOV AL, '$'
        MOV [ SI ], AL ;REPLACE CHR(13) BY '$'.
        
        CALL emptyRow
        
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET HemisphereR
        INT 21H
        XOR AX, AX 
        MOV AH, 1
        INT 21H
        MOV HEMISPHERE_REM, AL
        CALL emptyRow
        
        XOR AX, AX
        MOV AH, 9
        MOV DX, OFFSET TimeZoneR
        INT 21H
        XOR AX, AX
        MOV AH, 1
        INT 21H
        MOV SIGN_REM, AL  
        XOR AX, AX
        MOV AX, 2
        PUSH AX    
        CALL readDecimal
        POP AX
        MOV TIMEZONE_REM, AL 
        CMP SIGN_REM, MINUS
        JE  negativerem
        JMP positiverem   
negativerem: 
        NEG TIMEZONE_REM        
positiverem:                 
        CALL emptyRow   
        
        
        ;PRINT REMOTE INPUT
        
        ;-----------------INPUT REMOTE ENDS-----------------------
        
        ;-----------------VERIFY DST BEGINS-----------------------
        
        
        CALL VerifyDST    ;se la citta locale e' dst setta flagloc a 1
        
        CALL VerifyDSTrem ;se la citta remota e' dst setta flagrem a 1
                          ;andrebbe riscritto una unico procedura per entrambi
        
        
        ;QUA POSSO AVERE 4 COMBINAZIONI DI FLAG, 00, 01, 10, 11. 
        ;MI INTERESSANO SOLO 10 E 01
        
        CALL CombineFlag ;dopo qua se flag_fin e' 01 o 10 (utili) o 11 e 00 (inutili) 
        
        
        ;-----------------VERIFY DST ENDS-----------------------
        
        ;-----------------CALC NEW ENDS-----------------------
        
        XOR AX, AX
        MOV AL, TIMEZONE_REM        ;x = timerem - timeloc (trovo la differenza tra i due fusi)
        SUB AL, TIMEZONE_LOC
        ADD HOUR_LOC, AL            ;aggiungo all'orario locale
        
        CMP FLAG_FIN, 01B           ;confronto i flag, se c'e' dst devo agg o sott 1
        JE dst01
        CMP FLAG_FIN, 10B
        JE dst10
        JMP enddst
dst01:
        ADD HOUR_LOC, 1
        JMP enddst
dst10:
        SUB HOUR_LOC, 1
enddst:                             ;guardo se per caso ho sforato le 24 ore o le 0
        CMP HOUR_LOC, 24
        JG greater
        CMP HOUR_LOC, 0
        JL lower 
        JMP endconf
greater:
        ADD DAY_LOC, 1
        SUB HOUR_LOC, 24
        JMP endconf                                 
lower:
        SUB DAY_LOC, 1
        ADD HOUR_LOC, 24
endconf:
        XOR AX, AX
        
        MOV AL, DAY_LOC          ;intanto setto, poi puo' essere che dovro modificare
        MOV DAY_REM, AL          ;mese
        MOV AL, HOUR_LOC
        MOV HOUR_REM, AL
        MOV AL, MONTH_LOC 
        MOV MONTH_REM, AL
                                 
        CMP DAY_REM, 28          ;check del mese
        JG  change_month
        CMP DAY_REM, 0
        JLE change_month
        JMP end       
        
change_month:
        XOR AX, AX  
        MOV AL, MONTH_REM
        SUB AL, 1
        SHL AL, 1
        MOV DI, AX
        CALL J_TABLE[DI] 
        
        JMP end
               
;----------------------------------------------------------------------------                   



M1 PROC  ;JANUARY 31
    
        CMP DAY_REM, 31 
        JG  gr1 
        CMP DAY_REM, 1
        JL  lo1
        JMP end1
lo1:
        MOV DAY_REM, 31
        SUB MONTH_REM, 1        
gr1:
        MOV DAY_REM, 1
        ADD MONTH_REM, 1
end1:        
    RET
    
M1 ENDP   


M2 PROC  ;FEB 28
    
        CMP DAY_REM, 28 
        JG  gr2 
        CMP DAY_REM, 1
        JL  lo2
        JMP end2
lo2:
        MOV DAY_REM, 28
        SUB MONTH_REM, 1        
gr2:
        MOV DAY_REM, 1
        ADD MONTH_REM, 1
end2:        
    RET
    
M2 ENDP


M3 PROC  ;MARCH 31
    
        CMP DAY_REM, 31 
        JG  gr3 
        CMP DAY_REM, 1
        JL  lo3
        JMP end3
lo3:
        MOV DAY_REM, 31
        SUB MONTH_REM, 1        
gr3:
        MOV DAY_REM, 1
        ADD MONTH_REM, 1
end3:        
    RET
    
M3 ENDP  



M4 PROC  ;APRIL 30
    
        CMP DAY_REM, 30 
        JG  gr4 
        CMP DAY_REM, 1
        JL  lo4
        JMP end4
lo4:
        MOV DAY_REM, 30
        SUB MONTH_REM, 1        
gr4:
        MOV DAY_REM, 1
        ADD MONTH_REM, 1
end4:        
    RET
    
M4 ENDP


M5 PROC  ;MAY 31
    
        CMP DAY_REM, 31 
        JG  gr5 
        CMP DAY_REM, 1
        JL  lo5
        JMP end5
lo5:
        MOV DAY_REM, 31
        SUB MONTH_REM, 1        
gr5:
        MOV DAY_REM, 1
        ADD MONTH_REM, 1
end5:        
    RET
    
M5 ENDP 




M6 PROC  ;JUNE 30
    
        CMP DAY_REM, 30 
        JG  gr6 
        CMP DAY_REM, 1
        JL  lo6
        JMP end6
lo6:
        MOV DAY_REM, 30
        SUB MONTH_REM, 1        
gr6:
        MOV DAY_REM, 1
        ADD MONTH_REM, 1
end6:        
    RET
    
M6 ENDP



M7 PROC  ;JULE 31
    
        CMP DAY_REM, 31 
        JG  gr7 
        CMP DAY_REM, 1
        JL  lo7
        JMP end7
lo7:
        MOV DAY_REM, 31
        SUB MONTH_REM, 1        
gr7:
        MOV DAY_REM, 1
        ADD MONTH_REM, 1
end7:        
    RET
    
M7 ENDP   


M8 PROC  ;AUG 31
    
        CMP DAY_REM, 31 
        JG  gr8 
        CMP DAY_REM, 1
        JL  lo8
        JMP end8
lo8:
        MOV DAY_REM, 31
        SUB MONTH_REM, 1        
gr8:
        MOV DAY_REM, 1
        ADD MONTH_REM, 1
end8:        
    RET
    
M8 ENDP



M9 PROC  ;SEPT 30
    
        CMP DAY_REM, 30 
        JG  gr9 
        CMP DAY_REM, 1
        JL  lo9
        JMP end9
lo9:
        MOV DAY_REM, 30
        SUB MONTH_REM, 1        
gr9:
        MOV DAY_REM, 1
        ADD MONTH_REM, 1
end9:        
    RET
    
M9 ENDP   


M10 PROC  ;OCT 31
    
        CMP DAY_REM, 31 
        JG  gr10 
        CMP DAY_REM, 1
        JL  lo10
        JMP end10
lo10:
        MOV DAY_REM, 31
        SUB MONTH_REM, 1        
gr10:
        MOV DAY_REM, 1
        ADD MONTH_REM, 1
end10:        
    RET
    
M10 ENDP 


M11 PROC  ;NOV 30
    
        CMP DAY_REM, 30
        JG  gr11 
        CMP DAY_REM, 1
        JL  lo11
        JMP end11
lo11:
        MOV DAY_REM, 30
        SUB MONTH_REM, 1        
gr11:
        MOV DAY_REM, 1
        ADD MONTH_REM, 1
end11:        
    RET
    
M11 ENDP


M12 PROC  ;JANUARY 31
    
        CMP DAY_REM, 31 
        JG  gr12 
        CMP DAY_REM, 1
        JL  lo12
        JMP end12
lo12:
        MOV DAY_REM, 31
        SUB MONTH_REM, 1        
gr12:
        MOV DAY_REM, 1
        ADD MONTH_REM, 1
end12:        
    RET
    
M12 ENDP   







;----------------------------------------------------------------------------                   


CombineFlag PROC
        
        MOV FLAG_FIN, 0
        
        CMP FLAG_LOC, 1
        JE one
        CMP FLAG_REM, 1
        JNE no

zeroone:
        MOV FLAG_FIN, 01B
        JMP no
                        
               
one:    CMP FLAG_REM, 0
        JE onezero
        JMP no
                       
onezero:
        MOV FLAG_FIN, 10B  
no:    

        RET
        
CombineFlag ENDP

;----------------------------------------------------------------------------                   

VerifyDST PROC
        
        PUSH BX
        PUSH AX
        
        XOR AX, AX
        MOV FLAG_LOC, 0
        MOV AL, HEMISPHERE_LOC 
        CMP AL, CENTRAL
        JE  not_dst
        CMP AL, NORTH
        JE  north_dst

south_dst:
        MOV AX, DAYLIGHT[2]
        AND AX, 0011111111111111B
        MOV BX, DAYLIGHT[3]
        AND BX, 0011111111111111B
        CMP AX, TMP
        JL not_dst
        CMP BX, TMP
        JG not_dst
        MOV FLAG_LOC, 1 
        JMP not_dst
        
 
north_dst:        
        MOV AX, DAYLIGHT[0]
        AND AX, 0011111111111111B
        MOV BX, DAYLIGHT[1]
        AND BX, 0011111111111111B
        CMP AX, TMP
        JL not_dst
        CMP BX, TMP
        JG not_dst
        MOV FLAG_LOC, 1
        
not_dst:        
        
        POP AX
        POP BX
        RET

VerifyDST ENDP           
       
       
VerifyDSTRem PROC
        
        PUSH BX
        PUSH AX
        
        XOR AX, AX
        MOV FLAG_REM, 0
        MOV AL, HEMISPHERE_REM 
        CMP AL, CENTRAL
        JE  not_dstrem
        CMP AL, NORTH
        JE  north_dstrem

south_dstrem:
        MOV AX, DAYLIGHT[2]
        AND AX, 0011111111111111B
        MOV BX, DAYLIGHT[3]
        AND BX, 0011111111111111B
        CMP AX, TMP
        JL not_dstrem
        CMP BX, TMP
        JG not_dstrem
        MOV FLAG_REM, 1 
        JMP not_dstrem
        
 
north_dstrem:        
        MOV AX, DAYLIGHT[0]
        AND AX, 0011111111111111B
        MOV BX, DAYLIGHT[1]
        AND BX, 0011111111111111B
        CMP AX, TMP
        JL not_dstrem
        CMP BX, TMP
        JG not_dstrem
        MOV FLAG_REM, 1
        
not_dstrem:        
        
        POP AX
        POP BX
        RET

VerifyDSTrem ENDP           
       

;----------------------------------------------------------------------------                   

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
            
;----------------------------------------------------------------------------            
       
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
   

;----------------------------------------------------------------------------   
   
end:
       
       .EXIT
        END 
             
             