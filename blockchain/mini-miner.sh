#!/bin/bash

i=1

## write the nonce here
nonce_file=nonce.txt

## change these two parameters together
difficulty=0
num_zeros=1
 
while true
do
		nonce=$(echo $RANDOM | md5sum | cut -f1 -d" ")
		echo $nonce > $nonce_file
		attempt=$(cat data.txt $nonce_file| exec sha256sum | cut -f1 -d" ")
		echo "$nonce $attempt"
		if [ ${attempt:0:$num_zeros} = $difficulty ]; then
			echo "Mined a block after $i attempts! using nonce $nonce"
			exit 0;
		fi
		sleep 1
   let i++
done
