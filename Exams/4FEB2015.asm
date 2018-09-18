;NON E' COMPLETO, funzione per PLAYER1 ma no sbatti di MODIFICARE  2 E 3



M    EQU 3
N    EQU 11  

       .MODEL small
       .STACK
       .DATA  
       
WGF_RACE        DB  N DUP(?)
JUMP_T          DW  B0000, B0001, B0010, B0011, B0100, B0101, B0110, B0111 
BUFFER          DB  8  DUP(0)  

INDEX1          DW ?
INDEX2          DW ?
INDEX3          DW ?
NUM_DIE         DW ?
PAUSE1          DW ?
PAUSE2          DW ?
PAUSE3          DW ?  
                            
CellWord        DB  'Cell number $' 
B0              DB  ' has no penalty/award $'
B1              DB  ' has an award: double the number in the die and move; $' 
B2              DB  ' has an award: move two cell forward; $'
B3              DB  ' has an award: throw the die again and go forward; $'
B4              DB  ' has a penalty: miss the turn; $'
B5              DB  ' has a penalty: move two cell backward; $'
B6              DB  ' has a penalty: throw the die again and go backward; $'
B7              DB  ' has a penalty: say loudly I love to play this crazy game and I am a liar!!! $'
                            
StartPlayer1    DB  'Player 1 please throw the die and enter the number (1-6) $'
TooFar1         DB  'Player 1 is gone too far! Go back $'        
Win1            DB  'Player 1 win the game! $'
Position1       DB  'Player 1 is in $' 

StartPlayer2    DB  'Player 2 please throw the die and enter the number (1-6) $'
TooFar2         DB  'Player 2 is gone too far! Go back $'        
Win2            DB  'Player 2 win the game! $'
Position2       DB  'Player 2 is in $'

StartPlayer3    DB  'Player 3 please throw the die and enter the number (1-6) $'
TooFar3         DB  'Player 3 is gone too far! Go back $'        
Win3            DB  'Player 3 win the game! $'
Position3       DB  'Player 3 is in $'

       .CODE
       .STARTUP
       
       
       CALL fill_wgf        ;to fill the vector
       
       
       
Player1:
        
        
        MOV AX, PAUSE1       ;check the flag, if it's 1 the player miss the turn
        CMP AX, 1
        JE one1
        JMP zero1
        
one1:   
        MOV PAUSE1, 0        ;re-initialize to zero the flag
        JMP Player2 
        
zero1:              
        
        CALL emptyRow
        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET StartPlayer1    ;print("Player 1 please throw the...")
        INT 21H
        
        CALL emptyRow
        MOV AX, 1             ;numero di cifre da leggere
        PUSH AX               ;AX passato via stack
        CALL readDecimal
        POP AX
        
        ADD INDEX1, AX        ;aggiungo all'indice il valore che esce dal dado
        MOV NUM_DIE, AX       ;salvo il numero in NUM_DIE
        
        
Check PROC 
        
        PUSH AX
        PUSH BX
        PUSH DX
        ;PUSH DI no cause I need it's value 
                         
        MOV AX, INDEX1
        SUB AX, N-1             ;sottraggo ad AX 60
        CMP AX, 0               ;se AX e' maggiore di 60, ho sforato, se uguale ho vinto
        
        PUSH AX                 ;mi serve dopo questo valore in (*)
        
        JE winner1
        JG too_much1 
        JMP continue1
        

winner1: 
        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET Win1      ;print("The winner is...")
        INT 21H
        POP DX     ;svuoto lo stack prima 
        POP BX
        POP AX
        JMP end
        
too_much1:

        CALL emptyRow 
        
        
        MOV AH, 9
        MOV DX, OFFSET TooFar1    ;print("Too much...")
        INT 21H  
        
        POP AX      ;(*)recupero il numero in eccesso, cioe' quanto devo indietreggiare 
        
        MOV BX, N-1          ;sposto 60 in bx
        SUB BX, AX           ;sottraggo a 60 ax per trovare la casella finale
        MOV INDEX1, BX       ;salvo il nuovo indice
        
        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET Position1 ;"Player1 is in"
        INT 21H 
        
        MOV DI, INDEX1           ; "CELL 7"
        CALL printCell
        
        
