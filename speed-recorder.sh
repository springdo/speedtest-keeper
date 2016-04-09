#!/bin/bash 

function run_speed_test() {
	echo "Running speed test"
	./speedtest-cli   --simple > test_scores.txt
	cat test_scores.txt
}


function prepare_tweet() {
	echo "reparing tweet"
	export DATA='{"ping":"'$PING'","download":"'$DOWNLOAD_SPEED'","upload":"'$UPLOAD_SPEED'"}'
	echo $DATA
	curl -X POST -H "Content-Type: application/json" -d $DATA  http://speed-tweet.eu-gb.mybluemix.net/tweetme  && rc=$? || rc=$?
	echo "Error code from tweet is : " $rc 

}


function convert_to_csv() {
	echo "Running convert to csv task"
	printf `date +%x_%H:%M:%S`, >> test_scores.csv
	readarray -t LINES < test_scores.txt
	COUNTER=0 
	for LINE in "${LINES[@]}";
	do
		if [ $COUNTER -eq 2 ]; then
			export UPLOAD_SPEED=`echo $LINE | cut -d' ' -f2`
			printf $UPLOAD_SPEED >> test_scores.csv 
		elif [ $COUNTER -eq 1 ]; then
                        export DOWNLOAD_SPEED=`echo $LINE | cut -d' ' -f2`
                        printf $DOWNLOAD_SPEED, >> test_scores.csv
		else	
			export PING=`echo $LINE | cut -d' ' -f2`
			printf $PING, >> test_scores.csv
		fi
	let COUNTER=COUNTER+1 
	done
	echo "" >> test_scores.csv
}


function save_to_google_drive() {
	echo "Running google drive sync"
	FILE_ID=1OiMAZmSTXc34bguN5nhpKIgYow0p_x26DGAANdSnxNM
	curl -k -i -X PUT -H "Content-Type: text/plain" -H "Content-Length: ${CONTENT_LEN}"  -H "Authorization: Bearer ${ACCESS_TOKEN}" --data-binary @test_scores.csv  https://www.googleapis.com/upload/drive/v2/files/${FILE_ID}\?uploadType\=media
}

function get_auth_token() {
	echo "Getting Authtoken"
	ACCESS_TOKEN=`curl -k -d "client_id=${GOOGLE_CLIENT_ID}&client_secret=${GOOGLE_CLIENT_SECRET}&refresh_token=${GOOGLE_CLIENT_REFRESH_TOKEN}&grant_type=refresh_token" https://www.googleapis.com/oauth2/v3/token  | jq '.access_token'`
	echo $ACCESS_TOKEN
	if [ $ACCESS_TOKEN == 'null' ]; then
		clean_up
		exit 99999
	fi
}

function calc_cont_length() {
	echo "Getting content length"
	CONTENT_LEN=`ls -la test_scores.csv | cut -d' ' -f5`
	echo $CONTENT_LEN
}

function clean_up() {
	rm -rf test_scores.txt

}



run_speed_test

convert_to_csv

prepare_tweet

get_auth_token

calc_cont_length

save_to_google_drive

clean_up

