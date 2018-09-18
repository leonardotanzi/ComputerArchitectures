N      EQU    15

       .MODEL small
       .STACK
       .DATA  
       
IMAGE            DB     1, 1, 1, 2, 3, 1, 3, 3, 3, 3, 4, 4, 5, 7, 7
COMPRESSED       DB     2*N DUP(?) 
                 

       .CODE
       .STARTUP
       
        MOV CX, 0
        MOV SI, 0
        MOV DI, 0
       

for_out:
        
        
        CMP CX, N
        JE end 
        INC CX
        MOV BL, 0
        MOV BH, IMAGE[SI]
        ;CMP SI, N - 1
        ;JE diff
        INC SI
        MOV AX, CX
        
for_inner:

        CMP AX, N + 1
        JE for_out
        MOV DH, IMAGE[SI]
        INC AX
        
        CMP BH, DH 
        
        JNE diff
        
        
        INC SI 
        INC BL
        
        JMP for_inner
        
diff:

        MOV CX, AX
        DEC CX  
        MOV COMPRESSED[DI], BL
        MOV COMPRESSED[DI + 1], BH
        INC DI
        INC DI
        JMP for_out        
        
              
              
end:       
       .EXIT
       END