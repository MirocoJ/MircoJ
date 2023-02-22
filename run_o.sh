#!/bin/bash

for i in {1..3}; do
    input="test$i.txt"
    expected="exp$i.txt"
    output=$(./o < $input)
    if diff -q <(echo "$output") "$expected" > /dev/null; then
        echo "Test $i passed"
    else
        echo "Error in test $i: Fatal error: exception Stdlib.Parsing.Parse_error"
    fi
done