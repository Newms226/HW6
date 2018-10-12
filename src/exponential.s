		AREA    |.text|, CODE, READONLY, ALIGN=2
		EXPORT  exp
			
;2 ^ r10 = r9
;
; r5 -> base
; r6 -> exponent
; r7 -> general purpose (working value)
exp
		POP		{r5, r6}
		CMP		r6, #0
		BXEQ	lr
		MOV		r7, r5
		
loop
		CMP		r6, #1
		BLS		return
		
		MUL		r6, r5 ; OVERFLOW!
		BVS     error
		SUB		r6, r6, #1
		B		loop
		
return
		PUSH	{r7}
		BX		lr
		
error
		
		END