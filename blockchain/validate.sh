#!/bin/bash

i=1

## write the nonce here
nonce_file=proposed-nonce.txt

## change these two parameters together
difficulty=0
num_zeros=1
 
echo $1 > $nonce_file
attempt=$(cat data.txt $nonce_file| exec sha256sum)
echo "Checking $1 $attempt"
if [ ${attempt:0:$num_zeros} = $difficulty ]; then
	echo "Correct! I accept your nonce $1"
	exit 0;
else
	echo "Wrong! try again"
fi
