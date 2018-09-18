  
D       EQU 0
K       EQU 1
M       EQU 2 
MAX_MIN EQU 240

       .MODEL small
       .STACK
       .DATA  

UPDATE    DB  3 DUP(0, 0, 0)
MENU      DW  OPTION1, OPTION2, OPTION3, OPTION4  
BUFFER    DB  8  DUP(0)

DECILITERS         DB   0
KM                 DB   0
MINUTES            DB   0
DEC_IN_TANK        DW   320
TOT_LIT_IN_TANK    DB   32 
LIT_IN_TANK        DB   0
AVG_SPEED          DB   0 
HOURSOnly          DB   0
MINUTESOnly        DB   0 
KM_ON_LITER        DB   0
D_PER_100KM        DB   0

MenuText  DB 'Menu: 1) enter an update (deciliters burned; Km driven, minutes driven) 2) display the current available parameters 3) completely refuel the tank and reset all parameters 4) exit the program $'
                    
Display             DB 'DISPLAY: $' 
NumOfKM             DB 'Overall number of Km driven = $'
Duration            DB 'Overall duration of the drive in minutes= $'
UsedDec             DB 'Overall used deciliters of fuel = $'
LitersInTank        DB 'Number of liters still in the tank = $';
AvgSpeed            DB 'Average speed in Km/hour = $'
DurationHoursMin    DB 'Overall duration of the drive in hours and minutes = $'
KmOnLiter           DB 'Km/ liter = $'
DecOn100Km          DB 'Deciliters per 100 Km = $' 

InputT              DB 'INPUT: deciliters = $'
KmT                 DB 'Km driven = $'
MinutesT            DB 'Minutes = $'

TwoPoint            DB ':$'

MaximumMin          DB 'Reached 240 minutes! Need a fuel. $'
ResetAll            DB 'RESET ALL!$'

                    
        
       .CODE
       .STARTUP
         
         
for:        
        
        XOR AX, AX 
        XOR BX, BX
        MOV AL, MAX_MIN   
        MOV BL, UPDATE[M]
        CMP BL, AL
        JB  continue
        
        
maximum_min:
        
        MOV AH, 9 
        MOV DX, OFFSET MaximumMin
        INT 21H
        CALL OPTION3
                
        
continue:        
        
        MOV AH, 9 
        MOV DX, OFFSET MenuText
        INT 21H
        
        MOV AX, 1 
        PUSH AX
        CALL readDecimal
        POP AX  
        
        MOV SI, AX
        SUB SI, 1
        SHL SI, 1
        
        CALL MENU[SI] 
            
        JMP for    
            
            
            
            

;---------------------------------------------------------------------------------            
            
OPTION1 PROC
        
        
        CALL emptyRow
        
        MOV AH, 9 
        MOV DX, OFFSET InputT
        INT 21H             
        
        MOV AX, 2 ;sarebbero tre ma limitiamo a 2
        PUSH AX
        CALL readDecimal
        POP AX
        
        ADD UPDATE[D], AL
                     
        CALL emptyRow
        
        
        MOV AH, 9 
        MOV DX, OFFSET KmT
        INT 21H             
        
        MOV AX, 2 ;sarebbero tre ma limitiamo a 2
        PUSH AX
        CALL readDecimal
        POP AX
        
        ADD UPDATE[K], AL
                     
        CALL emptyRow
        
        
        MOV AH, 9 
        MOV DX, OFFSET MinutesT
        INT 21H             
        
        MOV AX, 2 ;sarebbero tre ma limitiamo a 2
        PUSH AX
        CALL readDecimal
        POP AX           
        
        ADD UPDATE[M], AL
                     
        CALL emptyRow
        
        ;---------------------FINE INPUT--------
        
        XOR BX, BX
        XOR CX, CX
        XOR AX, AX 
        XOR DX, DX
        
        MOV BX, DEC_IN_TANK
        MOV CL, UPDATE[D]
        SUB BX, CX
        MOV AX, BX 
        MOV DL, 10
        DIV DL
        MOV LIT_IN_TANK, AL
        
        XOR AX, AX 
        XOR BX, BX
        
        MOV AL, UPDATE[K]
        MOV BL, 60
        MUL BL
        DIV UPDATE[M]
        MOV AVG_SPEED, AL
        
        
        XOR AX, AX
        XOR BX, BX
        
        MOV AL, UPDATE[M]
        MOV BL, 60
        DIV BL
        MOV HOURSOnly, AL
        MOV MINUTESOnly, AH
        
        XOR AX, AX
        XOR BX, BX
        XOR CX, CX
        
        MOV BL, UPDATE[D] 
        MOV AL, UPDATE[K]
        MOV CL, 10
        MUL CL
        DIV BL  
        MOV KM_ON_LITER, AL
        
        
        XOR AX, AX
        XOR BX, BX
        XOR CX, CX
        
        MOV AL, UPDATE[D]
        MOV CL, 100
        MUL CL
        MOV BL, UPDATE[K]
        DIV BL
        MOV D_PER_100KM, AL 
        
        CALL OPTION2
        
        
        RET
            
