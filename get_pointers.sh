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
#echo ${ar_xpointer_ids[@]}
#echo ${ar_xpointer_names[@]}
xi_check=$(ls /tmp/xinput_toggle_target 2> /dev/null) && existing_target=1 || existing_target=0
if [ $existing_target -eq 0 ]
then
echo "Target input device not found; please select:"
select pointer in "${ar_xpointer_names[@]}"; do
read xpointer_id < <(jq .[$(($REPLY-1))]."id" /tmp/xinput_toggle_targets)
echo "$pointer, ID=$xpointer_id targeted."
echo $xpointer_id > /tmp/xinput_toggle_target
done
else
echo "Current target input: $(cat /tmp/xinput_toggle_target)"
fi
