#!/bin/bash
CURL='/usr/bin/curl'

function url_check(){
	line=$1
	if [[ $line = '#'* ]]; then
		return
	fi
	filename=${line////$'_'}
	
	if [[ $($CURL -s $line) = "" ]]; then
		if ! [[ -f "$filename" ]]; then
			touch $filename
			echo "" >> "$PWD/$filename"
			1>&2 echo "$line FAILED"
			return
		fi
		return
	fi

	touch "temp_$filename"
	temp_file="$PWD/temp_$filename"
	if [[ -f "$filename" ]]; then
		$CURL -s $line >> "$temp_file"
		if ! cmp -s "$filename" "$temp_file"; then
			echo $line
			cp "$temp_file" "$filename"
		fi
		> $temp_file
	else
		touch $filename
		echo "$line INIT"
		$CURL -s $line >> "$PWD/$filename"
	fi
}

{
while IFS='' read -r line || [[ -n "$line" ]]; do
	url_check $line &
done < "$1"
wait
}
