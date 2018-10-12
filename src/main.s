             AREA    |.text|, CODE, READONLY, ALIGN=2
             EXPORT  Start
		   
par0	DCD		0x2AAAAA
par1	DCD		0xCCCCC
par2	DCD		0x30F0F0
par3	DCD		0xFF00
par4	DCD		0x3F0000
parA    DCD		0x3FFFFF;
base	DCD		0x231B3A
	
Start
		ADR		r0, base;
		LDR		r9, [r0];
		;MOV		r9, #&231B3A
		BL		test_count_ones
		
		B		.
		
extract_recieved_code
		; word in r9
		; received code in r12
		MOV 	r12, #0 		; reset rec_parity_word
		MOV 	r6, #1
		MOV 	r0, r9          ; r0 = working space
		MOV 	r7, #3
		AND 	r1, r0, r7, LSL #1
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
		BL	 	count_ones		; puts count in r0
		EOR 	r1, r0, #1     ; Zero flag will be set if count is even
		MOV  	r11, r1
		
calculate_par_1
		ADR  	r0, par1
		LDR  	r0, [r0]
		AND  	r0, r0, r9
		BL	 	count_ones		; puts count in r0
		AND 	r1, r0, #1     ; Zero flag will be set if count is even
		ADD  	r11, r11, r1, LSL #1

calculate_par_2
		ADR  	r0, par2
		LDR  	r0, [r0]
		AND  	r0, r0, r9
		BL	 	count_ones		; puts count in r0
		AND 	r1, r0, #1     ; Zero flag will be set if count is even
		ADD  	r11, r11, r1, LSL #2
		
calculate_par_3
		ADR  	r0, par3
		LDR  	r0, [r0]
		AND  	r0, r0, r9
		BL	 	count_ones		; puts count in r0
		AND	 	r1, r0, #1     ; Zero flag will be set if count is even
		ADD  	r11, r11, r1, LSL #3
		
calculate_par_4
		ADR  	r0, par4
		LDR  	r0, [r0]
		AND  	r0, r0, r9
		BL	 	count_ones		; puts count in r0
		AND 	r1, r0, #1     ; Zero flag will be set if count is even
		LSL		r1, #1
		ADD  	r11, r11, r1, LSL #3
		
calc_correcting_code
		CMP 	r12, r11
		BLEQ	count_ones
		ANDEQS	r0, r0, #1
		BNE		.
		MOV		r1, #1
		LSL		r1, r0
		EOR		r9, r1
		
correct_code
		

		
		
		

;parity_all_check
;		ADR		r1, par1
;		LDR		r1, [r1]	; load p_all mask
;		AND		r0, r1, r9  ; extract bits
;		BL		count_ones
;		RRX		r2, r2, #1		; set carry. 0 = even, 1 = odd 
		  

; Assume that r0 has the word loaded. Places count in r0 when done (RESETS)
; WARNING: Code overwrites r0
; r0 = word
; r1 = word!
; r2 = count
count_ones
		TST		r0, #&0
		MOVEQ	r0, r2
		BXEQ	lr; base case
		
		SUB		r1, r0, #1
		AND		r0, r0, r1
		ADD     r2, r2, #1  ; increment count	
		B		count_ones
		
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
           