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
			find_txt $a
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

function check_repos(){
	if [ -f $1 ]; then
		if [[ $1 == *.txt ]]; then
			num_of_txt=$(($num_of_txt+1))
		else
			num_of_other=$(($num_of_other+1))
		fi
	elif [ -d $1 ]; then
		num_of_dir=$(($num_of_dir+1))
		for b in $1/*; do			
			check_repos $b
		done
	fi
}

if ! [ -d $PWD/assignments ]; then
	mkdir "$PWD/assignments" #create direcory where the repositories will be cloned
fi

tar -zxf $1 #unzip 

foldername=${1/.tar.gz/$''} #folder with the txt files

find_txt $foldername

searchd="$PWD/assignments"
for a in $searchd/*; do #for each repository directory
	if [ -d $a ]; then
		num_of_dir=-1 #don't count the main directory
		num_of_txt=0
		num_of_other=0
		check_repos $a
		name=$( basename $a | cut -d '.' -f 1) #repo's name
		echo -e "$name: \nNumber of directories: $num_of_dir \nNumber of txt files: $num_of_txt \nNumber of other files: $num_of_other"
		if [ $num_of_dir -eq 1 ] && [ $num_of_txt -eq 3 ] && [ $num_of_other -eq 0 ]; then
			if [ -e $searchd/$name/dataA.txt ] && [ -d $searchd/$name/more/ ] && [ -e $searchd/$name/more/dataB.txt ] && \
				[ -e $searchd/$name/more/dataC.txt ]; then
				echo "Directory structure is OK"
				continue
			fi
		fi
		echo "Directory structure is not OK"
	fi
done


