; we align 32 bit variables to 32-bits
; we align op codes to 16 bits
       THUMB
       AREA    DATA, ALIGN=4 
       EXPORT  M [DATA,SIZE=4]
M      SPACE   4
                 
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT  Start

Start
		LDR		r0, #1
		BLR		count_ones

; Assume that r0 has the word loaded. Places count in r2.
; WARNING: Code overwrites r0
; r0 = word
; r1 = word!
; r2 = count
count_ones
		CMP		r0, #0
		BEQ		lr			; base case
		; else
		SUB		r1, r0, #1
		AND		r0, r0, r0
		ADD     r2, r2, #1  ; increment count
		B		count_ones
		
        ALIGN      
        END  
           