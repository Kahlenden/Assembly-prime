To compile the program:

```console
nasm -felf64 prime.s -o prime.o
gcc -g prime.o -o prime -no-pie
```
