#! /bin/bash
interface=$1

if [[ $interface == "-h" ]]; then
	echo "bash spoofy.sh interface( ex: wlo1 )" 
	exit 1
fi

# check if gateway pingable
result="$(ping gateway -c 1)"

if [[ $result == *"Name or service not known"* ]]; then
	echo "Gateway is down" 
	exit 1
fi

# get gateway mac address
result="$(arp -a -i $interface)"

if [[ $result == *"no match found"* ]]; then
	echo "Wrong interface: $interface" 
	exit 1
fi

result=${result##*at } # get part after "at "
mac=${result%% [ether*} # get part before " [ether"

# first time, save the mac into the gateway.txt file
if [  ! -f gateway.txt ]; then
	echo "$mac" >> "gateway.txt"
	echo "Gateway mac address is: $mac"
fi 

# read from gateway.txt and check the mac address
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [ $mac != $line ]; then
		ifconfig $interface down # shutdown the network for this pc
		echo "You are being ATTACKED!!! the attacker mac is: $mac" >> "attacker.txt"
		espeak  'network is being spoofed by '$mac', connection, going down. Contact your network administrator.' 
		exit 1
	fi
done < gateway.txt

echo "You are safe"
