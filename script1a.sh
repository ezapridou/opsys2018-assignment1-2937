#!/bin/bash
CURL='/usr/bin/curl'

touch temp
temp_file="$PWD/temp"

while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line = '#'* ]]; then
		continue
	fi
	filename=${line////$'_'}
	
	if [[ $($CURL -s $line) = "" ]]; then
		if ! [[ -f "$filename" ]]; then
			touch $filename
			echo "" >> "$PWD/$filename"
			1>&2 echo "$line FAILED"
			continue
		fi
		continue
	fi
	
	if [[ -f "$filename" ]]; then
		$CURL -s $line >> "$temp_file"
		if ! cmp -s "$filename" "$temp_file"; then
			echo $line
			cp "$temp_file" "$filename"
		fi
		> temp
	else
		touch $filename
		echo "$line INIT"
		$CURL -s $line >> "$PWD/$filename"
	fi
done < "$1"
