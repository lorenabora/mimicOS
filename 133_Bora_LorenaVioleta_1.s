.data
    index_c: .long 0
    index_l: .long 0
    start_l: .space 4
    start_c: .space 4
    last: .space 4
    contor: .long 0
    nr_operatii: .long 0
    cod_op: .space 4
    nr_fisiere: .space 4
    id: .space 4
    dim: .space 4
    zeros: .space 4
    length: .space 4
    tmp_start_c: .space 4
    tmp_start_l: .space 4
    formatShow: .asciz "%d: ((%d, %d), (%d, %d))\n"
    formatGet: .asciz "((%d, %d), (%d, %d))\n"
    formatNr: .asciz "%d"
    formatErr: .asciz "Linia: %d\n"
    memory: .space 4194304
.text
    Add:
        pushl %ebp
        movl %esp, %ebp

        pushl $id
        pushl $formatNr
        call scanf
        popl %ebx
        popl %ebx

        pushl $dim
        pushl $formatNr
        call scanf
        addl $8, %esp
        
        movl dim, %eax
        addl $7, %eax
        shrl $3, %eax   ;//eax=nr of blocks
        movl %eax, %ebx ;//saving ebx=blocks, i'll use eax in the matrix

        cmpl $1025, %ebx
        jge FailedAdd

        leal memory, %edi
        movl $0, zeros
        movl $0, index_l

        MoveOnTheLine:
            movl $0, index_c

        MoveOnTheColumn:
            movl index_c, %ecx
            cmpl $1024, %ecx
            je NextLinePls

            movl $1024, %esi    ;//=n
            movl index_l, %eax  ;//eax=index_linie(i)
            movl $0, %edx       ;//edx=0
            mull %esi           ;//eax= eax*n +edx <=> eax= i*n +0
            addl index_c, %eax  ;//eax= i*n + j(=index_coloana)

            cmpl $0, (%edi, %eax, 4)
            jne NextPosition
            je TmpStart
        
        NextPosition:
            addl $1, index_c
            movl index_c, %esi
            cmpl $1025, %esi
            je NextLinePls
            jmp MoveOnTheColumn

        TmpStart:
            movl index_l, %esi
            movl %esi, start_l
            movl index_c, %esi
            movl %esi, start_c
            movl $0, zeros

        CountTheZeros:
            addl $1, zeros
            cmpl zeros, %ebx
            jle SetNewIndex

            addl $1, index_c
            movl index_c, %esi
            cmpl $1024, %esi
            je NextLinePls

            movl $1024, %esi
            movl index_l, %eax
            movl $0, %edx
            mull %esi
            addl index_c, %eax
            cmpl $0, (%edi, %eax, 4)    
            je CountTheZeros
            jmp MoveOnTheColumn

        SetNewIndex:
            movl start_c, %esi
            movl %esi, index_c
            movl start_l, %esi
            movl %esi, index_l

        EnoughSpace:
            cmpl $0, %ebx
            je FixIndex

            movl $1024, %esi
            movl index_l, %eax
            xorl %edx, %edx
            mull %esi
            addl index_c, %eax

            movl id, %esi
            movl %esi, (%edi, %eax, 4)

            addl $1, index_c
            decl %ebx
            jmp EnoughSpace

        NextLinePls:
            addl $1, index_l
            movl index_l, %ecx
            cmpl $1024, %ecx
            je FailedAdd
            jmp MoveOnTheLine

        FailedAdd:
            xorl %esi, %esi
            movl %esi, index_c
            movl %esi, index_l
            movl %esi, start_c
            movl %esi, start_l
            jmp OutputAdd

        FixIndex:
            subl $1, index_c

        OutputAdd:
            pushl index_c
            pushl index_l
            pushl start_c
            pushl start_l
            pushl id
            pushl $formatShow
            call printf
            addl $24, %esp
            pushl $0
            call fflush
            popl %ebx

            movl $1, last

        exitAdd:
            popl %ebp
            ret

    Get:
        pushl %ebp
        movl %esp, %ebp

        pushl $id
        pushl $formatNr
        call scanf
        addl $8, %esp

        movl id, %ebx
        movl $0, index_l

        MoveOnTheLine2:
            movl $0, index_c

        MoveOnTheColumn2:
            movl index_c, %ecx
            cmpl $1024, %ecx
            je NextLine

            movl $1024, %esi    ;//=n
            movl index_l, %eax  ;//eax=index_linie(i)
            movl $0, %edx       ;//edx=0
            mull %esi           ;// eax= eax*n +edx <=> eax= i*n +0
            addl index_c, %eax  ;//eax= i*n + j(=index_coloana)

            cmpl %ebx, (%edi, %eax, 4)
            je StartPoint

            addl $1, index_c
            jmp MoveOnTheColumn2

        StartPoint:
            movl index_c, %esi
            movl %esi, start_c
            movl index_l, %esi
            movl %esi, start_l

        WhileSameId:
            cmpl %ebx, (%edi, %eax, 4)
            jne StopPoint

            addl $1, index_c
            movl $1024, %esi
            movl index_l, %eax
            xorl %edx, %edx
            mull %esi
            addl index_c, %eax

            jmp WhileSameId

        NextLine:
            addl $1, index_l
            movl index_l, %ecx
            cmpl $1024, %ecx
            je NotFound
            jmp MoveOnTheLine2

        NotFound:
            movl $0, start_c
            movl $0, start_l
            movl $0, index_c
            movl $0, index_l
            jmp OutputGet

        StopPoint:
            subl $1, index_c

        OutputGet:
            pushl index_c
            pushl index_l
            pushl start_c
            pushl start_l
            pushl $formatGet
            call printf
            addl $20, %esp
            pushl $0
            call fflush
            popl %ebx

        exitGet:
            popl %ebp
            ret
    Delete: 
        pushl %ebp
        movl %esp, %ebp

        pushl $id
        pushl $formatNr
        call scanf
        addl $8, %esp

        movl id, %ebx
        movl $0, index_l

        MoveOnTheLine3:
            movl $0, index_c

        MoveOnTheColumn3:
            movl index_c, %ecx
            cmpl $1024, %ecx
            je NextLine3
            
            movl $1024, %esi    ;//=n
            movl index_l, %eax  ;//eax=index_linie(i)
            movl $0, %edx       ;//edx=0
            mull %esi           ;// eax= eax*n +edx <=> eax= i*n +0
            addl index_c, %eax  ;//eax= i*n + j(=index_coloana)

            cmpl %ebx, (%edi, %eax, 4)
            je EraseLoop

            addl $1, index_c
            jmp MoveOnTheColumn3

        EraseLoop:
            cmpl %ebx, (%edi, %eax, 4)
            jne ShowTime

            movl $0, (%edi, %eax, 4)

            addl $1, index_c
            movl $1024, %esi
            movl index_l, %eax
            xorl %edx, %edx
            mull %esi
            addl index_c, %eax

            jmp EraseLoop

        NextLine3:
            addl $1, index_l
            movl index_l, %ecx
            cmpl $1024, %ecx
            je ShowTime
            jmp MoveOnTheLine3

        ShowTime:
            movl $0, index_l

        MovingLines:
            movl $0, index_c

        MovingColumns:
            movl index_c, %ecx
            cmpl $1024, %ecx
            jge NextMovingLine
            
            movl $1024, %esi    
            movl index_l, %eax  
            movl $0, %edx       
            mull %esi           
            addl index_c, %eax  

            cmpl $0, (%edi, %eax, 4)
            jne LetsGetThePartyStarted

            addl $1, index_c
            jmp MovingColumns

        NextMovingLine:
            addl $1, index_l
            movl index_l, %ecx
            cmpl $1024, %ecx
            je exitDelete
            jmp MovingLines

        LetsGetThePartyStarted:
            movl (%edi, %eax, 4), %ebx
            movl index_c, %esi
            movl %esi, start_c
            movl index_l, %esi
            movl %esi, start_l

        WhileSameValue:
            cmpl %ebx, (%edi, %eax, 4)
            jne OutputDelete 

            addl $1, index_c
            movl $1024, %esi
            movl index_l, %eax
            xorl %edx, %edx
            mull %esi
            addl index_c, %eax

            jmp WhileSameValue

        OutputDelete:
            subl $1, index_c
            pushl index_c
            pushl index_l
            pushl start_c
            pushl start_l
            pushl %ebx
            pushl $formatShow
            call printf
            addl $24, %esp
            pushl $0
            call fflush
            popl %ebx
            addl $1, index_c

            jmp MovingColumns

        exitDelete:
            popl %ebp
            ret
    Defragmentation:
        pushl %ebp
        movl %esp, %ebp

        movl last, %esi
        cmpl $0, %esi
        je exitDefragmentation

        xorl %ebx, %ebx
        movl $0, index_l

        MoveOnTheLine4:
            movl $0, index_c

        MoveOnTheColumn4:
            movl index_c, %ecx
            cmpl $1024, %ecx
            je NextLine4   

            movl $1024, %esi    
            movl index_l, %eax  
            movl $0, %edx       
            mull %esi           
            addl index_c, %eax  

            cmpl $0, (%edi, %eax, 4)
            je ZeroValue

            addl $1, index_c
            jmp MoveOnTheColumn4

        ZeroValue:
            movl index_c, %esi
            movl %esi, start_c
            movl index_l, %esi
            movl %esi, start_l

        UntilTheNextValue:
            addl $1, index_c
        breakpoint2:
            movl index_c, %esi
            cmpl $1024, %esi
            je MimicNextLine4

            movl $1024, %esi
            movl index_l, %eax
            xorl %edx, %edx
            mull %esi
            addl index_c, %eax

            cmpl $0, (%edi, %eax, 4)
            je UntilTheNextValue
            jmp NonZeroValue
                
        MimicNextLine4:
            addl $1, index_l
            movl index_l, %esi
            cmpl $1024, %esi
            je ShowTimeShowTime

            movl $0, index_c
            jmp breakpoint2

        NonZeroValue:
            movl $0, length 
            movl index_c, %esi
            movl %esi, tmp_start_c
            movl index_l, %esi
            movl %esi, tmp_start_l
            movl (%edi, %eax, 4), %ebx

        CountTheLength:
            addl $1, length

            addl $1, index_c
            movl index_c, %esi
            cmpl $1024, %esi
            je CompareTheLengths

            movl $1024, %esi
            movl index_l, %eax
            xorl %edx, %edx
            mull %esi
            addl index_c, %eax
            cmpl %ebx, (%edi, %eax, 4)
            je CountTheLength

        CompareTheLengths:
            movl $1024, %esi 
            subl start_c, %esi
            cmpl length, %esi ;// if 1024-start_c < lg_secventa, then I have memory allocation fail
            jl RemainUnchanged
            jmp ILikeToMoveItMoveIt

        RemainUnchanged:   
            addl $1, start_l
            movl $0, start_c
            movl start_l, %ecx
            cmpl tmp_start_l, %ecx
            je CheckTheColumn 
            jmp CompareTheLengths

        CheckTheColumn:
            movl start_c, %ecx
            cmpl tmp_start_c, %ecx
            je MoveOnTheColumn4

        ILikeToMoveItMoveIt:
            movl tmp_start_c, %esi
            movl %esi, index_c
            movl tmp_start_l, %esi
            movl %esi, index_l

        KeepOnMovin:
            movl length, %ecx
            cmpl $0, %ecx
            je FixIndexFFS

            movl $1024, %esi
            movl start_l, %eax
            xorl %edx, %edx
            mull %esi
            addl start_c, %eax
            movl %ebx, (%edi, %eax, 4)  ;// i move the non-zero value on the empty position

            movl $1024, %esi
            movl index_l, %eax
            xorl %edx, %edx
            mull %esi
            addl index_c, %eax
            movl $0, (%edi, %eax, 4)    ;// I moved the 0 on the pozition I took the non-zero value

            addl $1, index_c 
            addl $1, start_c 
            subl $1, length
            jmp KeepOnMovin

        FixIndexFFS:
            movl start_c, %esi
            movl %esi, index_c
            movl start_l, %esi
            movl %esi, index_l
            jmp MoveOnTheColumn4

        NextLine4:
            addl $1, index_l
            movl index_l, %ecx
            cmpl $1024, %ecx
            je ShowTimeShowTime
            jmp MoveOnTheLine4

        ShowTimeShowTime:
            movl $0, index_l

        MovingLines2:
            movl $0, index_c

        MovingColumns2:
            movl index_c, %ecx
            cmpl $1024, %ecx
            jge NextMovingLine2
            
            movl $1024, %esi    
            movl index_l, %eax  
            movl $0, %edx       
            mull %esi           
            addl index_c, %eax  

            cmpl $0, (%edi, %eax, 4)
            jne LetsGetThePartyStartedYeah

            addl $1, index_c
            jmp MovingColumns2

        NextMovingLine2:
            addl $1, index_l
            movl index_l, %ecx
            cmpl $1024, %ecx
            je exitDefragmentation
            jmp MovingLines2

        LetsGetThePartyStartedYeah:
            movl (%edi, %eax, 4), %ebx
            movl index_c, %esi
            movl %esi, start_c
            movl index_l, %esi
            movl %esi, start_l

        WhileSameValue2:
            cmpl %ebx, (%edi, %eax, 4)
            jne OutputDefragmentation 

            addl $1, index_c
            movl $1024, %esi
            movl index_l, %eax
            xorl %edx, %edx
            mull %esi
            addl index_c, %eax

            jmp WhileSameValue2

        OutputDefragmentation:
            subl $1, index_c
            pushl index_c
            pushl index_l
            pushl start_c
            pushl start_l
            pushl %ebx
            pushl $formatShow
            call printf
            addl $24, %esp
            pushl $0
            call fflush
            popl %ebx
            addl $1, index_c

            jmp MovingColumns2


        exitDefragmentation:
            popl %ebp
            ret

    Concrete:
        exitConcrete:
            ret

