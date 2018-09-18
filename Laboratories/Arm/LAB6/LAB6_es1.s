; Standard definitions of Mode bits and Interrupt (I & F) flags in PSRs

Mode_USR        EQU     0x10
Mode_FIQ        EQU     0x11
Mode_IRQ        EQU     0x12
Mode_SVC        EQU     0x13
Mode_ABT        EQU     0x17
Mode_UND        EQU     0x1B
Mode_SYS        EQU     0x1F

I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled


;// <h> Stack Configuration (Stack Sizes in Bytes)
;//   <o0> Undefined Mode      <0x0-0xFFFFFFFF:8>
;//   <o1> Supervisor Mode     <0x0-0xFFFFFFFF:8>
;//   <o2> Abort Mode          <0x0-0xFFFFFFFF:8>
;//   <o3> Fast Interrupt Mode <0x0-0xFFFFFFFF:8>
;//   <o4> Interrupt Mode      <0x0-0xFFFFFFFF:8>
;//   <o5> User/System Mode    <0x0-0xFFFFFFFF:8>
;// </h>

UND_Stack_Size  EQU     0x00000080
SVC_Stack_Size  EQU     0x00000080
ABT_Stack_Size  EQU     0x00000000
FIQ_Stack_Size  EQU     0x00000000
IRQ_Stack_Size  EQU     0x00000080
USR_Stack_Size  EQU     0x00000400

ISR_Stack_Size  EQU     (UND_Stack_Size + SVC_Stack_Size + ABT_Stack_Size + \
                         FIQ_Stack_Size + IRQ_Stack_Size)

                AREA    STACK, NOINIT, READWRITE, ALIGN=3

Stack_Mem       SPACE   USR_Stack_Size
__initial_sp    SPACE   ISR_Stack_Size

Stack_Top


;// <h> Heap Configuration
;//   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF>
;// </h>

Heap_Size       EQU     0x00000280 	;cause we have a vector of 5 elements, each element is 32 bits so it's 
									;32bits * 5elements = 160bits -> 0x280

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3

Heap_Mem        SPACE   Heap_Size




                PRESERVE8
                

; Area Definition and Entry Point
; Startup Code must be linked first at Address at which it expects to run.

                AREA    RESET, CODE, READONLY
                ARM


; Exception Vectors
;  Mapped to Address 0.
;  Absolute addressing mode must be used.
;  Dummy Handlers are implemented as infinite loops which can be modified.

Vectors         LDR     PC, Reset_Addr			; reset (called when you power up the pc, is at the beginning cause it's the first to be execute,
												; then we jump and we don't execute the next but we go to label reset_handler)
                LDR     PC, Undef_Addr			; undefined instruction USE FOR SECOND EXERCISE
                LDR     PC, SWI_Addr			; software interrupt
                LDR     PC, PAbt_Addr			; prefetch abort
                LDR     PC, DAbt_Addr			; data abort
                NOP                             ; reserved vector 
                LDR     PC, IRQ_Addr			; IRQ
                LDR     PC, FIQ_Addr			; FIQ

Reset_Addr      DCD     Reset_Handler
Undef_Addr      DCD     Undef_Handler
SWI_Addr        DCD     SWI_Handler
PAbt_Addr       DCD     PAbt_Handler
DAbt_Addr       DCD     DAbt_Handler
                DCD     0                      ; Reserved Address 
IRQ_Addr        DCD     IRQ_Handler
FIQ_Addr        DCD     FIQ_Handler

Pool1 			DCD 	0x10, 0x70000000, 0xFFFFFFE0, 0x800000F0, 0x100EC023 		;the two literal pool of 5 elements
Pool2 			DCD 	0x200, 0x12345678, 0xE00A1238, 0xF0004538, 0xE9800348


Undef_Handler   B       Undef_Handler 			;JUMP ON ITSELF, dummy handlers
PAbt_Handler    B       PAbt_Handler
DAbt_Handler    B       DAbt_Handler
IRQ_Handler     B       IRQ_Handler
FIQ_Handler     B       FIQ_Handler

;SWI management
SWI_Handler	

;we need to check the identification code of the interrupt, the only way is to save in the stack pointer the link register lr,  
;which is the immediately next instruction of SWI, so i subtract 4 bytes and i'm back to the address of the instruction 
;SWI #0x10, i take only the 0x10 with a mask that clear the first bits. we need to know that at the end of exception 
;we have the same situation with no change, so we save also the value of the registers from r0 to r5,
;cause we need r6 to store the new value

                STMFD 	SP!, {R0-R5, LR}
				LDR R0, [LR, #-4]
				BIC 	R1, R0, #0xff000000		;means r0 AND NOT 0xff000000, that is like ANDING
												;for 0000000011111111...till 32bits, so it saves only the last 24 values
				;test the identification code of the interrupt
				CMP 	R1, #0x10			   	
				LDREQ 	R6, =0x7FFFFFFF
				CMP		R1, #0x20
				LDREQ	R6, =0x80000000
			
				

				B 	end_swi


end_swi			LDMFD 	SP!, {R0-R5, PC}^		  ;reload the values of registers and the program counter


; Reset Handler
Reset_Handler   


; Initialise Interrupt System
;  ...
;when an exception arise we change mode, each mode has its own stack, so we need to allocate some spaces for stack

; Setup Stack for each mode

                LDR     R0, =Stack_Top

;  Enter Undefined Instruction Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit  ;change the value of cpsr, moving a special flag (build with constant) for changing mode,
                MOV     SP, R0                               ;now we change the stack pointer of this mode, R0 is initialized to stack_top,
                SUB     R0, R0, #UND_Stack_Size              ;our stack ha #undstacksize bytes, we are reserving, then do everything for every mode

;  Enter Abort Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_ABT:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #ABT_Stack_Size

;  Enter FIQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_FIQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #FIQ_Stack_Size

;  Enter IRQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #IRQ_Stack_Size

;  Enter Supervisor Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #SVC_Stack_Size

;  Enter User Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_USR
                MOV     SP, R0
                SUB     SL, SP, #USR_Stack_Size

              

; main program starts here.
; The interrupt service routine with identification code 10h is called

				LDR R0, =Pool1			;initialize R0
				LDR R1, =Pool2 			;initialize R1
				LDR R2, =Heap_Mem

loop

				CMP R3, #5
				BEQ end
				ADD R3, R3, #1		 ;INCREASE THE COUNTER FOR THE OUTER LOOP
		
				LDR R4, [R0], #4 	 ;number of the first pool AND INCREMENT OF 4 THE INDEX OF THE POOL1
				LDR R5, [R1], #4	 ;number of the second pool AND INCREMENT OF 4 THE INDEX OF THE POOL2
				ADD R6, R4, R5

				CMP R4, #0
				BGT Bigger
				BLT Smaller
				BEQ set_r6

Bigger
				;if r4 is bigger than 0
				CMP R5, #0
				;if r5 is bigger than 0
				BGT both_bigger
				BLE set_r6
				;if LE continue here

both_bigger
				CMP R6, #0
				;if r6 is lower than 0 SWI
				SWILT #0x10
				B set_r6
				
Smaller
				CMP R5, #0
				BLT both_smaller
				BGE set_r6

both_smaller
				CMP R6, #0
				SWIGT #0x20
				B set_r6
							
set_r6
				STR R6, [R2], #4	  ;load R6 into memory, no matter if it has been modified by the SWI handler
				B loop


end				
				B Reset_Handler


                END
		