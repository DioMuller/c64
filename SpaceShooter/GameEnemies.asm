;-------------------------------------------------------------------------------
; Constants
;-------------------------------------------------------------------------------

EnemiesMax = 7
EnemiesHorizontalSpeed = 1
EnemiesFireDelay = 90
EnemiesRespawnDelay = 255
EnemiesXMoveDelay = 20
EnemiesXMoveNumIndices = 100

;-------------------------------------------------------------------------------
; Variables
;-------------------------------------------------------------------------------

enemiesActiveArray       dcb EnemiesMax, 1
enemiesActive            byte   0
enemiesFrameArray        byte   4,   4,   4,   4,   3,   3,   3
enemiesFrame             byte   0
enemiesColorArray        byte   Red, Orange, Blue, Yellow, Red, Green, Blue
enemiesColor             byte   0
enemiesMultiColorArray   byte   True, True, True, True, True, True, True
enemiesMultiColor        byte   0
enemiesXHighArray        byte   0,   0,   0,   1,   0,   0,   0
enemiesXHigh             byte   0
enemiesXLowArray         byte  33, 113, 193,  18,  73, 153, 233
enemiesXLow              byte   0
enemiesYArray            byte  80,  80,  80,  80, 130, 130, 130
enemiesY                 byte   0
enemiesXLocalArray       byte   0,   0,   0,   0,   0,   0,   0
enemiesXLocal            byte   0
enemiesYLocalArray       byte   0,   0,   0,   0,   0,   0,   0
enemiesYLocal            byte   0
enemiesXCharArray        byte   0,   0,   0,   0,   0,   0,   0
enemiesXChar             byte   0
enemiesXOffsetArray      byte   0,   0,   0,   0,   0,   0,   0
enemiesXOffset           byte   0
enemiesYOffset           byte   0
enemiesYCharArray        byte   0,   0,   0,   0,   0,   0,   0
enemiesYChar             byte   0
enemiesFireArray         byte   0,  30,  60,  90, 120, 150, 180
enemiesFire              byte   0
enemiesRespawnArray      byte   0,   0,   0,   0,   0,   0,   0
enemiesRespawn           byte   0
enemiesTemp              byte   0
enemiesCollisionNo       byte   0
enemiesSprite            byte   0

enemiesXMoveIndexArray   byte   0,   5,  10,  15,  20,  25,  30
enemiesXMoveIndex        byte   0


                        ; right
enemiesXMoveArray        byte    0,  0,  1,  1,  1,  2,  2,  3,  4,  5
                        byte    6,  7,  8,  9, 10, 11, 12, 13, 14, 15
                        byte   16, 17, 18, 19, 20, 21, 22, 23, 24, 25
                        byte   26, 27, 28, 29, 30, 31, 32, 33, 34, 35
                        byte   36, 37, 38, 39, 39, 40, 40, 40, 41, 41

                        ; left
                        byte   41, 41, 40, 40, 40, 39, 39, 38, 37, 36
                        byte   35, 34, 33, 32, 31, 30, 29, 28, 27, 26
                        byte   25, 24, 23, 22, 21, 20, 19, 18, 17, 16 
                        byte   15, 14, 13, 12, 11, 10,  9,  8,  7,  6
                        byte    5,  4,  3,  2,  2,  1,  1,  1,  0,  0

;-------------------------------------------------------------------------------
; Macros/Subroutines
;-------------------------------------------------------------------------------

gameEnemiesInit

        ldx #0
        stx enemiesSprite
_initLoop
        inc enemiesSprite ; x+1
        
        jsr gameEnemiesGetVariables

        LIBSPRITE_ENABLE_AV             enemiesSprite, True
        LIBSPRITE_SETFRAME_AA           enemiesSprite, enemiesFrame
        LIBSPRITE_SETCOLOR_AA           enemiesSprite, enemiesColor
        LIBSPRITE_MULTICOLORENABLE_AA   enemiesSprite, enemiesMultiColor
    
        jsr gameEnemiesSetVariables
        
        ; loop for each alien
        inx
        cpx #EnemiesMax
        bne _initLoop
        
        rts

;-------------------------------------------------------------------------------
gameEnemiesUpdate

        ldx #0
        stx enemiesSprite

_updateLoop
        inc enemiesSprite ; x+1

        jsr gameEnemiesGetVariables

        lda enemiesActive 
        beq _skipThisAlien

        jsr gameEnemiesUpdatePosition
        jsr gameEnemiesUpdateFiring
        jsr gameEnemiesUpdateCollisions
        
        jmp _updated

_skipThisAlien
        jsr gameEnemiesUpdateInactive
_updated

        jsr gameEnemiesSetVariables

        ; loop for each alien
        inx
        cpx #EnemiesMax
        bne _updateLoop

        rts

