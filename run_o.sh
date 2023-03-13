#!/bin/bash

for i in {1..7}; do
    posInput="tests/test$i.txt"
    posExpected="tests/exp$i.txt"

    if diff -q <(./o < $posInput) "$posExpected" > /dev/null; then
        echo "Positive test $i passed as expected"
    else
        echo "Error in positive test $i: Fatal error: exception Stdlib.Parsing.Parse_error"
    fi
done

for i in {1..5}; do
    negInput="tests/failTest$i.txt"
    
    if ! ./o < $negInput; then
        echo "Negative test $i failed as expected"
    else
        echo "Error in negative test $i: illegal syntax parsed successfully"
    fi
done