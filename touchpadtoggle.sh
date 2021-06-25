if synclient -l | grep TouchpadOff | awk '{print $3}' | grep -q 0;
then
synclient TouchpadOff=1
else
synclient TouchpadOff=0
fi