;-------------------------------------------------------------------------------
gameEnemiesGetVariables
        lda enemiesActiveArray,X
        sta enemiesActive
        lda enemiesFrameArray,X
        sta enemiesFrame
        lda enemiesColorArray,X
        sta enemiesColor
        lda enemiesMultiColorArray,X
        sta enemiesMultiColor
        lda enemiesXHighArray,X
        sta enemiesXHigh
        lda enemiesXLowArray,X
        sta enemiesXLow
        lda enemiesYArray,X
        sta enemiesY
        lda enemiesXLocalArray,X
        sta enemiesXLocal
        lda enemiesYLocalArray,X
        sta enemiesYLocal
        lda enemiesFireArray,X
        sta enemiesFire
        lda enemiesRespawnArray,X
        sta enemiesRespawn
        lda enemiesXMoveIndexArray,X
        sta enemiesXMoveIndex
        
        stx enemiesTemp; save X register as it gets trashed

        rts

;-------------------------------------------------------------------------------
gameEnemiesUpdatePosition

        ldy enemiesXMoveIndex
        iny
        sty enemiesXMoveIndex        
        cpy #EnemiesXMoveNumIndices
        beq _resetIndex
        jmp _dontReset

_resetIndex
        lda #0
        sta enemiesXMoveIndex
        
_dontReset
        ldy enemiesXMoveIndex
        lda enemiesXMoveArray,Y
        sta enemiesXLocal

        LIBMATH_ADD16BIT_AAVAAA enemiesXHigh, enemiesXLow, 0, enemiesXLocal, enemiesXHigh, enemiesXLow        
        LIBSPRITE_SETPOSITION_AAAA enemiesSprite, enemiesXHigh, enemiesXLow, enemiesY

        ; update the alien char positions
        LIBSCREEN_PIXELTOCHAR_AAVAVAAAA enemiesXHigh, enemiesXLow, 12, enemiesY, 40, enemiesXChar, enemiesXOffset, enemiesYChar, enemiesYOffset
        rts

;-------------------------------------------------------------------------------
gameEnemiesUpdateFiring

        lda playerActive ; only fire if the player is alive
        beq _dontFire

        ldy enemiesFire
        iny
        sty enemiesFire        
        cpy #EnemiesFireDelay
        beq _fire
        jmp _dontFire
_fire
        GAMEBULLETS_FIRE_AAAVV enemiesXChar, enemiesXOffset, enemiesYChar, Yellow, False
        lda #0
        sta enemiesFire
_dontFire
        rts

;-------------------------------------------------------------------------------
gameEnemiesUpdateCollisions

        GAMEBULLETS_COLLIDED enemiesXChar, enemiesYChar, True
        beq _enemyNoCollision
        ; run explosion animation
        LIBSPRITE_PLAYANIM_AVVVV      enemiesSprite, 5, 15, 3, False
        LIBSPRITE_SETCOLOR_AV         enemiesSprite, Yellow
        LIBSPRITE_MULTICOLORENABLE_AV enemiesSprite, True

        ; play the explosion sound
        LIBSOUND_PLAY_VAA 1, soundExplosionHigh, soundExplosionLow

        lda #False
        sta enemiesActive
_enemyNoCollision
        rts

;-------------------------------------------------------------------------------
gameEnemiesSetVariables

        ldx enemiesTemp ; restore X register as it gets trashed

        lda enemiesXLocal
        sta enemiesXLocalArray,X
        lda enemiesYLocal
        sta enemiesYLocalArray,X
        lda enemiesActive
        sta enemiesActiveArray,X
        lda enemiesXChar
        sta enemiesXCharArray,X
        lda enemiesXOffset
        sta enemiesXOffsetArray,X
        lda enemiesYChar
        sta enemiesYCharArray,X
        lda enemiesFire
        sta enemiesFireArray,X
        lda enemiesRespawn
        sta enemiesRespawnArray,X
        lda enemiesXMoveIndex
        sta enemiesXMoveIndexArray,X

        rts

;-------------------------------------------------------------------------------
gameEnemiesUpdateInactive

        ldy enemiesRespawn
        iny
        sty enemiesRespawn
  
        cpy #EnemiesRespawnDelay
        beq _respawn
        jmp _dontRespawn
_respawn
        LIBSPRITE_ENABLE_AV             enemiesSprite, true
        LIBSPRITE_SETFRAME_AA           enemiesSprite, enemiesFrame
        LIBSPRITE_SETCOLOR_AA           enemiesSprite, enemiesColor
        LIBSPRITE_MULTICOLORENABLE_AA   enemiesSprite, enemiesMultiColor
      
        lda #0
        sta enemiesRespawn
        lda #True
        sta enemiesActive
_dontRespawn
        rts































