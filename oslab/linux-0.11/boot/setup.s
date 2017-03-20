!
!    setup.s        (C) 1991 Linus Torvalds
!
! setup.s is responsible for getting the system data from the BIOS,
! and putting them into the appropriate places in system memory.
! both setup.s and system has been loaded by the bootblock.
!
! This code asks the bios for memory/disk/other parameters, and
! puts them in a "safe" place: 0x90000-0x901FF, ie where the
! boot-block used to be. It is then up to the protected mode
! system to read them from there before the area is overwritten
! for buffer-blocks.
!

! NOTE! These had better be the same as in bootsect.s!

INITSEG  = 0x9000    ! we move boot here - out of the way
SYSSEG   = 0x1000    ! system loaded at 0x10000 (65536).
SETUPSEG = 0x9020    ! this is the current segment

.globl begtext, begdata, begbss, endtext, enddata, endbss
.text
begtext:
.data
begdata:
.bss
begbss:
.text

entry start
start:
    mov    ax,cs
    mov    ds,ax
    mov    es,ax
! Print some inane message

    mov    ah,#0x03        ! read cursor pos
    xor    bh,bh
    int    0x10

    mov    cx,#25
    mov    bx,#0x0007        ! page 0, attribute 7 (normal)
    mov    bp,#msg1
    mov    ax,#0x1301        ! write string, move cursor
    int    0x10

! ok, we've written the message, now


! ok, the read went well so we get current cursor position and save it for
! posterity.

    mov    ax,#INITSEG    ! this is done in bootsect already, but...
    mov    ds,ax
    mov    ah,#0x03    ! read cursor pos
    xor    bh,bh
    int    0x10        ! save it in known place, con_init fetches
    mov    [0],dx        ! it from 0x90000.

    mov    ax,cs
    mov    ds,ax
    mov    es,ax
! Print some inane message

    mov    ah,#0x03        ! read cursor pos
    xor    bh,bh
    int    0x10

    mov    cx,#13
    mov    bx,#0x0007        ! page 0, attribute 7 (normal)
    mov    bp,#cursor1
    mov    ax,#0x1301        ! write string, move cursor
    int    0x10
    mov ax,#INITSEG
    mov ds,ax
    push [0]
    call print_hex
    pop [0]
    call print_nl
! ok, we've written the message, now


! Get memory size (extended mem, kB)

    mov    ah,#0x88
    int    0x15
    mov    [2],ax

    mov    ax,cs
    mov    ds,ax
    mov    es,ax
! Print some inane message

    mov    ah,#0x03        ! read cursor pos
    xor    bh,bh
    int    0x10

    mov    cx,#14
    mov    bx,#0x0007        ! page 0, attribute 7 (normal)
    mov    bp,#memory1
    mov    ax,#0x1301        ! write string, move cursor
    int    0x10
    mov ax,#INITSEG
    mov ds,ax
    push [2]
    call print_hex
    pop [2]
    call print_nl
! ok, we've written the message, now

! Get hd0 data

    mov    ax,#0x0000
    mov    ds,ax
    lds    si,[4*0x41]
    mov    ax,#INITSEG
    mov    es,ax
    mov    di,#0x0004
    mov    cx,#0x10
    rep
    movsb

    mov    ax,cs
    mov    ds,ax
    mov    es,ax
! Print some inane message

    mov    ah,#0x03        ! read cursor pos
    xor    bh,bh
    int    0x10

    mov    cx,#7
    mov    bx,#0x0007        ! page 0, attribute 7 (normal)
    mov    bp,#cyls1
    mov    ax,#0x1301        ! write string, move cursor
    int    0x10
    mov ax,#INITSEG
    mov ds,ax
    push [4]
    call print_hex
    pop [4]
    call print_nl
! ok, we've written the message, now
    mov    ax,cs
    mov    ds,ax
    mov    es,ax
! Print some inane message

    mov    ah,#0x03        ! read cursor pos
    xor    bh,bh
    int    0x10

    mov    cx,#8
    mov    bx,#0x0007        ! page 0, attribute 7 (normal)
    mov    bp,#heads1
    mov    ax,#0x1301        ! write string, move cursor
    int    0x10
    mov ax,#INITSEG
    mov ds,ax
    push [6]
    call print_hex
    pop [6]
    call print_nl
! ok, we've written the message, now
    mov    ax,cs
    mov    ds,ax
    mov    es,ax
! Print some inane message

    mov    ah,#0x03        ! read cursor pos
    xor    bh,bh
    int    0x10

    mov    cx,#10
    mov    bx,#0x0007        ! page 0, attribute 7 (normal)
    mov    bp,#sectors1
    mov    ax,#0x1301        ! write string, move cursor
    int    0x10
    mov ax,#INITSEG
    mov ds,ax
    push [8]
    call print_hex
    pop [8]
    call print_nl
! ok, we've written the message, now





gdt:
    .word    0,0,0,0        ! dummy

    .word    0x07FF        ! 8Mb - limit=2047 (2048*4096=8Mb)
    .word    0x0000        ! base address=0
    .word    0x9A00        ! code read/exec
    .word    0x00C0        ! granularity=4096, 386

    .word    0x07FF        ! 8Mb - limit=2047 (2048*4096=8Mb)
    .word    0x0000        ! base address=0
    .word    0x9200        ! data read/write
    .word    0x00C0        ! granularity=4096, 386

idt_48:
    .word    0            ! idt limit=0
    .word    0,0            ! idt base=0L

gdt_48:
    .word    0x800        ! gdt limit=2048, 256 GDT entries
    .word    512+gdt,0x9    ! gdt base = 0X9xxxx

msg1:
    .byte 13,10
    .ascii "Now we are in setup"
    .byte 13,10,13,10

cursor1:
    .byte 13,10
    .ascii "Cursor Pos:"

memory1:
    .byte 13,10
    .ascii "Memory Size:"

cyls1:
    .byte 13,10
    .ascii "Cyls:"

heads1:
    .byte 13,10
    .ascii "Heads:"

sectors1:
    .byte 13,10
    .ascii "Sectors:"
print_hex:
    push bp
    mov bp,sp
    mov    cx,#4        
    mov    dx,(bp+4)     
    print_digit:
    rol    dx,#4        
    mov    ax,#0xe0f     
    and    al,dl     
    add    al,#0x30    
    cmp    al,#0x3a
    jl    outp       
    add    al,#0x07     
outp: 
    int    0x10
    loop    print_digit
    pop bp
    ret

print_nl:
    mov    ax,#0xe0d     ! CR
    int    0x10
    mov    al,#0xa     ! LF
    int    0x10
    ret


.text
endtext:
.data
enddata:
.bss
endbss:
