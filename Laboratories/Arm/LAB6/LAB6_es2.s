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

Heap_Size       EQU     0x00000100 	
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


PAbt_Handler    B       PAbt_Handler
DAbt_Handler    B       DAbt_Handler
IRQ_Handler     B       IRQ_Handler
FIQ_Handler     B       FIQ_Handler
SWI_Handler		B		SWI_Handler

;we need to check the identification code of the interrupt, the only way is save in the stack pointer the 
;link register lr, which is the immediately next instruction of DIVr6BY5 so i subtract 4 bytes and i'm back
;to the address 0x77F005F6. we need to know that at the end of exception we have the same situatuion with 
;no changeS, so we save also the value of the registers from r0 to r11, cause we need r12 to store the new value.

Undef_Handler
                STMFD 	SP!, {R0-R11, LR}
				LDR 	R0, [LR, #-4]
				BIC 	R1, R0, #0xFFFFFFF		;means r0 AND NOT 0xFFFFFFF0, that is like ANDING
												;for 0x0000000F that is 1111000000000...till 32bits, so it saves 
												;only the first 4 bit

				CMP 	R1, #0xE0000000			;if it's equal to E is the right condition 
				BNE 	end_undef  	
				
				BICEQ 	R1, R0, #0xF00FFFFF		
				CMP		R1, #0x07F00000			;if it's equal to 7f is the right opcode
				BNE end_undef
	
				BICEQ   R1, R0, #0xFFFFFF0F		;check the F in the register dividend
				CMP 	R1, #0x000000F0
				BNE 	end_undef

				BICEQ	R1, R0, #0xFFFF00FF
				LSREQ	R1, #8					;in order to change from 0x00000500 to 0x00000005 i need to shift 
												;8 bits to the right (10100000000 and 00000000101)

	
				BICEQ	R2, R0, #0xFFFFFFF0		;r2 contains the number of register that contain the dividend
				LDREQ	R3, [SP, R2, LSL #2]	;i load in R3 the value of the stack pointer (that contains all the
												;register's values, as we stored them with stmfd) at the x-th position,
												; where x is the number of the register dividend 
												;multiplied by 4 because every register is 4 bytes (LSL #2), so 6*4 = 24.	THEY'RE USING BYTES NOT BITS, IF
												;IT WAS BITS I SHOULD HAVE MUL AGAIN FOR 8 6*4*8

begin_cycle

				SUBS R3, R3, R1		  	;compute division
				CMP R3, #0
				ADDGE R7, R7, #1 		;if the number is for ex 27, the result is 5 not 6, cause inc the counter only if >=		  
				BLE out
				BGT begin_cycle
				
out
				MOV R12, R7				;store in r12 the result of the division
				B 	end_undef

				; your action here 

end_undef		LDMFD 	SP!, {R0-R11, PC}^		  ;reload the values of registers and the program counter


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


				MOV R6, #25
				;MOV R8, #40

DIVr6BY5 		DCD 	0xE7F005F6
;DIVr8BY5		DCD		0xE7F008F8
				B Reset_Handler


                END
		