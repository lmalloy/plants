BASE_NAME="malloytrendley"
INPUT_FILE="$BASE_NAME.tab.c"
OUT_FILE="parser.out"
# FILE="let_good4.txt"
FILE="*.txt"


flex $BASE_NAME.l && bison $BASE_NAME.y 
g++ $INPUT_FILE -o $OUT_FILE

find hw5_sample_input -name "*.txt" | while read filename; do 
    echo `basename $filename`
    $OUT_FILE  $filename > out.txt
    diff out.txt hw5_expected_output/`basename $filename`.out --ignore-space-change --ignore-case --ignore-blank-lines
done;


# ./$OUT_FILE < input/$FILE > out.txt
# # diff --side-by-side out.txt output/$FILE.out
# diff out.txt output/$FILE.out --ignore-space-change --ignore-case --ignore-blank-lines