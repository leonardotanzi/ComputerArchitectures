DIM_MAX      EQU 50
DIM_MIN      EQU 20  
DIM          EQU 50 
ALPHABET     EQU 27 ;26 + 1, one more to use in the counter 
DIFF_MA      EQU 65
DIFF_MI      EQU 97
K            EQU 3

       .MODEL small
       .STACK
       .DATA  

FIRST_ROW    DB  DIM DUP(?)
SECOND_ROW   DB  DIM DUP(?)
THIRD_ROW    DB  DIM DUP(?)
FOURTH_ROW   DB  DIM DUP(?)
 
FIRST_V      DB  ALPHABET DUP (?)  
SECOND_V     DB  ALPHABET DUP (?)
THIRD_V      DB  ALPHABET DUP (?)
FOURTH_V     DB  ALPHABET DUP (?) 
TOTAL        DB  ALPHABET DUP (?) 

LEN_FIRST     DW  ? 
LEN_SECOND    DW  ?
LEN_THIRD     DW  ?
LEN_FOURTH    DW  ?
MAX_FIRST     DB  ?
MAX_SECOND    DB  ?
MAX_THIRD     DB  ?
MAX_FOURTH    DB  ? 
MIDDLE_FIRST  DB  ?
MIDDLE_SECOND DB  ? 
MIDDLE_THIRD  DB  ? 
MIDDLE_FOURTH DB  ?
MAX_TOTAL     DB  ? 
IND_TOTAL     DW  ?            

       .CODE
       .STARTUP
        
           
           JMP begin  
           

new_line:
           PUSH DX
           MOV DX, 0
           MOV DL, 10
           INT 21h
           MOV DL, 13
           INT 21h
           POP DX        
           RET   
           
           
begin:          
           MOV CX,0
           MOV DI,0
           MOV AH,1 
           


first:     
           INT 21H     
           MOV FIRST_ROW[DI],AL
           INC DI
           INC CX
           CMP CX,DIM_MIN
           JL  first       ;se e' minore di 20 continua finche non >20
           CMP AL, 0xDh    ;qua e' maggiore di 20, se e' \n si ferma
           JE  end_first
           CMP CX, DIM_MAX ;se e' uguale a 50 si ferma
           JE  end_first
           JMP first
           
end_first:

           MOV LEN_FIRST, CX
           MOV CX, 0
           MOV DI, 0  
           
second:     
           INT 21H     
           MOV SECOND_ROW[DI],AL
           INC DI
           INC CX
           CMP CX,DIM_MIN
           JL  second 
           CMP AL, 0xDh
           JE  end_second
           CMP CX, DIM_MAX
           JE  end_second
           JMP second
           
end_second:

           MOV LEN_SECOND, CX
           MOV CX, 0
           MOV DI, 0  
           
third:     
           INT 21H     
           MOV THIRD_ROW[DI],AL
           INC DI
           INC CX
           CMP CX,DIM_MIN
           JL  third 
           CMP AL, 0xDh
           JE  end_third
           CMP CX, DIM_MAX
           JE  end_third
           JMP third
           
end_third:

           MOV LEN_THIRD, CX
           MOV CX, 0
           MOV DI, 0  


fourth:     
           INT 21H     
           MOV FOURTH_ROW[DI],AL
           INC DI
           INC CX
           CMP CX,DIM_MIN
           JL  fourth 
           CMP AL, 0xDh
           JE  end_fourth
           CMP CX, DIM_MAX
           JE  end_fourth
           JMP fourth
           
end_fourth:

           MOV LEN_FOURTH, CX
           
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
           MOV CX, 0
           MOV DI, 0
             
find_char_loop1:      
           MOV AL, FIRST_ROW[DI] 
           CMP AL, 90           ;ASCII per 'A'
           JLE maiusc1          ;se e' <= 90 maiuscolo
           CMP AL, 97           ;ASCII per 'a'
           JGE  minusc1         ;se e' >= 97 minuscolo
                    
return_find1:                    
           MOV AH, 0  
           PUSH DI
           MOV DI, AX
           MOV BL, FIRST_V[DI]
           INC BL
           MOV FIRST_V[DI], BL
           POP DI
           
continue_find1:  
           INC DI
           INC CX
           CMP CX, LEN_FIRST
           JNE find_char_loop1  
           JMP end_find1    
           
