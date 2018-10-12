             AREA    |.text|, CODE, READONLY, ALIGN=2
             EXPORT  Start
		   
par0	DCD		0x2AAAAA
par1	DCD		0xCCCCC
par2	DCD		0x30F0F0
par3	DCD		0xFF00
par4	DCD		0x3F0000
	
parA    DCD		0x3FFFFF
	
test1	DCD		0x331B3D
asnw1	DCD		0x331B7D
	
Start
		ADR		r0, test1;
		LDR		r8, [r0];
		
extract_recieved_code
		; word in r8
		; received code in r12
		MOV 	r12, #0 		; reset rec_parity_word
		MOV 	r6, #1
		MOV 	r0, r8          ; r0 = working space
		MOV 	r7, #3
		AND 	r1, r0, #6
		MOV 	r12, r1, LSR #1  ; bits 0 & 1 in correct position
		AND 	r1, r0, r6, LSL #4 ; r1 contains par2
		ORR 	r12, r12, r1, LSR #2 ; par2 in correct position
		AND 	r1, r0, r6, LSL #8 ; r1 contains par3
		ORR 	r12, r12, r1, LSR #5
		AND 	r1, r0, r6, LSL #16
		ORR 	r12, r12, r1, LSR #12
		
calc_parity_word
		
			
; generic method to calculate parity bit
;
; r0  -> general (initially loaded with address of mask)
; r9  -> index of working parity bit in recieved word
; r10 -> index of working parity bit in parity word
; r11 -> calculated parity bit
generic_parity
		LDR  	r0, [r0]            ; load actual mask
		AND  	r0, r0, r8       	; r0 = unpacked parity
		BL	 	count_ones		    ; puts count in r0
		ANDS 	r0, r0, #1          ; Zero flag will be set if count is even
		ROREQ	r0, r8, r1          ; shift parity to index 0
		ANDEQ	r0, r0, #1          ; r0 = unpacked parity bit
		LSL		r0, r10             ; move parity bit to position
		ORREQ	r11, r11, r0        ; pack calculated parity bit
		ADD		r10, r10, #1		; increment index      

calc_correcting_code
		EORS	r0, r12, r11
		BEQ		stop
		MOV		r1, #1
		LSL		r1, r0
		EOR		r8, r8, r1
		
stop
		B		.

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
           