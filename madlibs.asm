; Complete Mad Libs Windows Application
; Compile with: nasm -f win64 madlibs.asm -o madlibs.obj
; Link with: link /subsystem:windows madlibs.obj kernel32.lib user32.lib gdi32.lib

DEFAULT REL
BITS 64

; External Windows API functions
extern ExitProcess
extern RegisterClassExW
extern CreateWindowExW
extern ShowWindow
extern UpdateWindow
extern GetMessageW
extern TranslateMessage
extern DispatchMessageW
extern DefWindowProcW
extern PostQuitMessage
extern GetWindowTextW
extern SetWindowTextW
extern SendMessageW
extern MessageBoxW
extern GetDC
extern ReleaseDC
extern InvalidateRect
extern BeginPaint
extern EndPaint
extern TextOutW
extern CreateFontW
extern SelectObject
extern DeleteObject
extern SetBkMode
extern SetTextColor

section .data
    ; Window classes
    ClassName    dw 'M','a','d','L','i','b','s','C','l','a','s','s',0
    WindowTitle  dw 'M','a','d',' ','L','i','b','s',' ','G','a','m','e',0
    EditClass    dw 'E','D','I','T',0
    ButtonClass  dw 'B','U','T','T','O','N',0
    StaticClass  dw 'S','T','A','T','I','C',0
    
    ; Control labels
    LabelTitle   dw 'M','a','d',' ','L','i','b','s',' ','G','a','m','e',0
    LabelNoun    dw 'E','n','t','e','r',' ','a',' ','n','o','u','n',':',' ',0
    LabelVerb    dw 'E','n','t','e','r',' ','a',' ','v','e','r','b',':',' ',0
    LabelAdj     dw 'E','n','t','e','r',' ','a','n',' ','a','d','j','e','c','t','i','v','e',':',' ',0
    ButtonGenerate dw 'G','e','n','e','r','a','t','e',' ','S','t','o','r','y',0
    ButtonClear   dw 'C','l','e','a','r',' ','A','l','l',0
    ButtonExit    dw 'E','x','i','t',0
    
    ; Messages
    ErrorTitle      dw 'E','r','r','o','r',0
    ErrorEmpty      dw 'P','l','e','a','s','e',' ','f','i','l','l',' ','a','l','l',' ','f','i','e','l','d','s','.',0
    StoryTitle      dw 'Y','o','u','r',' ','M','a','d',' ','L','i','b',' ','S','t','o','r','y',0
    
    ; Story templates
    StoryTemplate1  dw 'T','h','e',' ','%','s',' ','%','s',' ','%','s',' ','w','e','n','t',' ','t','o',' ','t','h','e',' ','p','a','r','k','.',0
    StoryTemplate2  dw 'O','n','c','e',' ','u','p','o','n',' ','a',' ','t','i','m','e',',',' ','a',' ','%','s',' ','%','s',' ','%','s',' ','d','a','n','c','e','d','.',0
    StoryTemplate3  dw 'I','n',' ','a',' ','%','s',' ','w','o','r','l','d',',',' ','t','h','e',' ','%','s',' ','%','s',' ','s','m','i','l','e','d','.',0
    StoryTemplate4  dw 'W','h','e','n',' ','t','h','e',' ','%','s',' ','%','s',' ','s','a','w',' ','t','h','e',' ','%','s',',',' ','i','t',' ','l','a','u','g','h','e','d','.',0
    StoryTemplate5  dw 'T','h','e',' ','%','s',' ','%','s',' ','f','o','u','n','d',' ','a',' ','%','s',' ','t','r','e','a','s','u','r','e','.',0
    
    ; Window constants
    WS_OVERLAPPED       equ 0x00000000
    WS_CAPTION          equ 0x00C00000
    WS_SYSMENU         equ 0x00080000
    WS_THICKFRAME      equ 0x00040000
    WS_MINIMIZEBOX     equ 0x00020000
    WS_MAXIMIZEBOX     equ 0x00010000
    WS_OVERLAPPEDWINDOW equ WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX
    WS_VISIBLE         equ 0x10000000
    WS_CHILD           equ 0x40000000
    WS_BORDER          equ 0x00800000
    ES_LEFT            equ 0x0000
    ES_AUTOHSCROLL     equ 0x0080
    BS_PUSHBUTTON      equ 0x00000000
    
    ; Control IDs
    ID_EDIT_NOUN       equ 101
    ID_EDIT_VERB       equ 102
    ID_EDIT_ADJ        equ 103
    ID_BTN_GENERATE    equ 104
    ID_BTN_CLEAR       equ 105
    ID_BTN_EXIT        equ 106
    
    ; Colors
    COLOR_WINDOW      equ 5
    COLOR_WINDOWTEXT  equ 8
    TRANSPARENT       equ 1
    
    ; Random number generator
    rand_a            dq 6364136223846793005
    rand_c            dq 1442695040888963407
    
