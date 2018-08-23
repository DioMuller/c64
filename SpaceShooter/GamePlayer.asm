;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------

PlayerFrame             = 0     ; Player Sprite. 0-4
PlayerHorizontalSpeed   = 2
PlayerVerticalSpeed     = 1
PlayerXMinHigh          = 0     ; 0*256 + 24 = 24  minX
PlayerXMinLow           = 24
PlayerXMaxHigh          = 1     ; 1*256 + 64 = 320 maxX
PlayerXMaxLow           = 64
PlayerYMin              = 180
PlayerYMax              = 229 

PlayerStartXHigh        = 0
PlayerStartXLow         = 175
PlayerStartY            = 229

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
playerActive    byte True

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
; Update Player
gamePlayerUpdate
        lda playerActive
        beq _playerUpdateSkip

        jsr gamePlayerUpdatePosition
        jsr gamePlayerUpdateFiring
        jsr gamePlayerUpdateCollisions

_playerUpdateSkip
        lda playerActive
        bne _playerUpdateDontReset
        LIBSPRITE_ISANIMPLAYING_A playerSprite
        bne _playerUpdateDontReset
        jsr gamePlayerReset

_playerUpdateDontReset
        rts

;-------------------------------------------------------------------------------
; Update Player Shooting
gamePlayerUpdateFiring
        ; do fire after the ship has been clamped to position
        ; so that the bullet lines up
        LIBINPUT_GETFIREPRESSED
        bne _noFire  

        GAMEBULLETS_FIRE_AAAVV playerXChar, playerXOffset, playerYChar, White, True
        ; play the firing sound
        LIBSOUND_PLAY_VAA 0, soundFiringHigh, soundFiringLow

; No Firing
_noFire
        rts

;-------------------------------------------------------------------------------
; Update Player Position
gamePlayerUpdatePosition
        LIBINPUT_GETHELD GameportLeftMask
        bne _updateRight
        LIBMATH_SUB16BIT_AAVVAA playerXHigh, PlayerXLow, 0, PlayerHorizontalSpeed, playerXHigh, PlayerXLow
_updateRight
        LIBINPUT_GETHELD GameportRightMask
        bne _updateUp
        LIBMATH_ADD16BIT_AAVVAA playerXHigh, PlayerXLow, 0, PlayerHorizontalSpeed, playerXHigh, PlayerXLow
_updateUp
        LIBINPUT_GETHELD GameportUpMask
        bne _updateDown
        LIBMATH_SUB8BIT_AVA PlayerY, PlayerVerticalSpeed, PlayerY
_updateDown
        LIBINPUT_GETHELD GameportDownMask
        bne _endMove
        LIBMATH_ADD8BIT_AVA PlayerY, PlayerVerticalSpeed, PlayerY        
_endMove

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

;-------------------------------------------------------------------------------
; Update Player Collisions
gamePlayerUpdateCollisions
        GAMEBULLETS_COLLIDED playerXChar, playerYChar, False
        beq _playerNoCollision
        lda #False
        sta playerActive

        ; run explosion animation
        LIBSPRITE_SETCOLOR_AV     playerSprite, Yellow
        LIBSPRITE_PLAYANIM_AVVVV  playerSprite, 5, 15, 3, False

        ; play the explosion sound
        LIBSOUND_PLAY_VAA 1, soundExplosionHigh, soundExplosionLow
                    
_playerNoCollision
        rts

;-------------------------------------------------------------------------------
; Player Reset
gamePlayerReset

        lda #True
        sta playerActive

        LIBSPRITE_ENABLE_AV             playerSprite, True
        LIBSPRITE_SETFRAME_AV           playerSprite, PlayerFrame
        LIBSPRITE_SETCOLOR_AV           playerSprite, LightGray
        
        lda #PlayerStartXHigh
        sta playerXHigh
        lda #PlayerStartXLow
        sta PlayerXLow
        lda #PlayerStartY
        sta PlayerY
        LIBSPRITE_SETPOSITION_AAAA playerSprite, playerXHigh, playerXLow, playerY
        
        rts