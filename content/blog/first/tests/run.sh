#!/bin/zsh -e

readonly expected="hello world"

gcc main.c
readonly actual=$(./a.out)

if [[ "$expected" != "$actual" ]]
then
    echo "Test failed."
    echo "Expected: $expected"
    echo "Actual: $actual"
    exit 1
fi
