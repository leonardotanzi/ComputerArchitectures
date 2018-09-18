
       .MODEL small
       .STACK
       .DATA  

CITATIONS           DW  51 DUP(?)
NMAX_CITATIONS      DB  50 DUP(?)
H_INDEX             DB  63 DUP(?)

H_IND               DB  ? 
COUNT               DB  ?
        
         .CODE
       .STARTUP
        
        MOV CITATIONS[0],  5
        MOV CITATIONS[2],  0001000011000010B
        MOV CITATIONS[4],  0010000001000010B
        MOV CITATIONS[6],  0011000111000100B
        MOV CITATIONS[8],  0100000001000011B
        MOV CITATIONS[10], 0101000011000011B
        
        
        XOR DI, DI
        XOR SI, SI
        MOV CX, CITATIONS[0]

cycle1:
        INC DI
        INC DI
        XOR AX, AX
        XOR BX, BX
        
        MOV AX, CITATIONS[DI]
        MOV BX, AX
        AND AX, 0000111111000000B
        SHR AX, 6
        AND BX, 0000000000111111B
        CMP AX, BX
        JG  greaterWOS
        MOV NMAX_CITATIONS[SI], BL
        JMP greaterSCO 
        
greaterWOS:
        MOV NMAX_CITATIONS[SI], AL                       

greaterSCO: 
        INC SI
        LOOP cycle1
         
         
         
        
        XOR CX, CX
        MOV CX, CITATIONS[0]
        XOR DI, DI
        
cycle2:
        XOR AX, AX 
        XOR SI, SI
        MOV AL, NMAX_CITATIONS[DI]
        MOV SI, AX 
        INC H_INDEX[SI - 1]
        INC DI
        LOOP cycle2
        
        
        XOR CX, CX
        XOR DI, DI
        MOV DI, 10
        MOV CX, 11
        MOV COUNT, 0
        
cycle4:
        XOR AX, AX 
        MOV AL, H_INDEX[DI]
        CMP AL, 0
        JE  nope 
        MOV BL, COUNT
        ADD H_INDEX[DI], BL
        ADD COUNT, AL
        
nope:
        DEC DI
        LOOP cycle4        
        
        
        
        
        MOV CX, 63
        MOV DI, 62
        
cycle3: 
        XOR AX, AX
        MOV AL, H_INDEX[DI]
        CMP AL, 0
        JE  end
        INC DI
        CMP AX, DI
        JGE index
        DEC DI
end:        
        DEC DI
        LOOP cycle3
        
index:
        XOR AX, AX
        MOV AX, DI
        MOV H_IND, AL
          

                     
       
       .EXIT
        END 