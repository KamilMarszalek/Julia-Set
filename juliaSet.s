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
    cvtsi2sd xmm7, rsi ; xmm7 = width
    mulsd xmm7, xmm5 ; xmm7 = width * scale
    divsd xmm6, xmm7 ; xmm6 = 2 * (col - offsetX) * escapeRadius / (width * scale)

    ; calc imag part xmm8 = zImag
    cvtsi2sd xmm8, r8 ; xmm8 = row
    subsd xmm8, xmm4 ; xmm8 = row - offsetY
    mulsd xmm8, xmm0 ; xmm8 = (row - offsetY) * escapeRadius
    addsd xmm8, xmm8 ; xmm8 = 2 * (row - offsetY) * escapeRadius
    cvtsi2sd xmm7, rdx ; xmm7 = height
    mulsd xmm7, xmm5 ; xmm7 = height * scale
    divsd xmm8, xmm7 ; xmm8 = 2 * (row - offsetY) * escapeRadius / (height * scale)

    ; set iter counter
    mov rcx, 128
pixelLoop:
    ; check if iter counter is zero
    test rcx, rcx
    jz endPixelLoop

    ; calc zReal^2
    movsd xmm7, xmm6 ; xmm7 = zReal
    mulsd xmm7, xmm6 ; xmm7 = zReal^2
    
    ; calc zImag^2
    movsd xmm9, xmm8 ; xmm9 = zImag
    mulsd xmm9, xmm8 ; xmm9 = zImag^2

    ; xmm7 = zReal^2 + zImag^2
    addsd xmm7, xmm9

    ; xmm9 = escapeRadius^2
    movsd xmm9, xmm0
    mulsd xmm9, xmm0

    ; if zReal^2 + zImag^2 > escapeRadius^2, then break
    comisd xmm7, xmm9
    jge endPixelLoop

    ; xmm7 = zReal^2 - zImag^2
    movsd xmm7, xmm6 ; xmm7 = zReal
    mulsd xmm7, xmm6 ; xmm7 = zReal^2
    movsd xmm9, xmm8 ; xmm9 = zImag
    mulsd xmm9, xmm8 ; xmm9 = zImag^2
    subsd xmm7, xmm9 ; xmm7 = zReal^2 - zImag^2

    ; xmm10 = 2 * zReal * zImag + cImag
    movsd xmm10, xmm6 ; xmm10 = zReal
    mulsd xmm10, xmm8 ; xmm10 = zReal * zImag
    addsd xmm10, xmm10 ; xmm10 = 2 * zReal * zImag
    addsd xmm10, xmm2 ; xmm10 = 2 * zReal * zImag + cImag

    ; xmm11 = xmm7 + cReal
    movsd xmm11, xmm7 ; xmm11 = zReal^2 - zImag^2
    addsd xmm11, xmm1 ; xmm11 = zReal^2 - zImag^2 + cReal

    ; decrement iter counter
    dec rcx
    jmp pixelLoop
endPixelLoop:
    imul rcx, 255 ; rcx = 255 * (128 - iter)
    sar rcx, 7 ; rcx = 255 * (128 - iter) / maxIter

    ; rax = 3 * (width * row + col)
    mov rax, rsi    ; rax = width
    imul rax, r8    ; rax = width * row
    add rax, r9     ; rax = width * row + col
    imul rax, 3     ; rax = 3 * (width * row + col)
    
    mov [rdi + rax], cl 
    mov byte [rdi + rax + 1], 0
    mov byte [rdi + rax + 2], 0

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