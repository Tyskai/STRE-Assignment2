## STRE Assignment 2
# American Fuzzy Lop (AFL)

Download and install AFL (on Linux):

http://lcamtuf.coredump.cx/afl/

# KLEE

Download and install KLEE: 

https://klee.github.io/

This can be quite troublesome from scratch. The easiest way to install is via Docker:

https://www.docker.com/

Docker is a container, you can think of it as a small virtual machine. Use any of the standard isntallers for docker, then run:

```
docker pull klee/klee
```

to get KLEE, and run:

```
docker run --rm -ti --ulimit='stack=-1:-1' klee/klee
```

to start a small VM containing KLEE, more details can be found at: http://klee.github.io/docker/. Run

```
exit
```

to exit. Another important command is to make Docker mount a local directory:

```
sudo docker run -v [PATH IN THE HOST MACHINE]:[PATH IN THE CONTAINER] -ti --name=[NAME OF THE CONTAINER] --ulimit='stack=-1:-1' klee/klee
```

which will load the host path and a path in the Docker container. I simply give it my home_dir:

```
sudo docker run -v /Users/sicco/:/home/klee/sicco -ti --name=dock_klee --ulimit='stack=-1:-1' klee/klee
```

You can remove an old contained using rm:

```
docker rm dock_klee
```
