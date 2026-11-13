.export _soft_draw_tilemap
.importzp sp, tmp1, tmp2, ptr1, ptr2
.import incsp2, pushax
.import _tilemap, _ASSET__font__bios8_bmp_ptr


.segment	"DATA"

.proc	_soft_draw_tilemap: near

.segment	"DATA"
        php
        sei
	;;
	;; SETUP
	;;

        ldx #$00

LoopOverTiles:
        ;; Store tile starting index in ptr1
        ;; Low byte of the index is 8x the low nibble of the tile ix
        txa
        and #$0f
        asl a
        asl a
        asl a
        sta ptr1
        ;; High byte of the index is $40 more than 4x the high nibble of the tile ix
        ;; Because the high nibble is 16x we divide by 4 (by shifting right twice)
        txa
        and #$f0
        lsr a
        lsr a
        adc #$40
        sta ptr1+1


        ;; NOTE label currently unused
DrawTile:
        ldy #$00
        ;;  High byte of this address to be overwritten

        .repeat 4
        ;; TODO this should instead be setting ptr2 to tilemap as ptr1 is set above
        lda _tilemap, x
        sta (ptr1), y
        iny
        sta (ptr1), y
        iny
        sta (ptr1), y
        iny
        sta (ptr1), y
        iny
        sta (ptr1), y
        iny
        sta (ptr1), y
        iny
        sta (ptr1), y
        iny
        sta (ptr1), y

        ldy #$80

        sta (ptr1), y
        iny
        sta (ptr1), y
        iny
        sta (ptr1), y
        iny
        sta (ptr1), y
        iny
        sta (ptr1), y
        iny
        sta (ptr1), y
        iny
        sta (ptr1), y
        iny
        sta (ptr1), y

        ldy #$00

        lda ptr1+1
        inc a
        sta ptr1+1

        .endrepeat

        inx
        beq End
        jmp LoopOverTiles

End:
        plp
        rts
.endproc
