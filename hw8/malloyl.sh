#!/usr/bin/env bash

# @author: Luke Malloy
# @description: CS3500 Homework 8: Bash Script - Autograding

# Unzip the files
# unzip -qq "sampleInput.ZIP" -d "sampleInput"
# unzip -qq "expectedOutput.ZIP" -d "expectedOutput"
# unzip -qq "submissions.ZIP" -d "submissions"


########### run dos2unix on all files ##############


subfolder="submissions"
inputfolder="sampleInput"
expectedfolder="expectedOutput"

mkdir -p "studentOutput"
resultsfolder="studentOutput"

# Process every entry in the submissions directory 

# for each student .pl file
for i in "$subfolder"/*.pl
do
    # init/reset var for counting input cases per student
    casenumber=0
    # grab persons last "name+firstinitial"
    filename="${i##*/}"
    studentid="${filename%.*}"

    # make a unique student directory to hold output
    mkdir -p "$resultsfolder"/"$studentid"

    # init/reset var for counting correct submissions

    # loop through all inputs to be tested on the student's submission
    for j in "$inputfolder"/*.txt
    do 
    
        casenumber=$((casenumber+1))    # inc case number
        program="$i"                    # exe name
        input="$(< $j)"                 # input from text file (string)
        
        # output file path
        outpath="$resultsfolder"/"$studentid"/"$studentid""$casenumber".out 

        # run prolog on studentid.pl for each case, redirect output to folder
        swipl "$program" $input > "$outpath"

        # expected file
        cd "expectedOutput/"
        expectedfile=`ls|grep $casenumber`
        cd ..
        # total cases
        expectedpath="$expectedfolder"/"$expectedfile"

        # check against expected output
        if diff --ignore-all-space "$outpath" "$expectedpath"
        then
            
        else
            echo fail 
        fi  

    done
done

