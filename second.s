;   ===========================================================================
;   void decode_ean8(unsigned char *out, void *img, int bytesPerBar);
;   ===========================================================================

section     .data
    codes_left:  db 13, 25, 19, 61, 35, 49, 47, 59, 55, 11
    codes_right: db 114, 102, 108, 66, 92, 78, 80, 68, 72, 116

section     .text
global      decode_ean8

;   ===========================================================================
;           eax     -   buffer of *out
;           ebx     -   buffer of data image
;           cl      -   counter of number captured to out buffer
;           ch      -   counter of captured bars for one number
;           esi     -   buffer of current capture number
;           edi     -   number of bytes per one bar 
;   ===========================================================================

decode_ean8:
	push ebp
	mov	ebp, esp
	push ebx
	push esi
    push edi

	mov	eax, [ebp+8]	                        ;   unsigned char *out
	mov ebx, [ebp+12]                           ;   void *img
    mov edi, [ebp + 16]                             ;   int bytesPerBar

    xor esi, esi                                    ;   zero esi for capture number
    xor ecx, ecx                                    ;   zero ecx for counter

    mov dl, BYTE [ebx]                              ;   read first byte

decode_ean8_skip_101:                               ;   skip first brace '101' 
    add ebx, edi                                    
    add ebx, edi                   
    add ebx, edi                   

decode_ean8_getBit:                                 ;   checking value of bit: 1 - black bar, 0 - white bar
    mov dl, BYTE [ebx]
    
    shl esi, 1                          
    test dl, dl                                       ;   setting the proper value in esi accoriding to value of bit.
    jz decode_ean8_set_one                          ;          
    bts esi, 0                                      ;   zero bit set to 1

decode_ean8_set_one:
    inc ch                                          ;   increase counter for handle bars in one number
    add ebx, edi                                    ;   go to next bar  |   ebx + bytesPerBar

    cmp ch, 7                                       ;   if counter of handled bars < 7 
    jl decode_ean8_getBit                           ;       get next bar

decode_ean8_convert_number:                         ;   else save binary number to eax
    mov [eax], esi                                  
    inc eax
    
    mov ch, 0                                       ;   zero counter of captured bars for one number
    xor esi, esi                                    ;   zero currently captured number

    inc cl                                          ;   increase counter of number captured to out buffer
    cmp cl,4                                        ;   if cl ==   4
    jne decode_ean8_skip_middle                        
    add ebx, edi                                    ;   skip midlle brace '01010' 
    add ebx, edi                   
    add ebx, edi                   
    add ebx, edi                   
    add ebx, edi                   

decode_ean8_skip_middle:
    cmp cl,8                                        ;   if cl != 8
    jne decode_ean8_getBit                          ;       capture next number

;   ===========================================================================
;           eax     -   buffer of *out
;           cl      -   counter for idx in codes' tables
;           esi     -   counter for converted numbers
;           dl      -   codes section     
;   ===========================================================================

decode_ean8_convert_main:
 	mov	eax, [ebp+8]	                            
    xor cl, cl
    xor edx, edx                              
    xor esi, esi

decode_ean8_convert:
    mov cl, 0                                       ;   counter for idx in codes' tables
    
decode_ean8_loop:                                   ;   loop responsible for converting numbers for decoded code
    mov dl, BYTE [codes_left + ecx]                 ;   looking for codes in left part
    cmp esi, 4                                      ;   if esi < 4
    jl decode_ean8_compare                          ;       go to comparing codes
    mov dl, BYTE [codes_right + ecx]                ;   looking for codes in right part

decode_ean8_compare:
    cmp BYTE [eax], dl                              
    jne decode_ean8_compare_next                    ;   if not match, compare next             
    mov [eax], cl                                   ;   if match, set index in the section to eax
    cmp cl, 10                                      ;   go to next number
    jl end_loop                                     ;

decode_ean8_compare_next:
    inc cl                                          ;   increase index of compared number in codes' table
    cmp cl, 10                                         
    jne decode_ean8_loop                            

end_loop:
    inc esi                                         ;   inc counter for convered number
    inc eax                                         ;   get next number to conversion
    cmp esi, 8                                      ;   if not convered 8 numbers
    jl decode_ean8_convert                          ;       convert next one

decode_ean8_exit:                                   ;   else
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
	pop	ebp
	ret