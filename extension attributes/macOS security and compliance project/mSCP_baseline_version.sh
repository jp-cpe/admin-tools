#!/bin/sh
######
# mSCP-BaselineVersion.sh
# Written by Jordan Burnette (jburnette@vcu.edu)
# Last modified 28 Sept 2022 by Jordan Burnette
# https://github.com/jordanburnette/mSCP_EAs
###### Description
# Lists the baseline being used on the targeted machine
######

result=$(/bin/ls -l /Library/Preferences | /usr/bin/grep "org.*.audit.plist" | /usr/bin/awk '{print $NF}')

if [[ ! -z "$result" ]]; then
	count=$(echo "$result" | wc -l | xargs)
	if [[ "$count" != 1 ]]; then
		result="Multiple Baselines Set"
	fi
else result="No Baseline Set"
fi

/bin/echo "<result>$result</result>"
