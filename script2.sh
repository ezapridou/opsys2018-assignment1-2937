#!/bin/bash

# takes a directory and finds the txt files it contains
function find_txt(){
	for a in $1/*; do
		if [ -f $a ]; then
			if [[ $a == *.txt ]]; then
				clone $a
			else
				continue
			fi
		elif [ -d $a ]; then
			find_repos $a
		fi
	done
}

# takes a txt file and clones the repository
function clone(){
	while IFS='' read -r line || [[ -n "$line" ]]; do
		if [[ $line = 'https'* ]]; then
			repo_name=$( basename $line | cut -d '.' -f 1)
			git clone -q $line "$PWD/assignments/$repo_name" &> /dev/null
			if [ $? = 0 ]; then
				echo "$line: Cloning OK"
			else
				echo "$line: Cloning FAILED"
			fi
			return
		fi		
	done < "$1"
}

mkdir "$PWD/assignments" #create direcory where the repositories will be cloned

tar -zxf $1 #unzip #SOS UNCOMMENT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

foldername=${1/.tar.gz/$''} #folder with the txt files

find_txt $foldername


