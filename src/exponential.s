		AREA    |.text|, CODE, READONLY, ALIGN=2
		EXPORT  exp
			
;2 ^ r10 = r9
;
; r0 -> base
; r1 -> exponent
; r2 -> general purpose (working value)
exp
		POP		{r0, r1}
		MOV		r2, r0
		
loop
		CMP		r1, #1
		BLS		return
		
		MUL		r2, r2, r0 ; OVERFLOW!
		BVS     error
		SUB		r1, r1, #1
		B		loop
		
return
		PUSH	{r2}
		BX		lr
		
error
		
		END