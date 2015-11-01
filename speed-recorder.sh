#!/bin/bash 

function run_speed_test() {
	echo "Running speed test"
	./speedtest-cli   --simple > test_scores.txt
}


function convert_to_csv() {
	echo "Running convert to csv task"
	readarray -t LINES < test_scores.txt 
	for LINE in "${LINES[@]}";
	do
		if [ $COUNTER -eq 2 ]; then
			printf `echo $LINE | cut -d' ' -f2` >> test_scores.csv 
		else
			printf `echo $LINE | cut -d' ' -f2`, >> test_scores.csv
		fi
	done
	echo "" >> test_scores.csv
}


function save_to_google_drive() {
# https://developers.google.com/identity/protocols/OAuth2ForDevices
	echo "Running google drive sync"
}

function clean_up() {
	rm -rf test_scores.txt

}



#run_speed_test

convert_to_csv
