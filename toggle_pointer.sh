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
#xi_check=$(ls /tmp/xinput_toggle_target_id 2> /dev/null) && existing_target=1 || existing_target=0
xn_check=$(ls /tmp/xinput_toggle_target_name 2> /dev/null) && existing_target=1 || existing_target=0

if (( SHLVL > 1 ))
then 
#Executed from terminal
xp_source="terminal"
else
#Executed from within desktop
xp_source="desktop"
fi

if [ $existing_target -eq 0 ]
then

if [ $xp_source -eq "desktop" ]
then

xp_zenity_check=$(command -v zenity) && xp_has_zenity=1 || xp_has_zenity=0
if [ $xp_has_zenity -eq 0 ]
then
notify-send -t 20000 -a "xinput toggle" -i mouse "xinput toggle" "Error: Zenity is required for initial desktop setup. Please install Zenity or run initial setup from terminal instead."
exit 2
fi

zen_list=$(jq -r '.[] | [.id, .name] | @csv' /tmp/xinput_toggle_targets | awk '{gsub(" ", "_")}{sub(","," ")};{print $0}')
xpointer_id=$(zenity --list --title="xinput toggle" \
--text="Select target toggle device:" \
--column=id --column=device \
$zen_list)
xpointer_name=$(jq '.[]|select(.id=='$xpointer_id')| .name' /tmp/xinput_toggle_targets)
else

echo "Target input device not found; please select:"
select pointer in "${ar_xpointer_names[@]}"; do
read xpointer_id < <(jq .[$(($REPLY-1))]."id" /tmp/xinput_toggle_targets)
read xpointer_name < <(jq .[$((REPLY-1))]."name" /tmp/xinput_toggle_targets)
echo "$pointer, ID=$xpointer_id targeted."
break
done

fi
echo $xpointer_id > /tmp/xinput_toggle_target_id
echo $xpointer_name > /tmp/xinput_toggle_target_name
fi

xpointer_status=$(xinput list-props $(cat /tmp/xinput_toggle_target_id) | grep "Device Enabled" | awk '{print $4}')
xpointer_id=$(cat /tmp/xinput_toggle_target_id)
xpointer_name=$(cat /tmp/xinput_toggle_target_name)
if [ $xpointer_status = 0 ]
then
echo "Enabling $xpointer_name ($xpointer_id)."
notify-send -a "xinput toggle" -i mouse "xinput toggle" "Enabling $xpointer_name"
xinput set-prop $xpointer_id "Device Enabled" 1
else
echo "Disabling $xpointer_name ($xpointer_id)."
notify-send -a "xinput toggle" -i mouse "xinput toggle" "Disabling $xpointer_name"
xinput set-prop $xpointer_id "Device Enabled" 0
fi
