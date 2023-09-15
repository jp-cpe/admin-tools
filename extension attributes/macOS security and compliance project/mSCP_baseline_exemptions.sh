#!/bin/sh
######
# mSCP-BaselineExemptions.sh
# Written by Jordan Burnette (jburnette@vcu.edu)
# Last modified 2022.10.05 by Jordan Burnette
# https://github.com/jordanburnette/mSCP_EAs
###### Description
# Determines the baseline version being used and lists out any exemptions that are deployed to the machine. 
######

audit=$(/bin/ls -l /Library/Preferences | /usr/bin/grep 'org.*.audit.plist' | /usr/bin/awk '{print $NF}')
EXEMPT_RULES=()

if [[ ! -z "$audit" ]]; then

    count=$(echo "$audit" | /usr/bin/wc -l | /usr/bin/xargs)
	if [[ "$count" == 1 ]]; then
        auditfile="/Library/Managed Preferences/${audit}"
        if [[ ! -e "$auditfile" ]];then
                auditfile="/Library/Preferences/${audit}"
        fi

        rules=($(/usr/libexec/PlistBuddy -c "print :" "${auditfile}" | /usr/bin/awk '/Dict/ { print $1 }'))
        
        for rule in ${rules[*]}; do
            if [[ $rule == "Dict" ]]; then
                continue
            fi
            exemptions=$(/usr/libexec/PlistBuddy -c "print :$rule:exempt" "${auditfile}" 2>/dev/null)
            if [[ "$exemptions" == "true" ]]; then
                EXEMPT_RULES+=($rule)
            fi
        done
              

    else
        EXEMPT_RULES="Multiple Baselines Found"
    fi
else 
    EXEMPT_RULES="No Baseline Set"
fi
    if [[ ${#EXEMPT_RULES[@]} == 0 ]]; then
        EXEMPT_RULES="No Exemptions Set"
    fi

# sort the results
IFS=$'\n' sorted=($(/usr/bin/sort <<<"${EXEMPT_RULES[*]}")); unset IFS

printf "<result>"
printf "%s\n" "${sorted[@]}"
printf "</result>"