continue1:
        
        
        
        
        MOV DI, INDEX1        ;accedo alla posizione DI = INDEX1 
        XOR AX, AX
        MOV AL, WGF_RACE[DI]  ;salvo in ax il contenuto
        
       
        CALL emptyRow
        CALL printCell          ;print("CELL 3")
       
        
        MOV SI, AX              ;salvo l'indirizzo e moltiplico per due perche
        SHL SI, 1               ;e' a 16 bit quindi devo spostarmi due a due
        
        XOR BX, BX
        XOR DX, DX
        MOV CX, INDEX1
        CALL JUMP_T[SI]         ;"has an award: throw again the die..."
        
        
        MOV INDEX1, CX          ;questi tre vengono modificati a seconda del numero
        ADD INDEX1, BX
        MOV PAUSE1, DX 
        
               

        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET Position1 ;"Player1 is in"
        INT 21H 
        
        MOV DI, INDEX1           ; "CELL 7"
        CALL printCell
        
        ;rifaccio il controllo se il gioco e' finito
          
        MOV AX, INDEX1
        SUB AX, N-1             ;sottraggo ad AX 60
        CMP AX, 0               ;se AX e' maggiore di 60, ho sforato, se uguale ho vinto
        
        PUSH AX                 ;mi serve dopo questo valore in (*)
        
        JE winner12
        JG too_much12 
        JMP continue12
        

winner12: 
        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET Win1      ;print("The winner is...")
        INT 21H
        JMP end
        
too_much12:

        CALL emptyRow 
        
        
        MOV AH, 9
        MOV DX, OFFSET TooFar1    ;print("Too much...")
        INT 21H  
        
        POP AX      ;(*)recupero il numero in eccesso, cioe' quanto devo indietreggiare 
        
        MOV BX, N-1          ;sposto 60 in bx
        SUB BX, AX           ;sottraggo a 60 ax per trovare la casella finale
        MOV INDEX1, BX       ;salvo il nuovo indice
        
        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET Position1 ;"Player1 is in"
        INT 21H 
        
        MOV DI, INDEX1           ; "CELL 7"
        CALL printCell
        
        
continue12:
                  
          
          
                    
          
          
          
Player2:
          
        PUSH AX
        MOV AX, PAUSE2
        CMP AX, 1
        JE one2
        JMP zero2
        
one2:   
        MOV PAUSE2, 0 
        JMP Player3 
        
zero2:              
        
        CALL emptyRow
        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET StartPlayer2    ;"Player 1 please throw the..."
        INT 21H
        
        CALL emptyRow
        MOV AX, 1 ;numero di cifre da leggere
        PUSH AX
        CALL readDecimal
        POP AX
        
        ADD INDEX2, AX
        MOV NUM_DIE, AX
        
        PUSH AX
        SUB AX, N-1
        CMP AX, 0
        JE winner2
        JG too_much2 
        JMP continue2
        

winner2: 
        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET Win2
        INT 21H
        JMP end
        
too_much2:

        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET TooFar2
        INT 21H  
        
        MOV BX, N-1
        SUB BX, AX
        MOV INDEX2, BX 
        
        
continue2:
        
        POP AX
        MOV DI, INDEX2
        MOV AL, WGF_RACE[DI] 
        
        CALL emptyRow
        CALL printCell          ;"CELL 3"
        
        MOV SI, AX
        SHL SI, 1
        
        XOR BX, BX
        XOR DX, DX
        MOV CX, INDEX2
        CALL JUMP_T[SI]         ;"has an award: throw again the die..."
        
        MOV INDEX2, CX
        ADD INDEX2, BX
        MOV PAUSE2, DX 
        
        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET Position2 ;"Player1 is in"
        INT 21H 
        
        MOV DI, INDEX2           ; "CELL 7"
        CALL printCell
        
        
        
        
        
        
          

Player3: 
        
        PUSH AX
        MOV AX, PAUSE3
        CMP AX, 1
        JE one3
        JMP zero3
        
one3:   
        MOV PAUSE3, 0 
        JMP Player1 
        
zero3:              
        
        CALL emptyRow 
        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET StartPlayer3    ;"Player 1 please throw the..."
        INT 21H
        
        CALL emptyRow
        MOV AX, 1 ;numero di cifre da leggere
        PUSH AX
        CALL readDecimal
        POP AX
        
        ADD INDEX3, AX
        MOV NUM_DIE, AX
        
        PUSH AX
        SUB AX, N-1
        CMP AX, 0
        JE winner3
        JG too_much3 
        JMP continue3
        

winner3: 
        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET Win3
        INT 21H
        JMP end
        
too_much3:

        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET TooFar3
        INT 21H  
        
        MOV BX, N-1
        SUB BX, AX
        MOV INDEX3, BX 
        
        
continue3:
        
        POP AX
        MOV DI, INDEX3
        MOV AL, WGF_RACE[DI] 
        
        CALL emptyRow
        CALL printCell          ;"CELL 3"
        
        MOV SI, AX
        SHL SI, 1
        
        XOR BX, BX
        XOR DX, DX
        MOV CX, INDEX3
        CALL JUMP_T[SI]         ;"has an award: throw again the die..."
        
        MOV INDEX3, CX
        ADD INDEX3, BX
        MOV PAUSE3, DX 
        
        CALL emptyRow
        MOV AH, 9
        MOV DX, OFFSET Position3 ;"Player1 is in"
        INT 21H 
        
        MOV DI, INDEX3           ; "CELL 7"
        CALL printCell
        
        JMP Player1
                         
       