section .bss
    ; Window handles
    hInstance       resq 1
    hwnd            resq 1
    hEditNoun       resq 1
    hEditVerb       resq 1
    hEditAdj        resq 1
    hBtnGenerate    resq 1
    hBtnClear       resq 1
    hBtnExit        resq 1
    
    ; Message and window class structures
    msg             resq 8
    wc              resq 12
    ps              resq 16
    
    ; Buffers
    nounBuffer      resw 32
    verbBuffer      resw 32
    adjBuffer       resw 32
    storyBuffer     resw 512
    tempBuffer      resw 512
    
    ; Random number state
    rand_state      resq 1

section .text
global WinMain
global WindowProc

WinMain:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Store instance handle
    mov [hInstance], rcx
    
    ; Initialize random number generator
    rdtsc
    mov [rand_state], rax
    
    ; Register window class
    mov qword [wc], 48
    mov dword [wc+8], 0x0003
    lea rax, [WindowProc]
    mov [wc+16], rax
    mov qword [wc+24], 0
    mov qword [wc+28], 0
    mov rax, [hInstance]
    mov [wc+32], rax
    mov qword [wc+40], 0
    mov qword [wc+48], 0
    mov qword [wc+56], COLOR_WINDOW + 1
    mov qword [wc+64], 0
    lea rax, [ClassName]
    mov [wc+72], rax
    mov qword [wc+80], 0
    
    lea rcx, [wc]
    call RegisterClassExW
    test rax, rax
    jz .exit
    
    ; Create main window
    xor rcx, rcx
    lea rdx, [ClassName]
    lea r8, [WindowTitle]
    mov r9d, WS_OVERLAPPEDWINDOW | WS_VISIBLE
    mov qword [rsp+32], CW_USEDEFAULT
    mov qword [rsp+40], CW_USEDEFAULT
    mov qword [rsp+48], 600
    mov qword [rsp+56], 500
    mov qword [rsp+64], 0
    mov qword [rsp+72], 0
    mov rax, [hInstance]
    mov qword [rsp+80], rax
    mov qword [rsp+88], 0
    call CreateWindowExW
    mov [hwnd], rax
    
    ; Create controls
    call CreateControls
    
    ; Show and update window
    mov rcx, [hwnd]
    mov rdx, 1
    call ShowWindow
    mov rcx, [hwnd]
    call UpdateWindow
    
    ; Message loop
.msgloop:
    lea rcx, [msg]
    xor rdx, rdx
    xor r8, r8
    xor r9, r9
    call GetMessageW
    test rax, rax
    jle .exit
    
    lea rcx, [msg]
    call TranslateMessage
    
    lea rcx, [msg]
    call DispatchMessageW
    jmp .msgloop
    
.exit:
    xor rcx, rcx
    call ExitProcess

CreateControls:
    push rbp
    mov rbp, rsp
    sub rsp, 96
    
    ; Create input controls (labels and edit boxes)
    lea rdx, [StaticClass]
    lea r8, [LabelNoun]
    mov r9d, WS_CHILD | WS_VISIBLE
    mov qword [rsp+32], 20
    mov qword [rsp+40], 50
    mov qword [rsp+48], 150
    mov qword [rsp+56], 20
    call CreateStandardControl
    
    lea rdx, [EditClass]
    xor r8, r8
    mov r9d, WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL
    mov qword [rsp+32], 180
    mov qword [rsp+40], 50
    mov qword [rsp+48], 200
    mov qword [rsp+56], 20
    mov qword [rsp+72], ID_EDIT_NOUN
    call CreateStandardControl
    mov [hEditNoun], rax
    
    ; Similar control creation for verb and adjective...
    ; [Additional control creation code removed for brevity, 
    ; but would follow same pattern with different positions]
    
    ; Create buttons
    lea rdx, [ButtonClass]
    lea r8, [ButtonGenerate]
    mov r9d, WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON
    mov qword [rsp+32], 20
    mov qword [rsp+40], 200
    mov qword [rsp+48], 150
    mov qword [rsp+56], 30
    mov qword [rsp+72], ID_BTN_GENERATE
    call CreateStandardControl
    mov [hBtnGenerate], rax
    
    ; Create Clear and Exit buttons
    ; [Button creation code follows similar pattern]
    
    leave
    ret

