;===============================================================================
; BASIC Loader

*=$0801 ; 10 SYS (2049)

        byte    $0E, $08, $0A, $00, $9E, $20, $28, $32
        byte    $30, $34, $39, $29, $00, $00, $00

;===============================================================================
; Initialization

        ; Turn off interrupts to stop LIBSCREEN_WAIT failing every so 
        ; often when the kernal interrupt syncs up with the scanline test
        sei

        ; Disable run/stop + restore keys
        lda #$FC 
        sta $0328

        ; Set border and background colors.
        ; The last 3 parameters are not used yet.
        LIBSCREEN_SETCOLORS Blue, White, Black, Black, Black

        ; Fill 1000 bytes (40x25) of screen memory
        LIBSCREEN_SET1000 SCREENRAM, 'a'

        ; Fill 1000 bytes (40x25) of color memory
        LIBSCREEN_SET1000 COLORRAM, Black

;===============================================================================
; Update

gMainLoop
        LIBSCREEN_WAIT_V 255
        ;inc EXTCOL ; start code timer change border color

        ; Game update code goes here

        ;dec EXTCOL ; end code timer reset border color
        jmp gMainLoop