#!/usr/bin/env sh

# @author: Luke Malloy
# @description: CS3500 Homework 8: Bash Script - Autograding

# If folders present
if ! [ -d "sampleInput" ] && [ -d "expectedOutput" ] && [ -d "submissions" ];
then
    # Unzip the files
    unzip -qq "sampleInput.ZIP" -d "sampleInput"
    unzip -qq "expectedOutput.ZIP" -d "expectedOutput"
    unzip -qq "submissions.ZIP" -d "submissions"
else
    echo "One of the following directories already exists: sampleInput, expectedOutput, submissions"
fi

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
    
    # grab file name
    filename="${i##*/}"
    # student's last "name+firstinitial"
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

    # place input files in array
    expectedoutfiles=( expectedOutput/*.txt.out )
    #echo "${inputfiles[0]}"
    #echo "${inputfiles[1]}"

    # loop through all inputs to be tested on the student's submission
    for j in "$inputfolder"/*.txt
    do 
    
        casenumber=$((casenumber+1))    # inc case number
        program="$i"                    # exe name
        input="$(< $j)"                 # input from text file (string) # < : akin to cat
        
        # output file path
        outpath="$resultsfolder/$studentid/$studentid$casenumber.out" 
        #echo $outpath

        # run prolog on studentid.pl for each case, redirect output to folder
        swipl $program $input > $outpath

        # append newline to output files in outpath
        echo -e "\r\n" >> $outpath
        #sed -i -e '$a\' $outpath > $outpath

        # index is one less than case number
        index=$((casenumber-1))

        # expected output file from array
        expectedfile="${expectedoutfiles[$index]}"        
        
        # check against expected output
        if diff -q -w -B -Z <(head -n 1 "$outpath") <(head -n 1 "${expectedfile}")
        #if diff $outpath $expectedfile;
        then
            correct=$((correct+1))
            #echo -e "\r\n"
            # check for cheating
            studentoutput=`cat $outpath`
            # -q for quiet # -E -o
            if grep "$studentoutput" $program; then
                manualgrade=1 
            else
                manualgrade=0
            fi
        else
            wrong=$((wrong+1))
        fi  

        # add up total cases counted
        #countedcases=$((correct+wrong))

        # calculate total score
        bc <<< 'scale=2'
        float=`echo "$correct / $totalcases" | bc -l`
        # perform floating point arithmetic     # remove trailing zeroes if there is a decimal separator
        percentage=`echo "$float * 100" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//'` 

    done

    # write the student name and percentage in the file 
    entry="$studentid, $percentage"
    if [ "$manualgrade" == 0 ]; then
        echo -e "$entry\r\n" >> "grades.txt"
    else
    # indicate with * if manual grade necessary
        echo -e "$entry*\r\n" >> "grades.txt"
    fi

done