CreateStandardControl:
    ; Standard parameters already in registers/stack
    xor rcx, rcx        ; dwExStyle
    mov rax, [hwnd]
    mov qword [rsp+64], rax
    mov rax, [hInstance]
    mov qword [rsp+80], rax
    mov qword [rsp+88], 0
    call CreateWindowExW
    ret

GenerateRandomNumber:
    push rbp
    mov rbp, rsp
    
    mov rax, [rand_state]
    mov rdx, [rand_a]
    mul rdx
    add rax, [rand_c]
    mov [rand_state], rax
    shr rax, 32
    
    leave
    ret

GenerateStory:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Validate inputs
    call ValidateInputs
    test rax, rax
    jz .error_empty
    
    ; Choose random template
    call GenerateRandomNumber
    mov rcx, 5          ; Number of templates
    xor rdx, rdx
    div rcx
    ; rdx now contains template index (0-4)
    
    ; Select template based on random number
    lea rsi, [StoryTemplate1]
    cmp rdx, 0
    je .template_selected
    lea rsi, [StoryTemplate2]
    cmp rdx, 1
    je .template_selected
    ; [Template selection continues...]
    
.template_selected:
    ; Generate story
    lea rdi, [storyBuffer]
    call GenerateFromTemplate
    
    ; Display story
    xor rcx, rcx
    lea rdx, [storyBuffer]
    lea r8, [StoryTitle]
    mov r9d, 0x40      ; MB_OK
    call MessageBoxW
    jmp .finish
    
.error_empty:
    xor rcx, rcx
    lea rdx, [ErrorEmpty]
    lea r8, [ErrorTitle]
    mov r9d, 0x10      ; MB_ICONERROR
    call MessageBoxW
    
.finish:
    leave
    ret

GenerateFromTemplate:
    ; Template in rsi, destination in rdi
    ; [Story generation code that replaces placeholders with user input]
    ret

ValidateInputs:
    ; [Input validation code]
    ret

ClearAllFields:
    ; [Code to clear all input fields]
    ret

WindowProc:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    cmp rdx, WM_COMMAND
    je .wmcommand
    
    cmp rdx, WM_DESTROY
    je .wmdestroy
    
    call DefWindowProcW
    jmp .finish
    
.wmcommand:
    mov rax, r8
    shr rax, 16
    cmp ax, BN_CLICKED
    jne .finish
    
    mov rax, r8
    and rax, 0xFFFF
    
    cmp rax, ID_BTN_GENERATE
    je .generate
    cmp rax, ID_BTN_CLEAR
    je .clear
    cmp rax, ID_BTN_EXIT
    je .exit
    jmp .finish
    
.generate:
    call GenerateStory
    jmp .finish
    
.clear:
    call ClearAllFields
    jmp .finish
    
.exit:
    mov rcx, [hwnd]
    xor rdx, rdx
    xor r8, r8
    xor r9, r9
    call PostMessageW
    jmp .finish
    
.wmdestroy:
    xor rcx, rcx
    call PostQuitMessage
    xor rax, rax
    
; Continuing from previous implementation...

.finish:
    leave
    ret

; Complete the ValidateInputs function
ValidateInputs:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Check noun field
    mov rcx, [hEditNoun]
    lea rdx, [tempBuffer]
    mov r8, 32
    call GetWindowTextW
    test rax, rax
    jz .invalid
    
    ; Check verb field
    mov rcx, [hEditVerb]
    lea rdx, [tempBuffer]
    mov r8, 32
    call GetWindowTextW
    test rax, rax
    jz .invalid
    
    ; Check adjective field
    mov rcx, [hEditAdj]
    lea rdx, [tempBuffer]
    mov r8, 32
    call GetWindowTextW
    test rax, rax
    jz .invalid
    
    mov rax, 1      ; Valid input
    jmp .finish
    
.invalid:
    xor rax, rax    ; Invalid input
    
.finish:
    leave
    ret

; Complete GenerateFromTemplate function
GenerateFromTemplate:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    ; Save registers we'll use
    push rsi
    push rdi
    push rbx
    
    ; Copy template to working buffer
    lea rdi, [tempBuffer]
    
.copy_loop:
    mov ax, [rsi]
    mov [rdi], ax
    add rsi, 2
    add rdi, 2
    test ax, ax
    jnz .copy_loop
    
    ; Reset pointers for placeholder replacement
    lea rsi, [tempBuffer]
    lea rdi, [storyBuffer]
    
    ; Get input values
    mov rcx, [hEditNoun]
    lea rdx, [nounBuffer]
    mov r8, 32
    call GetWindowTextW
    
    mov rcx, [hEditVerb]
    lea rdx, [verbBuffer]
    mov r8, 32
    call GetWindowTextW
    
    mov rcx, [hEditAdj]
    lea rdx, [adjBuffer]
    mov r8, 32
    call GetWindowTextW
    
    ; Replace placeholders
    lea rbx, [nounBuffer]   ; First replacement string
    
