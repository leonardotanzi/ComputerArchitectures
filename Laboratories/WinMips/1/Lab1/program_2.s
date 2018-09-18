		.data
v1: .double 4, 5, 2, 10, 3, 21, 12, 7, 40, 18 
v2: .double 4, 5, 2, 10, 3, 21, 12, 7, 40, 18
v3: .double 4, 5, 2, 10, 3, 21, 12, 7, 40, 18
v4: .double 4, 5, 2, 10, 3, 21, 12, 7, 40, 18
v5: .double 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
v6: .double 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
v7: .double 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0								

		.text
MAIN:
daddui	R1, R0, 10
dadd 	R2, R0, R0
	
	
LOOP:
l.d		F1, v1(R2)
l.d		F2, v2(R2)
l.d		F3, v3(R2)
l.d		F4, v4(R2)
mul.d	F5, F1, F2
s.d		F5, v5(R2)
div.d	F6, F2, F3
s.d		F6, v6(R2)
add.d	F7, F1, F4
s.d		F7, v7(R2)

daddi	R2, R2, 8
daddi	R1, R1, -1
bnez 	R1, LOOP

halt