maiusc1:
           CMP AL, 65           ;altro controllo per assicurarsi che sia una lettera
           JL  continue_find1
           SUB AL, DIFF_MA      ;se la e' sottraggo per portare il valore
           JMP return_find1     ;da 0 a 27 in ordine alfabetico sia maiusc
                                ;che minuscolo
minusc1: 
           CMP AL, 122          ;altro controllo per assicurarsi che sia una lettera
           JG  continue_find1
           SUB AL, DIFF_MI
           JMP return_find1

end_find1: 

           MOV CX, 0
           MOV DI, 0
             
find_char_loop2:      
           MOV AL, SECOND_ROW[DI] 
           CMP AL, 90 ;number for 'A'
           JLE maiusc2
           CMP AL, 97 ;number for 'a'
           JGE  minusc2  
                    
return_find2:                    
           MOV AH, 0  
           PUSH DI
           MOV DI, AX
           MOV BL, SECOND_V[DI]
           INC BL
           MOV SECOND_V[DI], BL
           POP DI
           
continue_find2:  
           INC DI
           INC CX
           CMP CX, LEN_SECOND
           JNE find_char_loop2  
           JMP end_find2  
           
maiusc2:
           CMP AL, 65
           JL  continue_find2
           SUB AL, DIFF_MA
           JMP return_find2

minusc2: 
           CMP AL, 122
           JG  continue_find2
           SUB AL, DIFF_MI
           JMP return_find2

end_find2: 

           MOV CX, 0
           MOV DI, 0
             
find_char_loop3:      
           MOV AL, THIRD_ROW[DI] 
           CMP AL, 90 ;number for 'A'
           JLE maiusc3
           CMP AL, 97 ;number for 'a'
           JGE  minusc3  
                    
return_find3:                    
           MOV AH, 0  
           PUSH DI
           MOV DI, AX
           MOV BL, THIRD_V[DI]
           INC BL
           MOV THIRD_V[DI], BL
           POP DI
           
continue_find3:  
           INC DI
           INC CX
           CMP CX, LEN_THIRD
           JNE find_char_loop3  
           JMP end_find3  
           
maiusc3:
           CMP AL, 65
           JL  continue_find3
           SUB AL, DIFF_MA
           JMP return_find3

minusc3: 
           CMP AL, 122
           JG  continue_find3
           SUB AL, DIFF_MI
           JMP return_find3

end_find3:

           MOV CX, 0
           MOV DI, 0
             
find_char_loop4:      
           MOV AL, FOURTH_ROW[DI] 
           CMP AL, 90 ;number for 'A'
           JLE maiusc4
           CMP AL, 97 ;number for 'a'
           JGE  minusc4  
                    
return_find4:                    
           MOV AH, 0  
           PUSH DI
           MOV DI, AX
           MOV BL, FOURTH_V[DI]
           INC BL
           MOV FOURTH_V[DI], BL
           POP DI
           
continue_find4:  
           INC DI
           INC CX
           CMP CX, LEN_FOURTH
           JNE find_char_loop4  
           JMP end_find4  
           
maiusc4:
           CMP AL, 65
           JL  continue_find4
           SUB AL, DIFF_MA
           JMP return_find4

minusc4: 
           CMP AL, 122
           JG  continue_find4
           SUB AL, DIFF_MI
           JMP return_find4

end_find4: 
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

           MOV CX,0
           MOV DI, 0
      
           MOV AL, FIRST_V[DI]
           MOV MAX_FIRST, AL  
           
loop_find_max1:  
           MOV AL, FIRST_V[DI]
           INC DI    
           CMP DI, ALPHABET
           JE  end_max1    
           CMP AL, MAX_FIRST
           JG  max1          
           JL  loop_find_max1
                 

max1:       
           MOV MAX_FIRST, AL
           JMP loop_find_max1        
           
end_max1:   
           MOV AL, MAX_FIRST      ;trovo il max e lo divido per due
           SHR AL, 1 
           MOV MIDDLE_FIRST, AL 
           
           MOV CX, 0
           MOV SI, 0 
           MOV AH, 2
            
            
loop_find_corrispondence1:         ;cerco i i numeri corrispondendi a MIDDLE_FIRST
           
           MOV BL, FIRST_V[SI]
           INC SI
           CMP SI, ALPHABET
           JE end_find_corrispondence1
           CMP BL, MIDDLE_FIRST
           JE  print1              ;se li sono stampo a console
           JMP loop_find_corrispondence1

