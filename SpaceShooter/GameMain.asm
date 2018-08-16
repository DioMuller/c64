;-------------------------------------------------------------------------------
; BASIC Loader
;-------------------------------------------------------------------------------
*=$0801 ; 10 SYS (2064)

        byte $0E, $08, $0A, $00, $9E, $20, $28, $32
        byte $30, $36, $34, $29, $00, $00, $00

;-------------------------------------------------------------------------------
; Initialization
;-------------------------------------------------------------------------------

        ; Turn off interrupts to stop LIBSCREEN_WAIT failing every so 
        ; often when the kernal interrupt syncs up with the scanline test
        sei

        ; Disable run/stop + restore keys
        lda #$FC 
        sta $0328

        ; Set border and background colors
        LIBSCREEN_SETCOLORS Blue, Black, Black, Black, Black

        ; Fill 1000 bytes (40x25) of Screen Memory
        LIBSCREEN_SET1000 SCREENRAM, SpaceCharacter

        ; Fill 1000 bytes (40x25) of color memory
        LIBSCREEN_SET1000 COLORRAM, White

        ; Set sprite colors
        LIBSPRITE_SETMULTICOLORS_VV Cyan, MediumGray

        ; Initialize Player
        jsr gamePlayerInit

;-------------------------------------------------------------------------------
; Main Game Loop
;-------------------------------------------------------------------------------

gameMainLoop
        ; Wait for scanline 255
        LIBSCREEN_WAIT_V 255

        ; Update the input library
        jsr libInputUpdate

        ; Update the player
        jsr gamePlayerUpdate

        ; Loop back to the start of the loop.
        jmp gameMainLoop