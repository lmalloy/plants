#!/usr/bin/env sh

# @author: Luke Malloy
# @description: CS3500 Homework 8: Bash Script - Autograding

# Unzip the files

# unzip -qq "sampleInput.ZIP" -d "sampleInput"
# unzip -qq "expectedOutput.ZIP" -d "expectedOutput"
# unzip -qq "submissions.ZIP" -d "submissions"

########### dos2unix ran on all files before testing ##############

if [ -f "grades.txt" ]; 
then 
    rm -rf "grades.txt"
fi

subfolder="submissions"
inputfolder="sampleInput"
expectedfolder="expectedOutput"

# Make directories and files necessary for grading
mkdir -p "studentOutput"
resultsfolder="studentOutput"
touch "grades.txt"

# Determine total number of input files
cd "sampleInput/"
totalcases=`ls -l . | egrep -c '^-'`
cd ..

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

    # init/reset var for counting correct cases
    correct=0
    # init/reset var for counting incorrect cases
    wrong=0
    # init/reset var for counting total cases
    countedcases=0
    # init/reset var for student score
    percentage=0
    # init/reset var for manual grading
    manualgrade="false"

    # loop through all inputs to be tested on the student's submission
    for j in "$inputfolder"/*.txt
    do 
    
        casenumber=$((casenumber+1))    # inc case number
        program="$i"                    # exe name
        input="$(< $j)"                 # input from text file (string) # < : akin to cat
        
        # output file path
        outpath="$resultsfolder/$studentid/$studentid$casenumber.out" 

        # run prolog on studentid.pl for each case, redirect output to folder
        swipl $program $input > $outpath

        # expected file
        cd "expectedOutput/"
        expectedfile=`ls|grep $casenumber`          # determine the input file by casenumber
        cd ..

        # total cases
        expectedpath="$expectedfolder/$expectedfile"

        # check against expected output
        if diff -w --ignore-all-space $outpath $expectedpath;
        then
            correct=$((correct+1))

            # check for cheating
            studentoutput=`cat $outpath`

            if grep -q "$studentoutput" $program; then
                manualgrade="true" 
            else
                manualgrade="false"
            fi
        else
            wrong=$((wrong+1))
        fi  

        # add up total cases counted
        countedcases=$((correct+wrong))

        # calculate total score
        percentage=$((correct/totalcases*100))
        
    done

    # write the student name and percentage in the file 
    entry="$studentid, $percentage"
    if [ "$manualgrade" == "false" ]; then
        echo -e "$entry\r\n" >> "grades.txt"
    else
    # indicate with * if manual grade necessary
        echo -e "$entry*\r\n" >> "grades.txt"
    fi

done

