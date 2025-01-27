.data
    start: .long 0
    index_i: .space 4
    nr_operatii: .long 0
    cod_op: .space 4
    nr_fisiere: .space 4
    id: .space 4
    dim: .space 4
    contor: .long 0
    zeros: .long 0
    tmp_start: .space 4
    formatShow: .asciz "%d: (%d, %d)\n"
    formatGet: .asciz "(%d, %d)\n"
    formatNr: .asciz "%d"
    memory: .space 4097

.text
    Add:
        pushl %ebp 
        movl %esp, %ebp

        pushl $id
        pushl $formatNr
        call scanf
        addl $8, %esp

        pushl $dim
        pushl $formatNr
        call scanf
        addl $8, %esp

        movl dim, %eax
        addl $7, %eax
        shrl $3, %eax   ;//eax=nr of blocks
        movl %eax, %ecx

        leal memory, %edi
        movl $0, zeros
        xorl %esi, %esi

        Search4Gap:
            cmpl %esi, index_i ;//index_i este ultimul index ocupat in memory
            je SetStartEnd  ;//inseamna ca e primul fisier adaugat
                            ;//daca a mai existat inainte, incepe verificarea p-z de goluri
            cmpl $4096, %eax
            jge FailedAdd ;//am schimbat din NextValue in FailedAdd
 
        ZeroOrNot:
            cmpl $0, (%edi, %esi, 4) ;// compar memory[esi]==0
            je TempStart 

            cmpl $0, (%edi, %esi, 4) ;// compar memory[esi]==0
            jne NextValue

            incl %esi
            cmpl %esi, %eax ;//daca a ajuns la presupusul end, este ok, se poate intro in memo
            jle SetStartEnd
            jmp ZeroOrNot

        TempStart:
            movl %esi, tmp_start
            movl $0, zeros

        CountTheZeros:
            addl $1, zeros
            cmpl zeros, %eax
            jle SetNewStart

            incl %esi
            cmpl $0, (%edi, %esi, 4)
            je CountTheZeros
            jmp Search4Gap

        SetNewStart:
            movl tmp_start, %esi
            jmp SetStartEnd

        NextValue:
            incl %esi
            cmpl $1025, %esi
            je FailedAdd

            jmp Search4Gap
        
        SetStartEnd:
            movl %esi, start ;//am schimbat valorile intre ele si am comentat unde setez start-ul in Search4Gap
            movl %ecx, %eax
            addl start, %eax
            cmpl $1025, %eax
            jge FailedAdd

        CreateAdd:
            cmpl $0, %ecx ;//pana la urma treb sa consum un numar fix de blocuri
            je FixIndex

            movl id, %eax
            movl %eax, (%edi, %esi, 4) 
            incl %esi
            loop CreateAdd
        
        FixIndex:
            cmpl index_i, %esi
            jg LastIndex 

            decl %esi    ;//imi muta inapoi
            jmp OutputAdd

        LastIndex:  ;//doar dc se adauga liniar
            movl %esi, index_i ;//ultima valoare pe care s-a alocat+1 devine ultimul index al memoriei
            decl %esi

        OutputAdd:
            pushl %esi
            pushl start 
            pushl id 
            pushl $formatShow
            call printf
            addl $16, %esp
            pushl $0
            call fflush
            popl %ebx

            incl %esi ;//l-am readus pe prima poz goala
            jmp exitAdd
        
        FailedAdd:
            xorl %esi, %esi
            movl %esi, start
            jmp OutputAdd
        
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

        xorl %esi, %esi
        movl %esi, start ;//start=0
        movl id, %eax

        FirstValue:
            cmpl %eax, (%edi, %esi, 4)
            je FoundIt
            incl %esi
            cmpl index_i, %esi  ;//daca ajunge la ultima pozitie inseamna ca nu exista
            jge NonExisting
            jmp FirstValue

        FoundIt:
            movl %esi, start

        SearchingLoop:
            cmpl %eax, (%edi, %esi, 4)
            jne FixEnd
            incl %esi
            jmp SearchingLoop

        NonExisting:
            movl start, %esi
            jmp OutputGet

        FixEnd:
            decl %esi

        OutputGet:
            pushl %esi
            pushl start
            pushl $formatGet
            call printf
            addl $12, %esp
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

        xorl %esi, %esi ;//index incepe de la 0
        movl %esi, start ;//start=0(presupun initial)
        movl id, %eax

        SearchId:
            cmpl %eax, (%edi, %esi, 4)
            je FoundStart

            incl %esi
            cmpl $1025, %esi
            je IdNotFound
            jmp SearchId

        IdNotFound:
            jmp StartShow

        FoundStart:
            movl %esi, start
            movl %esi, %edx
            cmpl %edx, index_i ;//am adugat aceste doua linii ptc se intampla cv ciudat cand esi=247
            jle IdNotFound

        SearchEOF:
            cmpl %eax, (%edi, %edx, 4)
            jne FixEndId

            incl %edx
            cmpl $1025, %edx
            je EmptyMemo ;//poate am un fisier care ocupa toata memoria, asadar nu mai am nevoie de fix end id
            jmp SearchEOF

        FixEndId:
            decl %edx

        EmptyMemo:
            cmpl %edx, start    ;//sa verific daca merge de la edx la start sau de la edx la start+1!!!
            jg StartShow

            movl $0, (%edi, %edx, 4)
            decl %edx
            jmp EmptyMemo

        ;//acm trb sa afisez memoria modificata
        StartShow:
            xorl %esi, %esi
            movl %esi, start
            movl (%edi, %esi, 4), %eax
        
        CheckZero:
            cmpl $0, %eax
            je NextFile

        WhileSameId:
            cmpl %eax, (%edi, %esi, 4)
            jne OutputDelete

            incl %esi
            cmpl $1025, %esi
            je exitDelete
            jmp WhileSameId

        OutputDelete:
            decl %esi

            pushl %esi
            pushl start
            pushl %eax
            pushl $formatShow
            call printf
            addl $16, %esp
            pushl $0
            call fflush
            popl %ebx

        NextFile:
            incl %esi
            cmpl index_i, %esi
            jge exitDelete

            movl %esi, start
            movl (%edi, %esi, 4), %eax
            jmp CheckZero

        exitDelete:
            popl %ebp
            ret

    Defragmentation:
        pushl %ebp
        movl %esp, %ebp

        xorl %esi, %esi

        Search4Zero:
            cmpl $0, (%edi, %esi, 4)
            je LetsMoveIt

            incl %esi
            cmpl index_i, %esi
            je TheLastTouch
            jmp Search4Zero

        LetsMoveIt: ;//setez startul si un index pt prima lui poz goala
            movl %esi, %edx ;//edx va fi indexul pt pozitiile gole
                            ;//esi va fi pt poz pline
        SearchEnd:  ;//caut prima val nenula/ocupata
            cmpl $0, (%edi, %esi, 4)
            jne NonZeroId

            cmpl index_i, %esi
            je CheckIfItIsAnythingToShowOff

            incl %esi
            jmp SearchEnd

        NonZeroId: ;//cat timp nu da de valori dif de 0 sau de id
            cmpl $0, (%edi, %edx, 4)
            jne MoveTheIndex

            movl (%edi, %esi, 4), %eax  ;//mut val nenula in eax
            cmpl %eax, (%edi, %edx, 4) ;//compar val curenta cu cea a ultimei val stiute
            je MoveTheIndex

            movl %eax, (%edi, %edx, 4)  ;//mut eax in val nula
            movl $0, (%edi, %esi, 4)    ;//mut 0 in val initial nenula
            incl %esi
            incl %edx
            jmp NonZeroId
        MoveTheIndex:
            incl %esi
            cmpl $1025, %esi
            je TheLastTouch
            jmp NonZeroId

        CheckIfItIsAnythingToShowOff:
            xorl %esi, %esi
            cmpl $0, (%edi, %esi, 4)
            je exitDefragmentation
        ;//aici se intampla afisarea
        TheLastTouch:
            xorl %esi, %esi
            movl %esi, start
            movl (%edi, %esi, 4), %eax

        WhileSameValue:
            cmpl %eax, (%edi, %esi, 4)
            jne OutputDefragmentation

            incl %esi
            cmpl $1025, %esi
            je exitDefragmentation
            jmp WhileSameValue

        OutputDefragmentation:
            decl %esi

            pushl %esi
            pushl start
            pushl %eax
            pushl $formatShow
            call printf
            addl $16, %esp
            pushl $0
            call fflush
            popl %ebx

        NextId:
            incl %esi
            
            movl %esi, start
            movl (%edi, %esi, 4), %eax
            cmpl $1025, %esi
            jge exitDefragmentation
            cmpl $0, (%edi, %esi, 4)
            je exitDefragmentation
            jmp WhileSameValue

        exitDefragmentation:
            movl %esi, index_i ;//noul index final
            popl %ebp
            ret

.global main
main:
    movl $0, index_i
    pushl $nr_operatii
    pushl $formatNr
    call scanf
    addl $8, %esp

    xorl %esi, %esi ;// il iau pe esi ca index principal!!!
    movl $0, %ecx ;//folosesc ecx ca index principal

mainLoop:
    movl contor, %ecx
    cmpl nr_operatii, %ecx
    je exitTag ;//jge

    ;//citireCod:
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
    call Get
    jmp breakpoint

DeleteTag:
    pushl %edx
    call Delete
    popl %edx
    jmp breakpoint

DefragmentationTag:
    pushl %edx
    call Defragmentation
    popl %edx
    jmp breakpoint

exitTag:
    xorl %ebx, %ebx
    movl $1, %eax
    int $0x80