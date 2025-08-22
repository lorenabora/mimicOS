# mimicOS
mimicOS is a simulated file system written in x86 Assembly, designed to handle file operations on both linear and bidimensional memory layouts.

## What is this about?
This project is a file system( encoded) that uses 4 operations: ADD, GET, DELETE and DEFRAGMENTATION; on two cases, on a linear memory of maximum 4 GB and a bidimensional memory 4x4 GB. 

### The rules are the following:
1. Each file will be represented by a unique id (it was guaranteed that the ids will be unique in the test cases) and the memory that will be used in storing the file in kB (for a better understanding, a block of memory will take 8 kB).
2. For the ADD operation ( encoded: 1) you need to create a file. The purpose is to add files in such a manner that the memory will be used at maximum ( e.g. if after a deletion there will be enough space to add a new file, you need to take that into consideration). Attention for the bidimensional case: a file needs to be saved in memory on a single line! ( e.g. if you are on the last 2 available blocks of memory on the nth line and the file is larger that 16 kB, you need to save the fyle in the n+1 line of the memory. NO SLICING!)
3. For the GET operation ( encoded: 2), the user needs to write the id of the file that they are searching for and in the terminal it will be shown the file( in the format id: (starting_block_of_memory, ending_block_of_memory)) or nothing if the file is not found.
4. For the DELETE operation ( encoded: 3), the user writes the id of the file that they want to be gone and the file system will erase that file from the memory, without modifying anything except that specific file, then will display the rest of the files that remain using the same format as for the GET operation.
5. DEFRAGMENTATION ( encoded: 4) is the operation that makes sure no more "spaces" in memory are left behind. For the linear case it is simple, you need to shift left all the blocks that are used, but for the bidimentional case it is tricky because you need to make sure that you don't slice accidentaly a file in the memory.

### Demo input and output
1 101 24   ; ADD file with ID 101 and size 24 kB 

2 101      ; GET file with ID 101

101:( 0, 2)  ; OUTPUT after GET-> because we have 24 kB for the file and a block is 8 kB, then we need to save in memory

             ; the file using 3 blocks, being the first file, the place is between the block indexed with 0 and the one               
             ; indexed with 2

2 7        ; we want to GET the file with the ID 7 => no output, the file is not saved in the memory

1 10 34    ; ADD file with ID 10 and size 34 

3 101      ; DELETE file 101

10:(3, 7)  ; OUTPUT after DELETE operation 

; for a better understanding here is an ASCII diagram after deletion:

; [0][0][0][10][10][10][10][10][0]---

4          ; DEFRAGMENTATION

10:(0, 4)  ; OUTPUT after DEFRAGMENTATION

; the memory will look like:

; [10][10][10][10][10][0][0][0]---

### A visual representation for the bidimensional case:
- Let's say that we got a full line (4 GB) memory full and the last ID is 121 and we have only 3 blocks free on this line. We want to add the file with the ID 200 with the size 49 kB.
- Knowing the rules, the memory will look something like this:

; Line 1

[1][1][1][1] ... [121][121][121][0][0][0]

; Line 2

[200][200][200][200][200][200][0][0] ...


## Features
- Copy basic operations that a file system would do, but encoded

## Tech Stack/ Language used
- Assembly x86

## How to use it
Personally, I used WSL becuse I am more confortable with the Linux terminal commands, so I suggest working on a Linux distribution/ Virtual Machine or WSL.

Before, make sure that you have intalled the multilib to unlock the gcc command.

- Step 1: download the code from the repo or clone it
- Step 2: be sure that the program compiles without errors/ create the executable. I used the following command: 
`gcc -m32 133_Bora_LorenaVioleta_x.s -o name_of_executable`
- Step 3: run using `./name_of_executable` and have fun testing the operations.

## Lessons learnt
1. Using gdb/ pwndbg for seing how the program works and how to fix the bugs/ segfault (a nightmare for the bidimentional case at defragmentation. Worth it!)
2. Working with a low-level programming language
3. Reverse engineering looking for solutions on how to make this work

## Challenges
- At first, getting used to the low-level language. Without loop and conditions in other languages, here, I needed to use tags and jump commands to get the desired operations.
- After I got a sense of how things work and my mind started to shift in that direction, the code was easier to write, but a headache to debug, expecially on the bidimensional case at defragmentation. I used pwndbg to see the registers with ease, but the logic behind the first draft was bugged and I needed to see where the logic from the paper went wrong in the functional code from vs code.
- Shifting the registers on the stack was like the ace in my hand, making things easier when I wanted to call a variable
- The variables were my saviors when I needed to empty some registers to reuse them in other parts of the code without losing essential data.
