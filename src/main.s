             AREA    |.text|, CODE, READONLY, ALIGN=2
             EXPORT  Start
		   
par0	DCD		0x2AAAAA
par1	DCD		0xCCCCC
par2	DCD		0x30F0F0
par3	DCD		0xFF00
par4	DCD		0x3F0000
	
parA    DCD		0x3FFFFE
	
test1	DCD		0x331B3D
result1	DCD		0x331B7D
test2	DCD		0x11CADB

	
Start
		ADR		r0, test1;
		LDR		r9, [r0];
		
extract_recieved_code
		; word in r9
		; received code in r12
		MOV 	r12, #0 		; reset rec_parity_word
		MOV 	r6, #1
		MOV 	r0, r9          ; r0 = working space
		MOV 	r7, #3
		AND 	r1, r0, #6
		MOV 	r12, r1, LSR #1  ; bits 0 & 1 in correct position
		AND 	r1, r0, r6, LSL #4 ; r1 contains par2
		ORR 	r12, r12, r1, LSR #2 ; par2 in correct position
		AND 	r1, r0, r6, LSL #8 ; r1 contains par3
		ORR 	r12, r12, r1, LSR #5
		AND 	r1, r0, r6, LSL #16
		ORR 	r12, r12, r1, LSR #12
		
calculate_par_0
		ADR  	r0, par0
		LDR  	r0, [r0]
		AND  	r0, r0, r9
		ROR		r0, r0, #1
		AND		r3, r0, #1
		BL	 	count_ones		; puts count in r0
		ANDS 	r1, r0, #1   ; Zero flag will be set if count is even
		ADDEQ	r11, r11, r3
		
calculate_par_1
		ADR  	r0, par1
		LDR  	r0, [r0]
		AND  	r0, r0, r9
		ROR		r0, r0, #2
		AND		r3, r0, #1
		BL	 	count_ones		; puts count in r0
		ANDS 	r1, r0, #1     ; Zero flag will be set if count is even
		ADDEQ  	r11, r11, r3, LSL #1

calculate_par_2
		ADR  	r0, par2
		LDR  	r0, [r0]
		AND  	r0, r0, r9
		ROR		r0, r0, #4
		AND		r3, r0, #1
		BL	 	count_ones		; puts count in r0
		ANDS 	r1, r0, #1     ; Zero flag will be set if count is even
		ADDEQ  	r11, r11, r3, LSL #2
		
calculate_par_3
		ADR  	r0, par3
		LDR  	r0, [r0]
		AND  	r0, r0, r9
		ROR		r0, r0, #8
		AND		r3, r0, #1
		BL	 	count_ones		; puts count in r0
		ANDS	r1, r0, #1
		;MOVEQ	r1, #1     ; Zero flag will be set if count is ODD
		ADDEQ  	r11, r11, r3, LSL #3
		
calculate_par_4
		ADR  	r0, par4
		LDR  	r0, [r0]
		AND  	r0, r0, r9
		ROR		r1, r9, #16
		AND		r3, r1, #1 
		BL	 	count_ones		; puts count in r0
		ANDS 	r2, r0, #1     ; Zero flag will be set if count is even
		; equal, do nothing.
		; NE = find parity bit & move it
		ADDEQ	r11, r11, r3, LSL #4

calc_correcting_code
		EORS	r0, r12, r11
		BEQ		pall
		MOV		r1, #1
		LSL		r1, r0
		EOR		r9, r9, r1
		B		stop
		
pall
		AND		r3, r9, #1
		ADR		r0, parA
		LDR		r0, [r0]
		AND		r0, r9, r0
		BL		count_ones
		; EQ -> odd, r3 should be 1
		; NE -> even, r3 should be 0
		AND		r0, r0, #1
		TST		r0, r3
		BNE		.				; two errors, cannot be corrected
		
stop
		ADR		r0, result1
		LDR		r0, [r0]
		CMP		r0, r9			; Should set zero flag if everything worked
		B		.

; Assume that r0 has the word loaded. Places count in r0 when done (RESETS)
; WARNING: Code overwrites r0
; r0 = word
; r1 = word!
; r2 = count
count_ones
		MOV		r2, #0
loop
		CMP 	r0, #&0
		MOVEQ	r0, r2
		BXEQ	lr; base case
		
		SUB		r1, r0, #1
		AND		r0, r0, r1
		ADD     r2, r2, #1  ; increment count	
		B		loop
		
test_count_ones
		MOV		r0, #0x24
		BL		count_ones
		CMP		r2, #2      ; should be equal
		MOV		r0, #0x20
		MOV		r2, #0
		BL		count_ones
		CMP		r2, #1
		BLX		lr
		
        ALIGN      
        END  
           