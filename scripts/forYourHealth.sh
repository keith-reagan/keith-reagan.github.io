#Keith Reagan
#12-2-21
#Script to monitor server health
#!/usr/bin/bash

#echo start
NORMAL=$(tput sgr0)		# Var for removing formatting if there is any 
RED=$(tput setaf 1)		# Make txt red
UNDERLINE=$(tput smul)	# Var for underlining words
#echo after formatting
pants=$(date +"%A_%B_%d_%Y_%T").log #Defines var for log file using day of the week, month, day, 24hr time
#echo after logfile
logDir=/logs/health #Defines var for logDir, used to check to see if dir exists before trying to write to it
#echo after logfile dir
osflavor=$(hostnamectl | grep Operating | awk 'BEGIN{FS=": "}; {print $2}') #Defines flavor of OS var to use with commands
#echo after os flavor
#yesterdaySar=/var/log/sysstat/sa$(date +%d -d yesterday)
#highCPU=$(sar | sed 1,5d | awk '$4>10.00 || $6>10.00 { print $1" " $2" " $4" "$6}') #Remove top 5 lines, then print if user or system CPU is greater than 10 percent
#echo create dir if its not there
	[ -d /logs/health/ ] || mkdir /logs/health >/dev/null 2>&1 #Checks to see if log dir exists, if not makes it and sends error to null         
	#echo $osflavor #created as a standalone check
	sudo touch /logs/health/$pants #Creating the log file
	chmod 755 /logs/health/$pants #Changing rights to the log file
#echo start of ifs	

	if [[ "$osflavor" == *"Ubuntu"* ]]; then # If running on the Ubuntu server it will run the next few commands
echo Starting package upgrades...may take a moment
		printf "\n${UNDERLINE}Package upgrades -${NORMAL}\n">> /logs/health/$pants;
		sudo apt -y upgrade >> /logs/health/$pants;	# Runs upgrade on packages available to update with "-y" switch for no human intervention
echo Starting package cleanup
		printf "\n${UNDERLINE}Package cleanup -${NORMAL}\n">> /logs/health/$pants;
		sudo apt-get clean >> /logs/health/$pants;		# Cleans out old unused files from packages
	else # If running on the CentOS server it will run the next few commands
echo Starting package upgrades...may take a moment
		printf "\n${UNDERLINE}Package upgrades -${NORMAL}\n">> /logs/health/$pants;
		sudo sudo dnf -y upgrade >> /logs/health/$pants;	# Runs upgrade on packages available to update with "-y" switch for no human intervention
echo Starting package cleanup
		printf "\n${UNDERLINE}Package cleanup -${NORMAL}\n">> /logs/health/$pants;
		sudo dnf clean dbcache >> /logs/health/$pants;		# Cleans out old unused files from packages
	fi

echo Checking for over utilizing processes
	printf "\n${UNDERLINE}Checking for over utilizing processes${NORMAL}\n">> /logs/health/$pants;
	sudo ps -A | grep -i stress >> /logs/health/$pants;		# Check for unresponsive processes
	printf "\n If there is a processes running hot, run the command 'sudo kill -9 (PID)' where (PID) is the process in question\n">> /logs/health/$pants;
echo Checking for top five processes for cpu
	printf "\n${UNDERLINE}Top five processes utilizing the CPU -${NORMAL}\n">> /logs/health/$pants;
	sudo ps -eo pid,ppid,cmd,%cpu --sort=-%cpu | head -5 >> /logs/health/$pants;		# Display the top 5 process IDs with their parent process IDs and their file locations that are utilizing the CPU from most to least
echo Checking for top five processes for mem
	printf "\n${UNDERLINE}Top five processes utilizing the system memory -${NORMAL}\n">> /logs/health/$pants;
	sudo ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -5 >> /logs/health/$pants;		# Display the top 5 process IDs with their parent process IDs and their file locations that are utilizing system memory from most to least
	printf "\n${UNDERLINE}Process for running iostat in the background -${NORMAL}\n">> /logs/health/$pants;
	#sudo nohup iostat 10 3 -t -m -p sda &
echo Checking for high cpu usage previous day	
	if [[ "$osflavor" == *"Ubuntu"* ]]; then # If running on the Ubuntu server it will run the next few commands
		# Pull high CPU utilization for previous day
		File=$(sar -f /var/log/sysstat/sa$(date +%d -d yesterday) | sed 1,5d | awk '$4>10.00 || $6>10.00 { print $1" " $2" " $4" "$6}') #Remove top 5 lines, then print if user or system CPU is greater than 10 percent
		printf "\n${RED}Processes that ran more than 10 percent of CPU utilization${NORMAL}\n">> /logs/health/$pants; 
		printf "${UNDERLINE}%-11s%-6s%-10s\n" "Time" "User" "System${NORMAL}">> /logs/health/$pants; # Prints header for this section
		while read -r high_cpu; #while theres lines in this file
		do
			printf "$high_cpu\n" >> /logs/health/$pants;	# Print each line in file
		done < <(sar -f /var/log/sysstat/sa$(date +%d -d yesterday) | sed 1,5d | awk '$4>10.00 || $6>10.00 { print $1" " $2" " $4" "$6}') # Stops loop after all lines read
	else
		# Pull high CPU utilization for previous day
		File=$(sar -f /var/log/sa/sa$(date +%d -d yesterday) | sed 1,5d | awk '$4>10.00 || $6>10.00 { print $1" " $2" " $4" "$6}') #Remove top 5 lines, then print if user or system CPU is greater than 10 percent
		printf "\n${RED}Processes that ran more than 10 percent of CPU utilization${NORMAL}\n">> /logs/health/$pants; 
		printf "${UNDERLINE}%-11s%-6s%-10s\n" "Time" "User" "System${NORMAL}">> /logs/health/$pants; # Prints header for this section
		while read -r high_cpu; #while theres lines in this file
		do
			printf "$high_cpu\n" >> /logs/health/$pants;	# Print each line in file
		done < <(sar -f /var/log/sa/sa$(date +%d -d yesterday) | sed 1,5d | awk '$4>10.00 || $6>10.00 { print $1" " $2" " $4" "$6}') # Stops loop after all lines read
	fi