.global main
main:
    pushl $nr_operatii
    pushl $formatNr
    call scanf
    addl $8, %esp

    xorl %esi, %esi 
    movl $0, %ecx ;//ecx is the main index

mainLoop:
    movl contor, %ecx
    cmpl nr_operatii, %ecx
    je exitTag 

    pushl $cod_op
    pushl $formatNr
    call scanf
    addl $8, %esp

    cmpl $1, cod_op
    je AddTag

    cmpl $2, cod_op
    je GetTag

    cmpl $3, cod_op
    je DeleteTag

    cmpl $4, cod_op
    je DefragmentationTag

    cmpl $5, cod_op
    je ConcreteTag

breakpoint:
    addl $1, contor
    jmp mainLoop

AddTag:
    pushl $nr_fisiere
    pushl $formatNr
    call scanf
    addl $8, %esp

    movl nr_fisiere, %edx
    
AddLoop: 
    cmpl $0, %edx
    je breakpoint

    pushl %edx
    pushl %ecx
    pushl %ebx
    call Add
    popl %ebx
    popl %ecx
    popl %edx

    decl %edx
    jmp AddLoop

GetTag:
    pushl %ecx
    pushl %edx
    call Get
    popl %edx
    popl %ecx
    jmp breakpoint

DeleteTag:
    pushl %edx
    pushl %ecx
    call Delete
    popl %ecx
    popl %edx
    jmp breakpoint

DefragmentationTag:
    pushl %edx
    pushl %ecx
    call Defragmentation
    popl %ecx
    popl %edx
    jmp breakpoint

;// ConcreteTag:
;//     call Concrete
;//     jmp breakpoint

exitTag:
    xorl %ebx, %ebx
    movl $1, %eax
    int $0x80