B0000 PROC
    
    
    MOV AH, 9
    MOV DX, OFFSET B0
    INT 21H 
    RET
    
B0000 ENDP    
    
    


B0001 PROC
    
    
    MOV AH, 9
    MOV DX, OFFSET B1
    INT 21H 
    MOV BX, NUM_DIE
    SHL BX, 1
    RET
    
B0001 ENDP
    
    
    
    
B0010 PROC
    
    
    MOV AH, 9
    MOV DX, OFFSET B2
    INT 21H 
    INC CX
    INC CX
    RET
    
B0010 ENDP 
     
       
       
B0011 PROC
    
    
    
    MOV AH, 9
    MOV DX, OFFSET B3
    INT 21H 
    
    MOV AX, 1 ;numero di cifre da leggere
    PUSH AX
    CALL readDecimal
    POP AX       
    
    ADD CX, AX
    RET
    
B0011 ENDP    
   
   

B0100 PROC
    
    
    MOV AH, 9
    MOV DX, OFFSET B4
    INT 21H
    
    MOV DX, 1
    RET
    
B0100 ENDP




B0101 PROC
    
    
    MOV AH, 9
    MOV DX, OFFSET B5
    INT 21H  
    
    DEC CX
    DEC CX
    
    CMP CX, 0
    JL  lower1
    JMP greater1
    
lower1:
    XOR CX, CX
greater1:        
    RET
    
B0101 ENDP


B0110 PROC
    
    
    MOV AH, 9
    MOV DX, OFFSET B6
    INT 21H 
    
    MOV AX, 1 ;numero di cifre da leggere
    PUSH AX
    CALL readDecimal
    POP AX       
    
    SUB CX, AX 
    
    CMP CX, 0
    JL  lower2
    JMP greater2
    
lower2:
    XOR CX, CX
greater2:
    
    RET


B0110 ENDP

          
          
B0111 PROC
    
   
    MOV AH, 9
    MOV DX, OFFSET B7
    INT 21H 
    RET

B0111 ENDP
              
              
 
printCell PROC
        
        PUSH AX
        PUSH DX
        
        lea ax, BUFFER          ;NON HO CAPITO A COSA SERVA MA E' FONDAMENTALE
        push ax
        
        MOV AH, 9
        MOV DX, OFFSET CellWord
        INT 21H 
        
        PUSH DI
        CALL printDecimal
        POP DI
        
        pop ax
        
        POP DX
        POP AX
        
        RET      
    
    
printCell ENDP      
         
         
         
fill_wgf PROC
     
        MOV WGF_RACE[0], 0B
        
        PUSH CX
        PUSH DI
        PUSH AX
        PUSH BX
        
        MOV CX, 1
        MOV DI, 1

for:        
        
        MOV AX, DI
        MOV BL, 8
        DIV BL
        MOV WGF_RACE[DI], AH
        INC DI
        INC CX
         
        CMP CX, N
        JL  for
        
        POP BX
        POP AX
        POP DI
        POP CX
        
        RET 

fill_wgf ENDP

        

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



readDecimal proc 
    
        PUSH BP
        MOV BP, SP
    
        push ax
        push cx
        push dx
        
        mov cx, [bp+4]  ;max number of digits to be read
        mov dx, 0
readLoop:  
    
        mov ah, 1
        int 21h
        cmp al, 13  ; l'a-capo
        je endReadLoop
        
        sub al, '0' ;per spostarlo nella giusta posizione ascii
        mov ch, al
        
        mov ax, dx
        mov dx, 10  ;perche' se e' il primo numero moltiplicato per 10, secondo 1
        mul dx
        mov dx, ax
        
        add dl, ch
        adc dh, 0
        
        xor ch, ch
        loop readLoop
    
endReadLoop:    
        mov [bp+4], dx
              
        pop dx
        pop cx
        pop ax
        pop bp
        ret
readDecimal endp  
 
  
  
 
printDecimal proc
        push bp
        mov bp, sp
        
        push ax
        push dx
        push di
        push bx
        
        mov di, [bp+6]      ;buffer address 
        
        mov ax, [bp+4]      ;number
      
        
         
conv:
        xor dx, dx
        mov bx, 10
loopDiv:
        div bx
        add dl, '0'         ;remainder: binary -> ascii
        mov [di], dl
        inc di
        xor dx, dx
        cmp ax, 0
        jne loopDiv
    
loopPrint:
        dec di
        mov dl, [di]
        mov ah, 2
        int 21h
        cmp di, [bp+6]
        jne loopPrint
        
        pop bx
        pop di
        pop dx
        pop ax
        
        pop bp
        ret      
        
printDecimal endp  
    
    
end:
       
       .EXIT
        END 