print1:     
           CALL new_line
           
           PUSH SI                 ;salvo SI e lo decremento (se no potrei add DIFF_MI-1)
           DEC SI 
           ADD SI, DIFF_MI         ;aggiungo la diff in modo da passare da 
           MOV DX, SI              ;ASCII-97 0 ASCII-64 A ASCII corsivo per stampare
           POP SI                  ;poi store in DX che viene stampato     
           INT 21H 
           JMP loop_find_corrispondence1      
           
end_find_corrispondence1:

          
           MOV CX,0
           MOV DI, 0
           
           MOV AL, SECOND_V[DI]
           MOV MAX_SECOND, AL  
           
loop_find_max2:  
           MOV AL, SECOND_V[DI]
           INC DI    
           CMP DI, ALPHABET
           JE  end_max2    
           CMP AL, MAX_SECOND
           JG  max2          
           JL  loop_find_max2
                 

max2:       
           MOV MAX_SECOND, AL
           JMP loop_find_max2        
           
end_max2:   
           MOV AL, MAX_SECOND      ;trovo il max e lo divido per due
           SHR AL, 1 
           MOV MIDDLE_SECOND, AL 
           
           MOV CX, 0
           MOV SI, 0 
           MOV AH, 2
            
            
loop_find_corrispondence2:         ;cerco i i numeri corrispondendi a MIDDLE_FIRST
           
           MOV BL, SECOND_V[SI]
           INC SI
           CMP SI, ALPHABET
           JE end_find_corrispondence2
           CMP BL, MIDDLE_SECOND
           JE  print2              ;se li sono stampo a console
           JMP loop_find_corrispondence2

print2:    
           CALL new_line
            
           PUSH SI                 ;salvo SI e lo decremento (se no potrei add DIFF_MI-1)
           DEC SI 
           ADD SI, DIFF_MI         ;aggiungo la diff in modo da passare da 
           MOV DX, SI              ;ASCII-97 0 ASCII-64 A ASCII corsivo per stampare
           POP SI                  ;poi store in DX che viene stampato
                
           INT 21H 
           JMP loop_find_corrispondence2      
           
end_find_corrispondence2:
                          
                          
           MOV CX,0
           MOV DI, 0
           
           MOV AL, THIRD_V[DI]
           MOV MAX_THIRD, AL  
           
loop_find_max3:
  
           MOV AL, THIRD_V[DI]
           INC DI    
           CMP DI, ALPHABET
           JE  end_max3    
           CMP AL, MAX_THIRD
           JG  max3          
           JL  loop_find_max3
                 

max3:       
           MOV MAX_THIRD, AL
           JMP loop_find_max3        
           
end_max3:   
           MOV AL, MAX_THIRD      ;trovo il max e lo divido per due
           SHR AL, 1 
           MOV MIDDLE_THIRD, AL 
           
           MOV CX, 0
           MOV SI, 0 
           MOV AH, 2
            
            
loop_find_corrispondence3:         ;cerco i i numeri corrispondendi a MIDDLE_FIRST
           
           MOV BL, THIRD_V[SI]
           INC SI
           CMP SI, ALPHABET
           JE end_find_corrispondence3
           CMP BL, MIDDLE_THIRD
           JE  print3              ;se li sono stampo a console
           JMP loop_find_corrispondence3

print3:     
           CALL new_line
           
           PUSH SI                 ;salvo SI e lo decremento (se no potrei add DIFF_MI-1)
           DEC SI 
           ADD SI, DIFF_MI         ;aggiungo la diff in modo da passare da 
           MOV DX, SI              ;ASCII-97 0 ASCII-64 A ASCII corsivo per stampare
           POP SI                  ;poi store in DX che viene stampato
                
           INT 21H 
           JMP loop_find_corrispondence3      
           
end_find_corrispondence3: 

 
           MOV CX,0
           MOV DI, 0
           
           MOV AL, FOURTH_V[DI]
           MOV MAX_FOURTH, AL  
           
loop_find_max4:
  
           MOV AL, FOURTH_V[DI]
           INC DI    
           CMP DI, ALPHABET
           JE  end_max4    
           CMP AL, MAX_FOURTH
           JG  max4
           JL  loop_find_max4
                 

