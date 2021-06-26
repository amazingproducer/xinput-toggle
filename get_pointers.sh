#!/bin/bash
# REQUIRES jq TO COMPLETE
xpointers=`xinput | grep keyboard -B 10 -m 1 | grep pointer -A 10 -m 1 | grep keyboard -v | grep "Virtual core pointer" -v | grep "Virtual core XTEST pointer" -v | cut -d' ' -f5- | awk '{sub(/[ \t]+$/, "", $1); sub(/id=/,"",$2); print "{\"name\":\""$1"\",""\"id\":"$2"},"}' FS='\t' OFS=','`

xpointers=${xpointers%?}
xpointers=$xpointers]
xpointers=[$xpointers
echo $xpointers > /tmp/xinput_toggle_targets
unset ar_xpointer_ids
unset ar_xpointer_names
readarray -t ar_xpointer_ids < <(jq '.[]["id"]' /tmp/xinput_toggle_targets)
readarray -t ar_xpointer_names < <(jq '.[]["name"]' /tmp/xinput_toggle_targets)
echo ${ar_xpointer_ids[@]}
echo ${ar_xpointer_names[@]}
