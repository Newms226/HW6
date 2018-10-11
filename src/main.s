; we align 32 bit variables to 32-bits
; we align op codes to 16 bits
       THUMB
       AREA    DATA, ALIGN=4 
       EXPORT  M [DATA,SIZE=4]
M      SPACE   4
                 
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT  Start
Start
		;MOV		r0, #0x24
		BL		test_count_ones
		
		B		.

; Assume that r0 has the word loaded. Places count in r2 (w/o reseting).
; WARNING: Code overwrites r0
; r0 = word
; r1 = word!
; r2 = count
count_ones
		CMP		r0, #0
		BLXEQ  	lr		; base case
		; else
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
           