.replace_loop:
    mov ax, [rsi]
    test ax, ax
    jz .done
    
    cmp ax, '%'
    je .check_placeholder
    
    mov [rdi], ax
    add rsi, 2
    add rdi, 2
    jmp .replace_loop
    
.check_placeholder:
    add rsi, 2          ; Skip '%'
    mov ax, [rsi]
    cmp ax, 's'
    jne .not_placeholder
    
    ; Insert replacement string
    push rsi
    mov rsi, rbx
    
.insert_loop:
    mov ax, [rsi]
    test ax, ax
    jz .insert_done
    mov [rdi], ax
    add rsi, 2
    add rdi, 2
    jmp .insert_loop
    
.insert_done:
    pop rsi
    ; Rotate to next replacement string
    lea rax, [verbBuffer]
    cmp rbx, [nounBuffer]
    cmove rbx, rax
    lea rax, [adjBuffer]
    cmp rbx, [verbBuffer]
    cmove rbx, rax
    add rsi, 2          ; Skip 's'
    jmp .replace_loop
    
.not_placeholder:
    mov word [rdi], '%'
    add rdi, 2
    mov [rdi], ax
    add rdi, 2
    add rsi, 2
    jmp .replace_loop
    
.done:
    mov word [rdi], 0   ; Null terminate
    
    ; Restore registers
    pop rbx
    pop rdi
    pop rsi
    
    leave
    ret

; Clear all input fields
ClearAllFields:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Clear noun field
    mov rcx, [hEditNoun]
    xor rdx, rdx
    call SetWindowTextW
    
    ; Clear verb field
    mov rcx, [hEditVerb]
    xor rdx, rdx
    call SetWindowTextW
    
    ; Clear adjective field
    mov rcx, [hEditAdj]
    xor rdx, rdx
    call SetWindowTextW
    
    ; Set focus to first field
    mov rcx, [hEditNoun]
    call SetFocus
    
    leave
    ret

; Helper function to create fancy font
CreateFancyFont:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    xor rcx, rcx        ; Height
    xor rdx, rdx        ; Width
    xor r8, r8          ; Escapement
    xor r9, r9          ; Orientation
    mov qword [rsp+32], 400    ; Weight (FW_NORMAL)
    mov qword [rsp+40], 0      ; Italic
    mov qword [rsp+48], 0      ; Underline
    mov qword [rsp+56], 0      ; StrikeOut
    mov qword [rsp+64], 1      ; CharSet (DEFAULT_CHARSET)
    mov qword [rsp+72], 0      ; OutputPrecision
    mov qword [rsp+80], 0      ; ClipPrecision
    mov qword [rsp+88], 0      ; Quality
    mov qword [rsp+96], 0      ; PitchAndFamily
    lea rax, [FontName]
    mov qword [rsp+104], rax   ; FaceName
    call CreateFontW
    
    leave
    ret

; Add animations for story display
AnimateStoryDisplay:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Get DC for animation
    mov rcx, [hwnd]
    call GetDC
    mov rbx, rax        ; Store DC
    
    ; Set up text properties
    mov rcx, rbx
    mov rdx, TRANSPARENT
    call SetBkMode
    
    mov rcx, rbx
    mov rdx, 0x000000FF ; Blue color
    call SetTextColor
    
    ; Create and select font
    call CreateFancyFont
    mov rcx, rbx
    mov rdx, rax
    call SelectObject
    mov r12, rax        ; Store old font
    
    ; Animate text
    xor r15, r15        ; Character counter
    
.animate_loop:
    ; Calculate position
    mov rcx, rbx
    lea rdx, [storyBuffer]
    mov r8, r15
    mov r9, 100         ; y position
    call TextOutW
    
    ; Delay
    mov rcx, 50         ; 50ms delay
    call Sleep
    
    inc r15
    cmp r15, 100        ; Max characters
    jl .animate_loop
    
    ; Cleanup
    mov rcx, rbx
    mov rdx, r12
    call SelectObject
    
    mov rcx, [hwnd]
    mov rdx, rbx
    call ReleaseDC
    
    leave
    ret

section .data
    ; Add font name for fancy display
    FontName    dw 'C','o','m','i','c',' ','S','a','n','s',' ','M','S',0
    
    ; Add animation timing constants
    ANIM_DELAY  equ 50
    MAX_CHARS   equ 100