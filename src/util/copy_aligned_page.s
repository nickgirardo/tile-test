.export _copy_aligned_page
.import popax

.segment	"DATA"
.proc	_copy_aligned_page: near
        stx SrcPtr1+2
        stx SrcPtr2+2
        stx SrcPtr3+2
        stx SrcPtr4+2
        stx SrcPtr5+2
        stx SrcPtr6+2
        stx SrcPtr7+2
        stx SrcPtr8+2

        jsr popax
        stx  DestPtr1+2
        stx  DestPtr2+2
        stx  DestPtr3+2
        stx  DestPtr4+2
        stx  DestPtr5+2
        stx  DestPtr6+2
        stx  DestPtr7+2
        stx  DestPtr8+2

        ldy #$1f
CopyLoop:
SrcPtr1:
        lda $0000, y
DestPtr1:
        sta $0000, y

SrcPtr2:
        lda $0020, y
DestPtr2:
        sta $0020, y

SrcPtr3:
        lda $0040, y
DestPtr3:
        sta $0040, y

SrcPtr4:
        lda $0060, y
DestPtr4:
        sta $0060, y

SrcPtr5:
        lda $0080, y
DestPtr5:
        sta $0080, y

SrcPtr6:
        lda $00a0, y
DestPtr6:
        sta $00a0, y

SrcPtr7:
        lda $00c0, y
DestPtr7:
        sta $00c0, y

SrcPtr8:
        lda $00e0, y
DestPtr8:
        sta $00e0, y

        dey
        bpl CopyLoop

        rts
.endproc
