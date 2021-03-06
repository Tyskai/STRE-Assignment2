### Made by Côme du Crest, Ines Duits and Rashid Zamani. Testing group 9.

# STRE Assignment 2

In this file we explain how to install the required tools we worked with for this assignment. There are clear instructions on how to create and setup the environment, so you are able to reproduce everything yourself. This is an instruction on how to setup the experiment and interpret the result. Explanation on the causes of the crashes and corresponding fixes are explained in the video. 

## 1. Requirements
* GNU/Linux
    * We have used this operation system to conduct our experiment. In order to set up the testing environment, a Linux machine is needed.
* KLEE over Docker
    * Installation of docker is explained in the following subsection.

#### 1.1 Installing KLEE over Docker

Docker is a container, you can think of it as a small virtual machine. Download and install Docker for your operation system from: https://www.docker.com/

Once you install docker, run the following command to fetch the an Ubuntu image with KLEE installed on it:
```
docker pull klee/klee
```

More details can be found at: http://klee.github.io/docker/. 

## 2. Setting up the environment
We have analyzed two projects for this assignment, namely: _Gawk_ and a project we did for our _Cryptography Assignment_. Clone the repository. In STRE_2nd folder, provide the required privileges to `setup.sh` and run the script:
```
chmod 755 setup.sh; ./setup.sh
```
`setup.sh` will extract all the files, builds AFL, and then compiles both projects we used for this assignment with `afl-gcc` and the regular compiler. We use the binary generated by AFL compiler to fuzz and the binary compiled by `gcc` to debug with `gdb`, since we wanted to avoid stepping in to all the instrumented code AFL compiler injects into the binary. Thus for each project there are two binaries with either `_gcc` or `_afl` suffix to differentiate the two. It should be noted that the setup script will build `_afl` binaries with `AFL_HARDEN` enabled.

### 2.1 Cryptography Assignment
This program is a substitutional ciphering machine that uses a hard coded substitution table to encrypt and decrypt text file and show them on the command line.
```
USAGE: -d file.txt TO DECRYPT OR -e file.txt TO ENCRYPT.
```
We performed both concolic execution and fuzzing on this project with KLEE and AFL. Once you setup the environment, change directory to folder __"a"__. Following table demonstrates the foldering structure in this project.

File/Folder Name | Description
------------ | -------------
a.c| _original_ source code
a_fixed.c| _fixed_ source code based on AFL's findings
a_klee.c| _modified_ source code for KLEE
a_klee_fixed_*.c|_fixed_ source codes based on KLEE's findings
findings| directory containing outputs of both AFL and KLEE
input_dec| input directory for decryption
input_enc|input directory for encryption

__2.1.1. Fuzz Testing__
We fuzzed both encryption and decryption functionality of the program with AFL by the below commands. The result could be found in `findings/output_dec/` and `findings/output_enc/`. 
```
afl-fuzz -i input_dec/ -o output_dec/ ./a_afl -d @@
afl-fuzz -i input_enc/ -o output_enc/ ./a_afl -e @@
```
Provide the required privileges to `afl_replay.sh` and run the script with the name of the binary, to test the binary against the input that caused the crash. The script will run the binary with both encryption and decryption inputs which AFL discovered that caused crash. The script will count the success or failure of each input and provides the total result. While `a_gcc` crashes with all 47 inputs, `a_fixed_gcc` does not crash at all.
```
./afl_replay.sh a_fixed_gcc
```
__2.1.2 Concolic Execution__
Run `start_klee.sh` to start the image containing KLEE. This script mounts folder __"a"__ into docker running KLEE at `~/a`. Hereafter, you need to enter all the instruction in the docker image. Change the directory to `~/a`. There is a script called `setup_klee.sh`. This script will setup everything needed for KLEE to start. In other words, this scripts provides the byte code for KLEE to start the procedure of concolic execution. It should be noted, source codes used for KLEE are different. For more explanation please refer to the video. 
You analyze the byte codes with following command and substitute `a_klee_fixed_2.bc` with the desired one:
```
klee a_klee_fixed_2.bc
```
Once you run KLEE, it will generate some test cases. The test cases generated through our experiment could be found in findings folder. `klee_show_test.sh` script will print out all the test cases generated by KLEE. Provide the path to the KLEE output to this script like below.
```
./klee_show_test.sh findings/klee-out-6/
```
Once we observed the test cases and understood the causes for the crash, we had two attempts to successfully fix the problem. Please refer to the table above to find the corresponding files. After modifying the source code, we ran the tests against the modified version to confirm the fix. In order to do so, you need to build the source code with KLEE libraries. You can use `klee_build.sh` script to build the source code. KLEE docker image does not have `gcc` installed by default -- it could be installed as follow (the password is `klee`):
```
sudo apt-get install gcc
```
After using the scripts to build the code, the scripts will generate the binary with the same name of the source code with `.bin` suffix to the file. You need to set `KTEST_FILE` environment variable to the path of the `ktest` file, then run the binary and check the return code with `echo $?` command. Return code `0` shows normal exit, and others shows unexpected exit (crash) of the program. Below we you can see the steps to build the last fix source code and test the test case against it. You can substitute the source code or test case with other files.
```
./klee_build.sh a_klee_fixed_2.c
export LD_LIBRARY_PATH=/home/klee/klee_build/klee/lib/:$LD_LIBRARY_PATH
export KTEST_FILE=findings/klee-out-5/test000001.ktest
./a_klee_fixed_2.c.bin
echo $?
```
### 2.2 Gawk 4.1.4
We fuzzed Gawk with below command using AFL. Both input we provided to fuzzer and output generated by AFL could be found in this project under `findings` folder.
```
afl-fuzz -i input/ -o output/ -m none -t 1000+ ./gawk_afl -f @@
```
`-m` flags remove the restriction on memory usage and `-t` will give longer timeout for each run. We used these flags since our input where bigger and we wanted to give the fuzzer proper resource to analyze the project. We have another `afl_replay.sh` script in the Gawk folder which you could use to test the crashes against the binary. The script will feed each input to the binary and provides a total results showing sum of failures and successes.
```
./afl_replay ./gawk_gcc
```
The script shows the binary fails for all the input. The reason for the crash and the fix are expalined in the video. We have provided a patch for the crash -- `array.patch`. Use the below command in `Gawk-4.1.4` folder to patch the file and fix the issue.
```
patch < array.patch
make
```
Now you can test the fixed version and the original version installed on your Linux machine like below.
```
./afl_replay ./gawk
./afl_replay gawk
```
As you can observe, the second script testing the Gawk installed on Linux will fail while the patched version will succeed all the crashes. There is one false positive record in the test result after patching the project. It is because of the fact that the interpreter exists with a code rather than zero but does not crashes. This could be seen by using `valgrind` that the program will not crash.



