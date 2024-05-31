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
    cvtsi2sd xmm7, r8 ; xmm7 = row
    subsd xmm7, xmm4 ; xmm7 = row - offsetY
    mulsd xmm7, xmm0 ; xmm7 = (row - offsetY) * escapeRadius
    addsd xmm7, xmm7 ; xmm7 = 2 * (row - offsetY) * escapeRadius
    cvtsi2sd xmm8, rdx ; xmm8 = height
    mulsd xmm8, xmm5 ; xmm8 = height * scale
    divsd xmm7, xmm8 ; xmm7 = 2 * (row - offsetY) * escapeRadius / (height * scale)

    ; set iter counter maxIteration = 128
    mov rcx, 128
pixelLoop:
    ; calc zReal^2
    movsd xmm8, xmm6 ; xmm8 = zReal
    mulsd xmm8, xmm8 ; xmm8 = zReal^2
    
    ; calc zImag^2
    movsd xmm9, xmm7 ; xmm9 = zImag
    mulsd xmm9, xmm9 ; xmm9 = zImag^2

    ; xmm8 = zReal^2 + zImag^2
    addsd xmm8, xmm9

    ; xmm9 = escapeRadius^2
    movsd xmm9, xmm0
    mulsd xmm9, xmm9

    ; if zReal^2 + zImag^2 > escapeRadius^2, then break
    comisd xmm8, xmm9
    jae endPixelLoop

    ; xmm8 = zReal^2 - zImag^2
    movsd xmm8, xmm6 ; xmm8 = zReal
    mulsd xmm8, xmm8 ; xmm8 = zReal^2
    movsd xmm9, xmm7 ; xmm9 = zImag
    mulsd xmm9, xmm9 ; xmm9 = zImag^2
    subsd xmm8, xmm9 ; xmm8 = zReal^2 - zImag^2

    ; xmm7 = 2 * zReal * zImag + cImag
    addsd xmm7, xmm7
    mulsd xmm7, xmm6
    addsd xmm7, xmm2

    ; xmm6 = xmm7 + cReal
    movsd xmm6, xmm8 ; xmm6 = zReal^2 - zImag^2
    addsd xmm6, xmm1 ; xmm6 = zReal^2 - zImag^2 + cReal

    ; decrement iter counter
    dec rcx
    ; check if iter counter is zero
    cmp rcx, 0
    jne pixelLoop
endPixelLoop:
   	; rcx = uint8_t r = ((maxIteration - iteration) * 255) / maxIteration;
	imul rcx, 255		; rcx = (maxIteration - iteration) * 255
	sar	rcx, 7			; rcx = (maxIteration - iteration) * 255 / maxIteration (maxIteration == 128 == 2^7)

	; r10 = pixelIdx = 3 * (row * width + col)
	mov	r10, r8			; r10 = row
	imul r10, rsi		; r10 = row * width
	add	r10, r9			; r10 = row * width + col
	mov	rax, r10		; rax = 1 * (row * width + col)
	shl	r10, 1			; r10 = 2 * (row * width + col)
	add	r10, rax		; r10 = 3 * (row * width + col)

	mov [rdi + r10], cl				; *(pixels + pixelIdx) = cl
	mov	byte [rdi + r10 + 1], cl	; *(pixels + pixelIdx + 1) = cl
	mov	byte [rdi + r10 + 2], 0		; *(pixels + pixelIdx + 2) = 0

    ; decrement col
    dec r9
    jnz innerLoop
endInnerLoop:
    ; decrement row
    dec r8
    jnz outerLoop
end:
    ; restore stack frame
    mov rsp, rbp
    pop rbp
    ret
    