max4:       
           MOV MAX_FOURTH, AL
           JMP loop_find_max4        
           
end_max4:   
           MOV AL, MAX_FOURTH      ;trovo il max e lo divido per due
           SHR AL, 1 
           MOV MIDDLE_FOURTH, AL 
           
           MOV CX, 0
           MOV SI, 0 
           MOV AH, 2
            
            
loop_find_corrispondence4:         ;cerco i i numeri corrispondendi a MIDDLE_FIRST
           
           MOV BL, FOURTH_V[SI]
           INC SI
           CMP SI, ALPHABET
           JE end_find_corrispondence4
           CMP BL, MIDDLE_FOURTH
           JE  print4              ;se li sono stampo a console
           JMP loop_find_corrispondence4

print4:     
           CALL new_line
           
           PUSH SI                 ;salvo SI e lo decremento (se no potrei add DIFF_MI-1)
           DEC SI 
           ADD SI, DIFF_MI         ;aggiungo la diff in modo da passare da 
           MOV DX, SI              ;ASCII-97 0 ASCII-64 A ASCII corsivo per stampare
           POP SI                  ;poi store in DX che viene stampato
                
           INT 21H 
           JMP loop_find_corrispondence4      
           
end_find_corrispondence4:
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
           MOV DI, 0 
           MOV CX, 0
           
loop_sum_all:  

           MOV AL, FIRST_V[DI]         ;sommo tutte le i'esime posizioni
           MOV AH, SECOND_V[DI]
           MOV BL, THIRD_V[DI]
           MOV BH, FOURTH_V[DI]
           ADD AL, AH
           ADD AL, BL
           ADD AL, BH
           MOV TOTAL[DI], AL           ;sposto in un nuovo vettore
           INC DI
           CMP DI, ALPHABET
           JE end_sum_all
           JMP loop_sum_all
           

end_sum_all: 

           MOV DI, 0
           MOV CX, 0
           MOV AL, TOTAL[DI]  
           MOV MAX_TOTAL, AL
           MOV IND_TOTAL, DI                        

           
loop_find_totalmax:                      ;trovo il massimo nel vettore
      
           INC DI
           CMP DI, ALPHABET
           JE end_totalmax
           MOV AL, TOTAL[DI]
           CMP AL, MAX_TOTAL
           JG totalmax
           JMP loop_find_totalmax:
           
                                         ;salvo il max(non serve) e l'indice(serve)
totalmax:
           MOV MAX_TOTAL, AL
           MOV IND_TOTAL, DI
           JMP loop_find_totalmax
           

end_totalmax: 

           MOV AH, 2                      ;aggiungo la diff per rappresentarloc ome char
           MOV BX, IND_TOTAL
           ADD BX, DIFF_MI
           CALL new_line
           MOV DX, BX 
           INT 21H         
              
;;;;;;;;;;;;;;;;;;;;;;;;;;;funziona solo per maiuscole e prima riga;;;;;;;;;;;;;;;;;;              
           
           MOV CX, 0
           MOV DI, 0
           
           
loop_cypher:

           MOV AL, FIRST_ROW[DI]           ;se e' maggiore di 'a' salto
           CMP AL, DIFF_MI
           JGE  greater_cypher 
 
           
return_cypher: 

           INC DI
           CMP DI, LEN_FIRST
           JE end_cypher
           JMP loop_cypher          
           
greater_cypher: 
  
           CMP AL, 122 - K           ;se e' maggiore di 'z' - k salto
           JG   last_chars           ;serve per trasformare la z in c
            
            
back_cypher:  
                                     ;aggiungo k per cifrarlo
           ADD AL, K 
           MOV FIRST_ROW[DI], AL
           JMP return_cypher  
             
             
last_chars:                           ;se e' minore di 'z' ed e' maggiore di 'z' - k
                                      ;e' una fra x,y,z... quindi salto
           CMP AL, 122
           JLE back_cypher_lastchars
                  
                  
back_cypher_lastchars:  

           INC AL                      ;aumento di 1 perche' ho definito ALPHABET
           SUB AL, ALPHABET            ;come 27 e non come 26
           JMP back_cypher             ;poi sottraggo l'alfabeto per tornare all'inizio
           
end_cypher:       
                       
        .EXIT
        END   
       