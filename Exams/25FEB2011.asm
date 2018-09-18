N_ATL       EQU 4 
N_ELEMENT   EQU 12 

       .MODEL small
       .STACK
       .DATA  
       
TIMES       DB  N_ATL DUP (?, ?, ?)
STANDING    DB  N_ATL DUP (?, ?, ?)

WR      DW  ? 
TEMP    DW  ?
                 

       .CODE
       .STARTUP
       
        
        MOV AL, 1
        MOV TIMES[0], AL
        MOV AL, 00101101b
        MOV TIMES[1], AL 
        MOV AL, 00111100b 
        MOV TIMES[2], AL 
        
        MOV AL, 2
        MOV TIMES[3], AL
        MOV AL, 00110000b
        MOV TIMES[4], AL  
        MOV AL, 00111100b 
        MOV TIMES[5], AL      
        
        
        MOV AL, 3
        MOV TIMES[6], AL
        MOV AL, 00111101b
        MOV TIMES[7], AL 
        MOV AL, 00111100b 
        MOV TIMES[8], AL 
        
        MOV AL, 4
        MOV TIMES[9], AL
        MOV AL, 00110000b
        MOV TIMES[10], AL  
        MOV AL, 00111011b
        MOV TIMES[11], AL 
             
        
        ;MOV AL, 5
;        MOV TIMES[12], AL
;        MOV AL, 00100101b
;        MOV TIMES[13], AL 
;        MOV AL, 00111100b 
;        MOV TIMES[14], AL 
;        
;        MOV AL, 6
;        MOV TIMES[15], AL
;        MOV AL, 00110000b
;        MOV TIMES[16], AL  
;        MOV AL, 00110100b
;        MOV TIMES[17], AL      
;        
;        MOV AL, 7
;        MOV TIMES[18], AL
;        MOV AL, 00101101b
;        MOV TIMES[19], AL 
;        MOV AL, 00011100b 
;        MOV TIMES[20], AL 
;        
;        MOV AL, 8
;        MOV TIMES[21], AL
;        MOV AL, 00110000b
;        MOV TIMES[22], AL  
;        MOV AL, 00111001b
;        MOV TIMES[23], AL      
;                  

         
         MOV SI, 0
         MOV BX, 0

begin:         
         
         MOV AL, TIMES[SI]
         MOV STANDING[SI], AL
         INC SI
         
         INC BX
         CMP BX, N_ELEMENT
         JL begin

          
          
         MOV CH, 0
                

for:
         MOV CL, 0 
         MOV BX, 0  
         MOV SI, 0
           
         
while:         
         
         MOV TEMP, CX                
         MOV AL, STANDING[BX]
         INC BX
         MOV DH, STANDING[BX] 
         INC BX
         MOV DL, STANDING[BX] 
         INC BX
         MOV AH, STANDING[BX]
         INC BX
         MOV CH, STANDING[BX]
         INC BX
         MOV CL, STANDING[BX]
         SUB BX, 2
         
         PUSH DX
         PUSH CX
         
         AND DX, 0000000000000111b
         AND CX, 0000000000000111b
         CMP DX, CX
         JG  greater_first
         JL  greater_second
          
         POP CX
         POP DX
         
         PUSH DX
         PUSH CX
         
         AND DX, 0000000111111000b
         AND CX, 0000000111111000b
         CMP DX, CX
         JG   greater_first
         JL  greater_second
         
         POP CX
         POP DX
         
         PUSH DX
         PUSH CX
         
         AND DX, 1111111000000000b
         AND CX, 1111111000000000b
         CMP DX, CX
         JGE   greater_first
         JL    greater_second
         
greater_first: 

         POP CX
         POP DX
         
         
         MOV STANDING[SI], AH
         INC SI
         MOV STANDING[SI], CH
         INC SI
         MOV STANDING[SI], CL
         INC SI            
         MOV STANDING[SI], AL
         INC SI
         MOV STANDING[SI], DH
         INC SI
         MOV STANDING[SI], DL 
         SUB SI, 2           


         JMP end_c           
                
greater_second:  

         POP CX
         POP DX 
         ADD SI, 3
         
         ;MOV STANDING[SI], AL
;         INC SI
;         MOV STANDING[SI], DH
;         INC SI
;         MOV STANDING[SI], DL
;         INC SI            
;         MOV STANDING[SI], AH
;         INC SI
;         MOV STANDING[SI], CH
;         INC SI
;         MOV STANDING[SI], CL 
;         SUB SI, 3
         
end_c:                
         
         MOV CX, TEMP       
         INC CL
         CMP CL, N_ATL - 1
         JE end_while
         JL while      

end_while:                
                
         INC CH
         CMP CH, N_ATL - 1 
         JE end
         JL for
       
       
       
end:       	
       	.EXIT
        
        END 
       