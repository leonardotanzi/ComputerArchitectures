DAY_HOUR         EQU 24
WEEK_HOUR        EQU 168  

       .MODEL small
       .STACK
       .DATA  
       
RECORD      DB      00000000B, 01101111B, 00000001B, 10010010B
RATES       DB      1, 24, 168

DURATION_OF_RENTAL  DW ?
COST_TO_BE_CHARGED  DW ?
START_H             DW ?
END_H               DW ?
START_N             DW ?
END_N               DW ?
TOTAL_HOUR          DW ?
REM_HOUR            DB ?
N_WEEK              DB ?
N_DAY               DB ?
N_HOUR              DB ?  

INSERTmsg   DB  'Insert data of the rental: $'
STDmsg      DB  '  Starting Day = $'
STHmsg      DB  '  Starting Hour = $'
ENDmsg      DB  '  Ending Day = $'
ENHmsg      DB  '  Ending Hour = $'
NEWmsg      DB  '  Do you want evaluate a new rental [y/n]?$'
DURATIONmsg DB  'Duration: $'
Wmsg        DB  ' weeks, $'
Dmsg        DB  ' days, $'
Hmsg        DB  ' hours$'
COSTmsg     DB  'Cost = $'
                 

       .CODE
       .STARTUP
       
       CALL emptyRow
       MOV AH, 9
       MOV DX, OFFSET INSERTmsg
       INT 21H 
       
       CALL emptyRow
       MOV AH, 9
       MOV DX, OFFSET STDmsg
       INT 21H
       
       MOV AX, 3                  
       PUSH AX
       CALL readDecimal
       POP ax
       MOV CL, 5
       SHL AX, CL
       MOV RECORD[0], AH
       MOV RECORD[1], AL 
       
       call emptyRow       ;read starting hour
        mov ah, 9
        mov dx, offset STHmsg
        int 21h
        
        mov ax, 2                  
        push ax
        call readDecimal
        pop ax
        or RECORD[1], al
        
        call emptyRow       ;read ending day
        mov ah, 9
        mov dx, offset ENDmsg
        int 21h
        
        mov ax, 3                  
        push ax
        call readDecimal
        pop ax
        mov cl, 5
        shl ax, cl
        mov RECORD[2], ah
        mov RECORD[3], al
        
        call emptyRow       ;read ending hour
        mov ah, 9
        mov dx, offset ENHmsg
        int 21h
        
        mov ax, 2                  
        push ax
        call readDecimal
        pop ax
        or RECORD[3], al 
        
       
       MOV AH, RECORD[0]
       MOV AL, RECORD[1]
       
       MOV START_N, AX
       AND AX, 0011111111100000B
       SHR AX, 5
       MOV CX, 24
       MUL CX
       
       MOV START_H, AX
       
       MOV AX, START_N 
       AND AX, 0000000000011111B
       
       ;ADD AX, START_H
       ;MOV START_H, AX 
       ADD START_H, AX
       
       MOV AH, RECORD[2]
       MOV AL, RECORD[3]
       
       MOV END_N, AX
       AND AX, 0011111111100000B
       SHR AX, 5
       MOV CX, 24
       MUL CX
        
       MOV END_H, AX
       
       MOV AX, END_N 
       AND AX, 0000000000011111B
       
       ;ADD AX, END_H
       ;MOV END_H, AX
       ADD END_H, AX
       
       MOV REM_HOUR, 0
       MOV BX, START_H
       MOV AX, END_H
       SUB AX, BX
       MOV TOTAL_HOUR, AX
       
       CMP AX, WEEK_HOUR
       JGE weeks
       
return1:
       
       CMP AX, DAY_HOUR
       JGE days
       
       
return2:
       
       MOV BX, DURATION_OF_RENTAL  
       MOV N_HOUR, AL
       ADD BX, AX
       MOV DURATION_OF_RENTAL, BX
       MOV AL, RATES[0]
       MUL TOTAL_HOUR
       MOV COST_TO_BE_CHARGED, AX 
       
       CALL emptyRow
       MOV AH, 9
       MOV DX, OFFSET DURATIONmsg
       INT 21H 
       
       CALL emptyRow
       MOV AH, 9
       MOV DX, OFFSET Wmsg
       INT 21H 
       XOR AX, AX 
       MOV AL, N_WEEK 
       PUSH AX
       CALL printDecimal
       POP AX 
              
       
       CALL emptyRow
       MOV AH, 9
       MOV DX, OFFSET Dmsg
       INT 21H
       XOR AX, AX 
       MOV AL, N_DAY 
       PUSH AX
       CALL printDecimal
       POP AX
      
        
                       
       CALL emptyRow
       MOV AH, 9
       MOV DX, OFFSET Hmsg
       INT 21H 
       XOR AX, AX 
       MOV AL, N_HOUR  
       PUSH AX
       CALL printDecimal
       POP AX 
      
       
       
       
       JMP end
       

weeks:
        
       MOV BH, WEEK_HOUR
       DIV BH   
       MOV N_WEEK, AL
       MOV REM_HOUR, AH
       XOR AH, AH 
       MOV BX, AX
       SHL BX, 8
       MOV DURATION_OF_RENTAL, BX
       MOV AH, REM_HOUR
       XCHG AH, AL
       XOR AH, AH 
       
       JMP return1
       
days:

       MOV BH, DAY_HOUR
       DIV BH  
       MOV N_DAY, AL
       MOV REM_HOUR, AH 
       XCHG AH, AL
       XOR AH, AH
       MOV BX, AX
       SHL BX, 5 
       MOV CX, DURATION_OF_RENTAL
       ADD CX, BX
       MOV DURATION_OF_RENTAL, CX 
       
       JMP return2
       
     
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