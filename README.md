# STRE Assignment 2

In this file we explained how we set up AFL and KLEE. Then how we worked with the given code to find crashes, so you are able to reproduce the hole thing yourself. We worked on Linux machines, the tools work best (only) on Linux machines.

### Instal Ubuntu VM
Use a VM (Virtual Machine) if you do not run Linux on your computer, so you can install and use the tools. Download VirtualBox https://www.virtualbox.org/, install it, download Ubuntu https://www.ubuntu.com/ and create a Ubuntu VM.

## Setting up - American Fuzzy Lop (AFL)

Download and install AFL:

http://lcamtuf.coredump.cx/afl/

## Setting up - KLEE

Download and install KLEE: 

https://klee.github.io/

The easiest way to install KLEE is via Docker:

https://www.docker.com/

Docker is a container, you can think of it as a small virtual machine. Use any of the standard isntallers for docker, then run:

```
docker pull klee/klee
```

to get KLEE, and run:

```
docker run --rm -ti --ulimit='stack=-1:-1' klee/klee
```

to start a small VM containing KLEE, more details can be found at: http://klee.github.io/docker/. 

Run

```
exit
```

to exit. To make Docker mount a local directory run:

```
sudo docker run -v [PATH IN THE HOST MACHINE]:[PATH IN THE CONTAINER] -ti --name=[NAME OF THE CONTAINER] --ulimit='stack=-1:-1' klee/klee
```

which will load the host path and a path in the Docker container. To simply give it the home_dir:

```
sudo docker run -v /Users/user_name/:/home/klee/user_name -ti --name=dock_klee --ulimit='stack=-1:-1' klee/klee
```

You can remove an old contained using rm:

```
docker rm dock_klee
```

## Running - AFL

To compile the program using the afl-gcc compiler type:

```
path_to_afl/afl-gcc example.c
```

In our video example.c is a.c for the first program and gawk.c for the second one.

and then run AFL on the obtained binairy with:

```
path_to_afl/afl-fuzz -i path_to_input_dir -o path_to_output_dir path_to_binary/a.out
```

## Running - KLEE
