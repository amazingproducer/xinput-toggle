#!/bin/bash
# REQUIRES jq TO COMPLETE
xpointers=`xinput | grep keyboard -B 10 -m 1 | grep pointer -A 10 -m 1 | grep keyboard -v | grep "Virtual core pointer" -v | grep "Virtual core XTEST pointer" -v | cut -d' ' -f5- | awk '{sub(/[ \t]+$/, "", $1); sub(/id=/,"",$2); print "{\"name\":\""$1"\",""\"id\":"$2"},"}' FS='\t' OFS=','`

xpointers=${xpointers%?}
xpointers=$xpointers]
xpointers=[$xpointers
echo $xpointers > /tmp/xinput_toggle_targets
#unset ar_xpointer_ids
#unset ar_xpointer_names
readarray -t a_xpointer_ids < <(jq '.[]["id"]' /tmp/xinput_toggle_targets)
readarray -t a_xpointer_names < <(jq '.[]["name"]' /tmp/xinput_toggle_targets)
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
	echo "No existing target found."
	if [ $xp_source == "terminal" ]
		then
		readarray -t cur_list < <(jq -r '.[] | .id, .name' /tmp/xinput_toggle_targets | awk '{sub(","," ")};{print $0}')
		xpointer_id=$(dialog --clear --backtitle "xinput toggle" --title "xinput Toggle Setup" --menu "Select the default pointer to toggle:" 15 40 4 "${cur_list[@]}" 2>&1 >/dev/tty)
		xpointer_name=$(jq '.[]|select(.id=='$xpointer_id')| .name' /tmp/xinput_toggle_targets)
		echo $xpointer_id > /tmp/xinput_toggle_target_id
		echo $xpointer_name > /tmp/xinput_toggle_target_name
		else
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
		echo $xpointer_id > /tmp/xinput_toggle_target_id
		echo $xpointer_name > /tmp/xinput_toggle_target_name
	fi
else
echo "Existing target found."
xpointer_id=$(cat /tmp/xinput_toggle_target_id)
xpointer_name=$(cat /tmp/xinput_toggle_target_name)
fi
#xpointer_status=$(xinput list-props $(cat /tmp/xinput_toggle_target_id) | grep "Device Enabled" | awk '{print $4}')
xpointer_status=$(xinput list-props $xpointer_id | grep "Device Enabled" | awk '{print $4}')
if [ $xpointer_status -eq 0 ]
	then
	echo "Enabling $xpointer_name ($xpointer_id)."
	notify-send -a "xinput toggle" -i mouse "xinput toggle" "Enabling $xpointer_name"
	xinput set-prop $xpointer_id "Device Enabled" 1
	else
	echo "Disabling $xpointer_name ($xpointer_id)."
	notify-send -a "xinput toggle" -i mouse "xinput toggle" "Disabling $xpointer_name"
	xinput set-prop $xpointer_id "Device Enabled" 0
fi
