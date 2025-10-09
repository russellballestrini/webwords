; x86-64 Assembly WebWords String Search Implementation
; Demonstrates Assembly's low-level string processing capabilities

section .data
    msg_start db 'ASM: Starting Assembly string search...', 10, 0
    msg_found db 'ASM: Keyword FOUND using Assembly string operations!', 10, 0
    msg_not_found db 'ASM: Keyword NOT FOUND after Assembly analysis', 10, 0
    msg_analysis db 'ASM: Assembly analysis complete', 10, 0
    result_true db 'true', 0
    result_false db 'false', 0
    newline db 10, 0

section .bss
    keyword_buffer resb 256      ; Buffer for keyword
    content_buffer resb 65536    ; Buffer for content (64KB max)
    keyword_len resq 1           ; Length of keyword
    content_len resq 1           ; Length of content
    match_found resq 1           ; 1 if found, 0 if not

section .text
    global _start

; Function to convert character to lowercase
to_lowercase:
    cmp al, 'A'
    jl .done
    cmp al, 'Z'
    jg .done
    add al, 32              ; Convert to lowercase
.done:
    ret

; Function to search for keyword in content using Assembly string operations
; This demonstrates Assembly's byte-level manipulation capabilities
search_keyword:
    ; Print start message
    mov rax, 1              ; sys_write
    mov rdi, 2              ; stderr
    mov rsi, msg_start
    mov rdx, 47             ; length of start message
    syscall
    
    ; Initialize search variables
    mov qword [match_found], 0
    mov rsi, content_buffer ; Source (content)
    mov r8, [content_len]   ; Content length
    mov r9, [keyword_len]   ; Keyword length
    
    ; Check if keyword length is 0
    cmp r9, 0
    je .not_found
    
    ; Main search loop
.search_loop:
    ; Check if we have enough characters left
    mov rax, r8
    sub rax, r9
    jl .not_found           ; Not enough characters left
    
    ; Compare keyword with current position
    push rsi                ; Save current position
    push r8                 ; Save remaining length
    
    ; Character-by-character comparison (case-insensitive)
    mov rdi, keyword_buffer ; Keyword
    mov rcx, r9            ; Number of characters to compare
    
.compare_loop:
    ; Load characters and convert to lowercase
    lodsb                  ; Load byte from content into AL
    call to_lowercase      ; Convert content char to lowercase
    mov bl, al             ; Store content char in BL
    
    mov al, [rdi]          ; Load keyword char
    call to_lowercase      ; Convert keyword char to lowercase
    
    ; Compare characters
    cmp al, bl
    jne .no_match          ; Characters don't match
    
    inc rdi                ; Next keyword character
    loop .compare_loop     ; Continue comparison
    
    ; If we reach here, we found a match!
    mov qword [match_found], 1
    
    ; Clean up stack
    pop r8
    pop rsi
    jmp .found
    
.no_match:
    ; Restore registers and try next position
    pop r8
    pop rsi
    
    ; Move to next character in content
    inc rsi
    dec r8
    jmp .search_loop
    
.found:
    ; Print found message
    mov rax, 1              ; sys_write
    mov rdi, 2              ; stderr
    mov rsi, msg_found
    mov rdx, 52             ; length of found message
    syscall
    ret
    
.not_found:
    ; Print not found message
    mov rax, 1              ; sys_write
    mov rdi, 2              ; stderr
    mov rsi, msg_not_found
    mov rdx, 49             ; length of not found message
    syscall
    ret

; Function to read file content
read_file:
    ; Open file
    mov rax, 2              ; sys_open
    mov rsi, 0              ; O_RDONLY
    syscall
    cmp rax, 0
    jl .error
    
    ; Read file content
    mov rdi, rax            ; File descriptor
    mov rax, 0              ; sys_read
    mov rsi, content_buffer ; Buffer
    mov rdx, 65535          ; Max bytes to read
    syscall
    
    ; Store content length
    mov [content_len], rax
    
    ; Close file
    mov rax, 3              ; sys_close
    syscall
    ret
    
.error:
    mov qword [content_len], 0
    ret

_start:
    ; Read keyword from file
    mov rax, 2              ; sys_open
    mov rdi, keyword_file   ; filename
    mov rsi, 0              ; O_RDONLY
    syscall
    cmp rax, 0
    jl .exit_error
    
    ; Read keyword
    mov rdi, rax            ; File descriptor
    mov rax, 0              ; sys_read
    mov rsi, keyword_buffer ; Buffer
    mov rdx, 255            ; Max bytes
    syscall
    mov [keyword_len], rax
    
    ; Remove newline if present
    cmp rax, 0
    jle .close_keyword_file
    dec rax                 ; Remove newline
    mov [keyword_len], rax
    mov byte [keyword_buffer + rax], 0  ; Null terminate
    
.close_keyword_file:
    mov rax, 3              ; sys_close
    syscall
    
    ; Read content from file
    mov rax, 2              ; sys_open
    mov rdi, content_file   ; filename
    mov rsi, 0              ; O_RDONLY
    syscall
    cmp rax, 0
    jl .exit_error
    
    ; Read content
    mov rdi, rax            ; File descriptor
    mov rax, 0              ; sys_read
    mov rsi, content_buffer ; Buffer
    mov rdx, 65535          ; Max bytes
    syscall
    mov [content_len], rax
    
    ; Close content file
    mov rax, 3              ; sys_close
    syscall
    
    ; Perform Assembly string search
    call search_keyword
    
    ; Write result to file
    mov rax, 2              ; sys_open (create)
    mov rdi, result_file    ; filename
    mov rsi, 577            ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 644            ; File permissions
    syscall
    
    ; Write result
    mov rdi, rax            ; File descriptor
    mov rax, 1              ; sys_write
    
    ; Choose result string
    cmp qword [match_found], 1
    je .write_true
    
    ; Write "false"
    mov rsi, result_false
    mov rdx, 5
    jmp .write_result
    
.write_true:
    ; Write "true"
    mov rsi, result_true
    mov rdx, 4
    
.write_result:
    syscall
    
    ; Close result file
    mov rax, 3              ; sys_close
    syscall
    
    ; Print completion message
    mov rax, 1              ; sys_write
    mov rdi, 2              ; stderr
    mov rsi, msg_analysis
    mov rdx, 32             ; length
    syscall
    
    ; Exit successfully
    mov rax, 60             ; sys_exit
    mov rdi, 0              ; exit status
    syscall

.exit_error:
    ; Exit with error
    mov rax, 60             ; sys_exit
    mov rdi, 1              ; exit status
    syscall

section .data
    keyword_file db '/tmp/asm_keyword.txt', 0
    content_file db '/tmp/asm_content.txt', 0
    result_file db '/tmp/asm_result.txt', 0