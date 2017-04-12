#!/bin/bash

# wolftex
# takes Wolfram Language input line by line, and runs it with wolfram in

wolf_path="/media/grant/Data/LinuxPrograms/Mathematica/Executables/wolfram"

if [ ! -f "$wolf_path" ]; then
	sudo mount -t auto /dev/sda1 /media/grant/Data
	if [ ! -f "$wolf_path" ]; then
		echo "Error finding the Wolfram executables"
		exit 1
	fi
fi

echo "\"Grant Baker\"//TeXForm" > tmp.wolf

while IFS='' read -r line || [[ -n "$line" ]]; do
	echo "$line" >> find.tmp
	echo "$line//TeXForm" >> tmp.wolf
done < "$1"

$wolf_path < tmp.wolf > tmp2.wolf
rm tmp.wolf

echo "\\documentclass[12pt]{article}" > out.tex
echo "\\usepackage{amsmath}" >> out.tex
echo "\\usepackage[margin=1in]{geometry}" >> out.tex
echo "\\begin{document}" >> out.tex

echo $1

while IFS='' read -r line || [[ -n "$line" ]]; do
	if [[ $line == In* ]]; then
		read -r command < find.tmp
		tail -n +2 find.tmp > find.tmp.tmp
		mv find.tmp.tmp find.tmp
		echo "{\tt $line $command}" >> out.tex
		echo "" >> out.tex
	fi
done < tmp2.wolf

echo "\\end{document}" >> out.tex

latex out.tex
dvipdfm -q out.dvi
