DIM_SOURCE    EQU 10
DIM_DEST      EQU 9  

       .MODEL small
       .STACK
       .DATA  
       
VETT_SOURCE   DB  1, 2, 3, 4 5, 6, 7, 8, 9, 10
VETT_DEST     DB  DIM_DEST DUP(?) 
MATRIX        DW  (DIM_DEST * DIM_DEST) DUP(?) 	;dw because 8b * 8b = 16b
RESULT        DW  ? 
MIN_S         DB  ?
MIN_D         DB  ?  
DIM_M         DW  ?
MAX           DW  ?
                 

       .CODE
       .STARTUP
       
	   ;1ST PART

        MOV CX,DIM_SOURCE
        MOV DI,0  
        
lab1:  
         
        MOV BL, VETT_SOURCE[DI],
        MOV BH, VETT_SOURCE[DI + 1]
        ADD BL, BH
        MOV VETT_DEST[DI], BL
        INC DI
        DEC CX
        CMP CX,0
        JNZ lab1  
        
        
        ;2ND PART
        
        MOV DI, 0
        MOV BL, VETT_SOURCE[DI]       
        
lab2:        
        INC DI
        CMP DI, DIM_SOURCE
        JE  out2
        MOV BH, VETT_SOURCE[DI]
        CMP BL, BH
        JG  min2 
        JL  lab2      
        
min2:    
        MOV BL, BH
        JMP lab2       
        
out2:   
        MOV MIN_S, BL
        
        MOV DI, 0
        MOV BL, VETT_DEST[DI]
               
lab3:        
        INC DI
        CMP DI, DIM_DEST
        JE  out3
        MOV BH, VETT_DEST[DI]
        CMP BL, BH
        JG  min3 
        JL  lab3       
        
min3:    
        MOV BL, BH
        JMP lab3   

out3:    
        MOV MIN_D, BL 
       
        
        ;3RD PART
        
        MOV DI, 0               ;DI are the rows
        
loop1:  
        
        MOV BX, 0               ;BX are the colums
loop2:
        PUSH BX
        MOV AL, VETT_SOURCE[DI] ;value of first array
        MOV BL, VETT_DEST[BX]   ;value of second array
        MUL BL                  ;ax = bl * al
        MOV RESULT, AX          ;multiplication result stored in RESULT
        POP BX
        
                                ;M[DI,SI] = M[2 *(DI * DIM_DEST + BX)] 
                                ;2 is because we are accessing 16bits and not 8
        XOR AX, AX              ;set AX to 0
        MOV AX, DI
        PUSH BX
        MOV BX, DIM_DEST
        MUL BX                  ;DX-AX = AX * BX = DI * DIM_DEST
        POP BX                  ;RESTORE BX TO COUNTER VALUE AFTER MUL 
        ADD AX, BX              ;AX = AX + BX = (DI * DIM_DEST) + BX
        SHL AX, 1               ;MULT * 2
        
        MOV SI, AX 
        PUSH BX
        MOV BX, RESULT
        MOV MATRIX[SI], BX      ;SET THE VALUE INTO THE MATRIX
        POP BX
                     
        INC BX
        CMP BX, DIM_DEST
        JL loop2  
        INC DI
        CMP DI, DIM_DEST
        JL loop1
         
        ;4TH PART
        
        MOV DI, 0
        MOV BX, MATRIX[DI] 
        MOV MAX, BX
         
        MOV AX, DIM_DEST   ;compute the index till we have to increase DI,
        PUSH BX            ;ax * ax * 2  = dim_dest * dim_dest * 2
        MOV  BX,AX
        MUL  BX
        SHL  AX, 1
        MOV  DIM_M, AX 
        POP  BX
        
        
lab4:        
        INC DI      ;inc two times cause we are working with 16 bits
        INC DI 
          
        CMP DI,DIM_M
        JE  end
        MOV CX, MATRIX[DI]
        CMP MAX, CX
        JL  max4
        JG  lab4 
        
        
max4:    
        MOV MAX, CX
        JMP lab4
         
end:                 
        .EXIT
        END   
       

       