echo Checking for high mem usage previous day	
	if [[ "$osflavor" == *"Ubuntu"* ]]; then
		# Pull high memory utilization for previous day
		File=$(sar -r -f /var/log/sysstat/sa$(date +%d -d yesterday) | sed 1,5d | awk 'NR ==1 || $6>=80.00 { print}') #Remove top 4 lines, then print if memory usage was greater than 80 percent
		printf "\n${RED}Times that memory at 80 percent or more utilization${NORMAL}\n">> /logs/health/$pants;
		printf "${UNDERLINE}%-13s%-12s%-9s%-11s%-9s%-10s%-10s%-10s%-11s%-10s%-10s%-8s\n" "time" "kbmemfree" "kbavail" "kbmemused" "%memused" "kbbuffers" "kbcached" "kbcommit" "%commit" "kbactive" "kbinact" "kbdirty${NORMAL}">> /logs/health/$pants; # Prints header for this section		
		while read -r high_mem; #while theres lines in this file
		do
			printf "$high_mem\n" >> /logs/health/$pants;	# Print each line in file
		done < <(sar -r -f /var/log/sysstat/sa$(date +%d -d yesterday) | sed 1,5d | awk 'NR ==1 || $6>80.00 { print}') # Stops loop after all lines read		
	else

		# Pull high memory utilization for previous day
		File=$(sar -r -f /var/log/sa/sa$(date +%d -d yesterday) | sed 1,5d | awk 'NR ==1 || $6>=80.00 { print}') #Remove top 4 lines, then print if memory usage was greater than 80 percent
		printf "\n${RED}Times that memory at 80 percent or more utilization${NORMAL}\n">> /logs/health/$pants; 
		printf "${UNDERLINE}%-13s%-12s%-9s%-11s%-9s%-10s%-10s%-10s%-11s%-10s%-10s%-8s\n" "time" "kbmemfree" "kbavail" "kbmemused" "%memused" "kbbuffers" "kbcached" "kbcommit" "%commit" "kbactive" "kbinact" "kbdirty${NORMAL}">> /logs/health/$pants; # Prints header for this section	
		while read -r high_mem; #while theres lines in this file
		do
			printf "$high_mem\n" >> /logs/health/$pants;	# Print each line in file
		done < <(sar -r -f /var/log/sa/sa$(date +%d -d yesterday) | sed 1,5d | awk 'NR ==1 || $6>=80.00 { print}') # Stops loop after all lines read		
	fi
echo Checking for high network usage previous day		
	if [[ "$osflavor" == *"Ubuntu"* ]]; then
		# Pull high network utilization for previous day
		File=$(sar -n DEV -f /var/log/sysstat/sa$(date +%d -d yesterday) | egrep -v lo | sed 1,5d | awk 'NR ==1 || $11>=80.00 { print}')
		printf "\n${RED}Times that utilization was 80 percent or more for network interfaces${NORMAL}\n">> /logs/health/$pants; 
		printf "${UNDERLINE}%-16s%-10s%-9s%-11s%-10s%-10s%-10s%-10s%-10s%-9s\n" "time" "IFACE" "rxpck/s" "txpck/s" "rxkB/s" "txkB/s" "rxcmp/s" "txcmp/s" "rxmcst/s" "%ifutil${NORMAL}">> /logs/health/$pants; # Prints header for this section	
		while read -r high_mem; #while theres lines in this file
		do
			printf "$high_mem\n" >> /logs/health/$pants;	# Print each line in file
		done < <(sar -n DEV -f /var/log/sysstat/sa$(date +%d -d yesterday) | egrep -v lo | sed 1,5d | awk 'NR ==1 || $11>=80.00 { print}') # Stops loop after all lines read	
	else	
		# Pull high network utilization for previous day
		File=$(sar -n DEV -f /var/log/sa/sa$(date +%d -d yesterday) | egrep -v lo | sed 1,5d | awk 'NR ==1 || $11>=80.00 { print}') #Remove all the lo interfaces, remove top 4 lines, then print if network interface utilization was greater than 80 percent
		printf "\n${RED}Times that utilization was 80 percent or more for network interfaces${NORMAL}\n">> /logs/health/$pants; 
		printf "${UNDERLINE}%-16s%-10s%-9s%-11s%-10s%-10s%-10s%-10s%-10s%-9s\n" "time" "IFACE" "rxpck/s" "txpck/s" "rxkB/s" "txkB/s" "rxcmp/s" "txcmp/s" "rxmcst/s" "%ifutil${NORMAL}">> /logs/health/$pants; # Prints header for this section
		while read -r high_mem; #while theres lines in this file
		do
			printf "$high_mem\n" >> /logs/health/$pants;	# Print each line in file
		done < <(sar -n DEV -f /var/log/sa/sa$(date +%d -d yesterday) | egrep -v lo | sed 1,5d | awk 'NR ==1 || $11>=80.00 { print}') # Stops loop after all lines read	
	fi
echo Script complete! Log file /logs/health/$pants has been created
	
	