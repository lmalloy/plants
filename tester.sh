#!/bin/bash

# This script will flex whatever .l file(s) and bison whatever
# .y file(s) are in the directory from which it is run. It will
# then g++ the resulting .tab.c file(s) creating an executable
# named a.out
#
# Then it will run a.out on every file in a directory named
# HW3_sample_input writing the output to a directory named
# HW3_actual_output
#
# Finally, it will do a diff on each file in HW3_actual_output
# against the file with the same name that is in a directory
# named HW3_expected_output and report the differences in a
# directory named reports3
#
# To run this script, do the following:
# (1) Make sure you do NOT have a directory named HW3_actual_output
# (2) Make sure you do NOT have a directory named reports3
# (3) Make sure you have a directory named HW3_sample_input that
#     contains ONLY the sample input files you want to test
# (4) Make sure you have a directory named HW3_expected_output
#     that contains ONLY the expected output files, one for each
#     of the files in the HW3_sample_input directory
# (5) Make sure you have ONLY a single .l file in this directory
# (6) Make sure you have ONLY a single .y file in this directory
# (7) bash tester.sh
#
# If you get an ioctl error on any file other than summary.txt
# while running the script, rm the HW3_actual_output and reports3
# directories, and restart from step (7)

# If you make any changes to this script in Windows, you must
# run dos2unix on it before running it with bash
# The following is also equivalent to running dos2unix on this
# file to get rid of the \r's:
# perl -i -p -e "s/\r//" tester.sh

echo "--> Making folders"
mkdir ./HW5_actual_output
mkdir ./reports5
echo "--> rm ./a.out"
rm ./a.out

echo "--> flex"
flex *.l
echo "--> bison"
bison *.y
echo "--> g++"
g++ *.tab.c -o a.out

inputs=`ls HW5_sample_input --ignore-backups`
echo "--> Running against test cases"
for i in $inputs; do
  echo "--> Trying" $i
  ./a.out < ./HW5_sample_input/$i > ./HW5_actual_output/$i.out

  diff ./HW5_actual_output/$i.out ./HW5_expected_output/$i.out > \
       ./reports5/$i --ignore-space-change --ignore-case \
       --side-by-side

  lines=`diff ./HW5_actual_output/$i.out ./HW5_expected_output/$i.out \
         --ignore-space-change --ignore-case  | wc --lines`
  echo $lines unexpected lines in $i.out \
       >> ./reports5/summary.txt
  echo $lines errors
 done

 echo >> ./reports5/summary.txt