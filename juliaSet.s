section .text
global juliaSet

juliaSet:
    ; Arguments: 
    ; rdi = buffer address
    ; rsi = width
    ; rdx = height
    ; xmm0 = escapeRadius
    ; xmm1 = cReal
    ; xmm2 = cImag
    ; xmm3 = offsetX
    ; xmm4 = offsetY
    ; xmm5 = scale

begin:
    ; set up stack frame
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    ; r8 = row = height - 1 = rdx - 1
    mov r8, rdx
    dec r8
outerLoop:
    ; r9 = col = width - 1 = rsi - 1
    mov r9, rsi
    dec r9
innerLoop:
    ; calc real part xmm6 = zReal
    cvtsi2sd xmm6, r9 ; xmm6 = col
    subsd xmm6, xmm3 ; xmm6 = col - offsetX
    mulsd xmm6, xmm0 ; xmm6 = (col - offsetX) * escapeRadius
    addsd xmm6, xmm6 ; xmm6 = 2 * (col - offsetX) * escapeRadius
    cvtsi2sd xmm8, rsi ; xmm8 = width
    mulsd xmm8, xmm5 ; xmm8 = width * scale
    divsd xmm6, xmm8 ; xmm6 = 2 * (col - offsetX) * escapeRadius / (width * scale)

    ; calc imag part xmm7 = zImag
    cvtsi2sd xmm7, r8 ; xmm8 = row
    subsd xmm7, xmm4 ; xmm8 = row - offsetY
    mulsd xmm7, xmm0 ; xmm8 = (row - offsetY) * escapeRadius
    addsd xmm7, xmm7 ; xmm8 = 2 * (row - offsetY) * escapeRadius
    cvtsi2sd xmm8, rdx ; xmm7 = height
    mulsd xmm8, xmm5 ; xmm7 = height * scale
    divsd xmm7, xmm8 ; xmm8 = 2 * (row - offsetY) * escapeRadius / (height * scale)

    ; set iter counter
    mov rax, 0
pixelLoop:
    ; check if iter counter is zero
    cmp rax, 128
    je endPixelLoop

    ; calc zReal^2
    movsd xmm8, xmm6 ; xmm7 = zReal
    mulsd xmm8, xmm8 ; xmm7 = zReal^2
    
    ; calc zImag^2
    movsd xmm9, xmm7 ; xmm9 = zImag
    mulsd xmm9, xmm9 ; xmm9 = zImag^2

    ; xmm7 = zReal^2 + zImag^2
    addsd xmm8, xmm9

    ; xmm9 = escapeRadius^2
    movsd xmm9, xmm0
    mulsd xmm9, xmm9

    ; if zReal^2 + zImag^2 > escapeRadius^2, then break
    comisd xmm8, xmm9
    jae endPixelLoop

    ; xmm7 = zReal^2 - zImag^2
    movsd xmm8, xmm6 ; xmm7 = zReal
    mulsd xmm8, xmm8 ; xmm7 = zReal^2
    movsd xmm9, xmm7 ; xmm9 = zImag
    mulsd xmm9, xmm9 ; xmm9 = zImag^2
    subsd xmm8, xmm9 ; xmm7 = zReal^2 - zImag^2

    ; xmm10 = 2 * zReal * zImag + cImag
    addsd xmm7, xmm7
    mulsd xmm7, xmm6
    addsd xmm7, xmm2

    ; xmm11 = xmm7 + cReal
    movsd xmm6, xmm8 ; xmm11 = zReal^2 - zImag^2
    addsd xmm6, xmm1 ; xmm11 = zReal^2 - zImag^2 + cReal

    ; decrement iter counter
    inc rax
    jmp pixelLoop
endPixelLoop:
   	; rcx = uint8_t r = ((maxIteration - iteration) * 255) / maxIteration;
	mov	rcx, 128		; rcx = maxIteration
	sub	rcx, rax		; rcx = maxIteration - iteration
	imul rcx, 255		; rcx = (maxIteration - iteration) * 255
	sar	rcx, 7			; rcx = (maxIteration - iteration) * 255 / maxIteration (maxIteration == 128 == 2^7)

	; rbx = pixelIdx = 3 * (row * width + col)
	mov	rbx, r8			; rbx = row
	imul rbx, rsi		; rbx = row * width
	add	rbx, r9			; rbx = row * width + col
	mov	r12, rbx		; r12 = 1 * (row * width + col)
	shl	rbx, 1			; rbx = 2 * (row * width + col)
	add	rbx, r12		; rbx = 3 * (row * width + col)

	mov [rdi + rbx], cl				; *(pixels + pixelIdx) = r
	mov	byte [rdi + rbx + 1], cl		; *(pixels + pixelIdx + 1) = 0
	mov	byte [rdi + rbx + 2], 0		; *(pixels + pixelIdx + 2) = 0

    ; decrement col
    dec r9
    jnz innerLoop
endInnerLoop:
    ; decrement row
    dec r8
    jnz outerLoop
end:
    ; restore stack frame
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret