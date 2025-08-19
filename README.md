# mimicOS
mimicOS is a simulated file system written in x86 Assembly, designed to handle file operations on both linear and bidimensional memory layouts.

## What is this about?
This project is a file system( encoded) that uses 4 opperations: ADD, GET, DELETE and DEFRAGMENTATION; on two cases, on a linear memory of maximum 4 GB and a bidimentional memory 4x4 GB. 

The rules are the following:
1. Each file will be represented by an unique id (it was guaranteed that the ids will be unique in the test cases) and the memory that will be used in storing the file in kB (for a better understanding, a block of memory will take 8 kB).
2. For the ADD operation ( encoded: 1) you need to create a file. The purpose is to add files in such a manner that the memory will be used at maximum ( e.g. if after a deletion there will be enough space to add a new file, you need to take that into consideration). Attention for the bidimensional case: a file needs to be saved in memory on a single line! ( e.g. if you are on the last 2 available blocks of memory on the nth line and the file is larger that 16 kB, you need to save the fyle in the n+1 line of the memory. NO SLICING!)
3. For the GET operation ( encoded: 2), the user needs to write the id of the file that they are searching for and in the terminal it will be shown the file( in the format id: (starting_block_of_memory, ending_block_of_memory)) or nothing if the file is not found.
4. For the DELETE operation ( encoded: 3), the user writes the id of the file that they want to be gone and the file system will erase that file from the memory, without modifying anything except that specific file, then will display the rest of the files that remain using the same format as for the GET operation.
5. DEFRAGMENTATION ( encoded: 4) is the operation that makes sure no more "spaces" in memory are left behind. For the linear case it is simple, you need to shift left all the blocks that are used, but for the bidimentional case it is tricky because you need to make sure that you don't slice accidently a file in the memory.

## Features
- Copy basic operations that a file system would do, but encoded

## Tech Stack/ Language used
- Assembly x86

## How to use it
Personally, I used WSL becuse I am more confortable with the Linux terminal commands, so I suggest working on a Linux distribution/ Virtual Machine or WSL.
- Step 1: download the code from the repo
- Step 2: be sure that the program compiles without errors/ create the executable. I used the following command: 
`gcc -m32 133_Bora_LorenaVioleta_x.s -o name_of_executable`
- Step 3: run using `./name_of_executable` and have fun testing the operations.

## Lessons learnt
1. Using gdb/ pwndbg for seing how the program works and how to fix the bugs/ segfault (a nightmare for the bidimentional case at defragmentation. Worth it!)
2. Working with a low-level programming language
3. Reverse engineering looking for solutions on how to make this work

