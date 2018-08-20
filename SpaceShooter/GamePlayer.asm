;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------

PlayerFrame             = 1
PlayerHorizontalSpeed   = 2
PlayerVerticalSpeed     = 1
PlayerXMinHigh          = 0     ; 0*256 + 24 = 24  minX
PlayerXMinLow           = 24
PlayerXMaxHigh          = 1     ; 1*256 + 64 = 320 maxX
PlayerXMaxLow           = 64
PlayerYMin              = 180
PlayerYMax              = 229 

;-------------------------------------------------------------------------------
; Variables
;-------------------------------------------------------------------------------
playerSprite    byte 0
playerXHigh     byte 0
playerXLow      byte 175
playerY         byte 229
playerXChar     byte 0
playerXOffset   byte 0
playerYChar     byte 0
playerYOffset   byte 0

;-------------------------------------------------------------------------------
; Subroutines
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Initialize Player values
gamePlayerInit
        LIBSPRITE_ENABLE_AV             playerSprite, True
        LIBSPRITE_SETFRAME_AV           playerSprite, PlayerFrame
        LIBSPRITE_SETCOLOR_AV           playerSprite, LightGray
        LIBSPRITE_MULTICOLORENABLE_AV   playerSprite, True

        rts

;-------------------------------------------------------------------------------
; Update Player values

; Update Player
gamePlayerUpdate
        jsr gamePlayerUpdatePosition
        jsr gamePlayerUpdateFiring

        rts

; Update Player Shooting
gamePlayerUpdateFiring

        ; do fire after the ship has been clamped to position
        ; so that the bullet lines up
        LIBINPUT_GETFIREPRESSED
        bne gamePlayerUpdateNoFire
     
        GAMEBULLETS_FIRE_AAAVV playerXChar, playerXOffset, playerYChar, White, True
gamePlayerUpdateNoFire
        rts

; Update Player Position
gamePlayerUpdatePosition
        LIBINPUT_GETHELD GameportLeftMask
        bne gamePlayerUpdateRight
        LIBMATH_SUB16BIT_AAVVAA playerXHigh, PlayerXLow, 0, PlayerHorizontalSpeed, playerXHigh, PlayerXLow
gamePlayerUpdateRight
        LIBINPUT_GETHELD GameportRightMask
        bne gamePlayerUpdateUp
        LIBMATH_ADD16BIT_AAVVAA playerXHigh, PlayerXLow, 0, PlayerHorizontalSpeed, playerXHigh, PlayerXLow
gamePlayerUpdateUp
        LIBINPUT_GETHELD GameportUpMask
        bne gamePlayerUpdateDown
        LIBMATH_SUB8BIT_AVA PlayerY, PlayerVerticalSpeed, PlayerY
gamePlayerUpdateDown
        LIBINPUT_GETHELD GameportDownMask
        bne gamePlayerUpdateRightEndMove
        LIBMATH_ADD8BIT_AVA PlayerY, PlayerVerticalSpeed, PlayerY        
gamePlayerUpdateRightEndMove

        ; clamp the player x position
        LIBMATH_MIN16BIT_AAVV playerXHigh, playerXLow, PlayerXMaxHigh, PlayerXMaxLow
        LIBMATH_MAX16BIT_AAVV playerXHigh, playerXLow, PlayerXMinHigh, PlayerXMinLow
        
        ; clamp the player y position
        LIBMATH_MIN8BIT_AV playerY, PlayerYMax
        LIBMATH_MAX8BIT_AV playerY, PlayerYMin

        ; set the sprite position
        LIBSPRITE_SETPOSITION_AAAA playerSprite, playerXHigh, playerXLow, playerY

        ; update the player char positions
        LIBSCREEN_PIXELTOCHAR_AAVAVAAAA playerXHigh, playerXLow, 12, playerY, 40, playerXChar, playerXOffset, playerYChar, playerYOffset


        rts