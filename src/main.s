		AREA    |.text|, CODE, READONLY, ALIGN=2
		EXPORT  Start
		IMPORT 	exp
		   
masks	DCD		0x2AAAAA, 0xCCCCC, 0x30F0F0, 0xFF00, 0x3F0000
	
parA    DCD		0x3FFFFF
	
test1	DCD		0x331B3D
asnw1	DCD		0x331B7D

; {r0 - r2} -> general purpose
;
; r8  -> word to parse
; r9  -> working address of the mask array
; r10 -> index of working parity bit in calculated parity word
; r11 -> calculated parity word
; r12 -> received Parity word

Start
		ADR		r0, test1;
		LDR		r8, [r0];
		ADR		r9, masks
		BL		extract_recieved_code
		MOV		r10, #0
		B		generic_parity
	
calc_correcting_code
		EORS	r0, r12, r11
		BEQ		stop
		
correct_word
		MOV		r1, #1
		LSL		r1, r0
		EOR		r8, r8, r1
		
stop
		PUSH {r8}
		B		.


extract_recieved_code
		; word in r8
		; received code in r12
		MOV 	r12, #0 		     ; reset rec_parity_word
		MOV 	r6, #1
		MOV 	r0, r8               ; r0 = working space
		AND 	r1, r0, #6
		MOV 	r12, r1, LSR #1      ; bits 0 & 1 in correct position
		AND 	r1, r0, r6, LSL #4   ; r1 contains par2
		ORR 	r12, r1, LSR #2      ; par2 in correct position
		AND 	r1, r0, r6, LSL #8   ; r1 contains par3
		ORR 	r12, r1, LSR #5
		AND 	r1, r0, r6, LSL #16  
		ORR 	r12, r1, LSR #12
		BX		lr

generic_parity
		CMP		r10, #5				; base case
		BEQ		calc_correcting_code
		
		LDR  	r0, [r7], #1		; load actual mask
		AND  	r0, r8       		; r0 = unpacked parity
		BL	 	count_ones		    ; puts count in r0
		ANDS 	r0, #1          	; Zero flag will be set if count is even
		BEQ		shift				; Branch to shift instruction 
		
continue
		ADD		r10, #1				; increment index
		B		generic_parity

shift
		MOV 	r2, #2
		PUSH	{r2, r10}			; {base, exponential}
		BL		exp                 ; branch to calculate exponent
		POP		{r0}                ; get result (ie: amount of bits to shift)
		ROR		r0, r8, r0          ; shift parity to index 0
		AND		r0, r0, #1          ; r0 = unpacked parity bit
		LSL		r0, r10             ; move parity bit to position
		ORR		r11, r11, r0        ; pack calculated parity bit
		B		continue

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
		MOV		r2, #0
count_ones_loop
		CMP 	r0, #&0
		MOVEQ	r0, r2
		BXEQ	lr; base case
		
		SUB		r1, r0, #1
		AND		r0, r0, r1
		ADD     r2, r2, #1  ; increment count	
		B		count_ones_loop
		
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
           