OPTION1 ENDP                

;---------------------------------------------------------------------------------

OPTION2 PROC
        
         
        MOV AH, 9 
        MOV DX, OFFSET Display
        INT 21H             
                     
        CALL emptyRow
        
        ;-----------print km
         
        MOV AH, 9 
        MOV DX, OFFSET NumOfKm
        INT 21H
        
        XOR AX, AX
        LEA AX, BUFFER          ;NON HO CAPITO A COSA SERVA MA E' FONDAMENTALE
        PUSH AX
        MOV AL, UPDATE[K]
        PUSH AX
        CALL writeDecimal
        POP AX
        POP AX
        
        CALL emptyRow
        
        
        ;-----------print minutes
        
        XOR AX, AX 
        MOV AH, 9 
        MOV DX, OFFSET Duration
        INT 21H
        
        XOR AX, AX  
        LEA AX, BUFFER
        PUSH AX
        MOV AL, UPDATE[M]
        PUSH AX
        CALL writeDecimal
        POP AX
        POP AX
        
        CALL emptyRow
        
        ;-----------print used deciliters
        
        XOR AX, AX 
        MOV AH, 9 
        MOV DX, OFFSET UsedDec
        INT 21H
        
        XOR AX, AX 
        LEA AX, BUFFER
        PUSH AX
        MOV AL, UPDATE[D]
        PUSH AX
        CALL writeDecimal
        POP AX 
        POP AX
        
        CALL emptyRow 
        
        
        ;-----------print liters in tank
        
        XOR AX, AX 
        MOV AH, 9 
        MOV DX, OFFSET LitersInTank
        INT 21H
        
        XOR AX, AX 
        LEA AX, BUFFER
        PUSH AX
        MOV AL, LIT_IN_TANK
        PUSH AX
        CALL writeDecimal
        POP AX
        POP AX
        
        CALL emptyRow 
        
        
        ;-----------print avg speed 
        
        XOR AX, AX 
        MOV AH, 9 
        MOV DX, OFFSET AvgSpeed
        INT 21H
        
        XOR AX, AX 
        LEA AX, BUFFER
        PUSH AX
        MOV AL, AVG_SPEED
        PUSH AX
        CALL writeDecimal
        POP AX
        POP AX
        
        CALL emptyRow 
        
        
        ;-----------print hours and min 
        
        XOR AX, AX 
        MOV AH, 9 
        MOV DX, OFFSET DurationHoursMin
        INT 21H
        
        XOR AX, AX
        LEA AX, BUFFER
        PUSH AX
        MOV AL, HOURSOnly
        PUSH AX
        CALL writeDecimal
        POP AX
        POP AX
        
        XOR AX, AX 
        
        MOV AH, 9
        MOV DX, OFFSET TwoPoint
        INT 21H
        
        XOR AX, AX 
        LEA AX, BUFFER
        PUSH AX
        MOV AL, MINUTESOnly
        PUSH AX
        CALL writeDecimal
        POP AX 
        POP AX
        
        CALL emptyRow 
        
        
        ;-----------print KM/LITER 
        
        XOR AX, AX 
        MOV AH, 9 
        MOV DX, OFFSET KmOnLiter
        INT 21H
        
        XOR AX, AX 
        LEA AX, BUFFER
        PUSH AX
        MOV AL, KM_ON_LITER
        PUSH AX
        CALL writeDecimal
        POP AX 
        POP AX
        
        CALL emptyRow 
        
        
        ;-----------print deciliter per 100km
        
        XOR AX, AX
        MOV AH, 9 
        MOV DX, OFFSET DecOn100Km
        INT 21H
        
        XOR AX, AX  
        LEA AX, BUFFER
        PUSH AX
        MOV AL, D_PER_100KM
        PUSH AX
        CALL writeDecimal
        POP AX 
        POP AX
        
        CALL emptyRow 
        
        
        
        RET
            
OPTION2 ENDP                

;---------------------------------------------------------------------------------

OPTION3 PROC
        
        MOV UPDATE[0], 0
        MOV UPDATE[1], 0
        MOV UPDATE[2], 0
        MOV D_PER_100KM, 0
        MOV KM_ON_LITER, 0
        MOV HOURSOnly, 0
        MOV MINUTESOnly, 0
        MOV AVG_SPEED, 0
        MOV LIT_IN_TANK, 32
    
        RET
            
OPTION3 ENDP                

;---------------------------------------------------------------------------------

OPTION4 PROC
        
        
        JMP end
        
            
OPTION4 ENDP                
        
;---------------------------------------------------------------------------------

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

;---------------------------------------------------------------------------------

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

;---------------------------------------------------------------------------------


writeDecimal PROC
        
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
        
writeDecimal ENDP


end:
       
       .EXIT
        END 