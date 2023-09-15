#!/bin/sh
######
# mSCP-FailedItems.sh
# Original by Matt Woodruff @ Jamf
# Last modified 2022.10.04 by Jordan Burnette
# https://github.com/jordanburnette/mSCP_EAs
###### Description
# Displays a list of compliance controls that failed.
######

audit=$(ls -l /Library/Preferences | /usr/bin/grep 'org.*.audit.plist' | /usr/bin/awk '{print $NF}')
FAILED_RULES=()
if [[ ! -z "$audit" ]]; then

    count=$(echo "$audit" | wc -l | xargs)
	if [[ "$count" == 1 ]]; then
        auditfile="/Library/Preferences/${audit}"

        rules=($(/usr/libexec/PlistBuddy -c "print :" "${auditfile}" | awk '/Dict/ { print $1 }'))
        
        for rule in ${rules[*]}; do
            if [[ $rule == "Dict" ]]; then
                continue
            fi
            FINDING=$(/usr/libexec/PlistBuddy -c "print :$rule:finding" "${auditfile}")
            if [[ "$FINDING" == "true" ]]; then
                FAILED_RULES+=($rule)
            fi
        done
              

    else
        FAILED_RULES="Multiple Baselines Found"
    fi
else 
    FAILED_RULES="No Baseline Found"
fi

# sort the results
IFS=$'\n' sorted=($(sort <<<"${FAILED_RULES[*]}")); unset IFS

printf "<result>"
printf "%s\n" "${sorted[@]}"
printf "</result>"
