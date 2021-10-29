#Keith Reagan
#10-16-21
#Script to dump network info
#!/usr/bin/bash

pants=$(date +"%A_%B_%d_%Y_%T").log #Defines var for log file using day of the week, month, day, 24hr time
currentUser=$(whoami) #Defines currentUser var for use on greeting the user
hostMachine=$(hostname) #Defines hostMachine var for use on greeting the user
#Below line defines hostip var for use throughout script by scraping ip addr command
hostip=$(ip addr | grep inet | awk '/inet[[:space:]]192/ {print $2}' | awk 'BEGIN{FS="/"}; {print $1}')
logDir=/logs/netdump #Defines var for logDir, used to check to see if dir exists before trying to write to it
osflavor=$(hostnamectl | grep Operating | awk 'BEGIN{FS=": "}; {print $2}') #Defines flavor of OS var to use with commands

	clear #Clears the screen for a cleaner look
	[ -d /logs/netdump/ ] || mkdir /logs/netdump >/dev/null 2>&1 #Checks to see if log dir exists, if not makes it and sends error to null         
	#echo $osflavor #created as a standalone check
	echo #Giving some space
	echo
	echo
	echo
	sudo touch /logs/netdump/$pants #Creating the log file
	chmod 755 /logs/netdump/$pants #Changing rights to the log file
	#Below line greets the user with their name, the host they're logged into, os version, and the hosts IP. It then starts appending to the log file
	echo -e "\e[34mGreetings $currentUser, I'm going to run a few commands on your host machine $hostMachine running $osflavor with the IP $hostip\e[0m " | tee -a /logs/netdump/$pants
	echo | tee -a /logs/netdump/$pants #Giving some space for cleaner look
	echo -e "\e[1;4m Your current IP address is: $hostip \e[0m" | tee -a /logs/netdump/$pants #Tells user current hosts IP underlined
	echo  | tee -a /logs/netdump/$pants
	#Begin fetching dedault gateway and subnet mask info
	echo -e "\e[1;4m Printing default gateway and subnet... \e[0m" | tee -a /logs/netdump/$pants
	if [[ "$osflavor" == *"Ubuntu"* ]]; then #Checks OS flavor, will determine what command to run next and suggest for install if not located
	#If the OS is Ubuntu, script will check if netstat is installed by using dpkg and cleaning up the command until it just prints "netstat" as the result
	netstatInstalled=$(sudo dpkg -s netstat >/dev/null 2>&1 | awk '/Package/ {print $2}') 
		if [[ "$netstatInstalled" == *"netstat"* ]]; then #If command print check comes back with "netstat" 
			netstat -r | sed -n '2,4p' | awk '{print $1, "\t" $2, "\t" $3}' | tee -a /logs/netdump/$pants #Prints out default gateway and subnet
		else #If netstat isn't install, it will error and let you know it is not and give you the command on how to install it
			echo -e "netstat is \e[41mNOT\e[0m installed! Use \e[96msudo apt-get install netstat -y\e[0m to install. Skipping process for now" | tee -a /logs/netdump/$pants
		fi
	else #If the OS is Centos, script will check if netstat aka net-tools is installed, if not suggest you do
	netstatInstalled=$(sudo dnf info net-tools | grep net-tools | awk '/Name/ {print $3}') 
		if [[ "$netstatInstalled" == *"net-tools"* ]]; then
			netstat -r | sed -n '2,4p' | awk '{print $1, "\t" $2, "\t" $3}' | tee -a /logs/netdump/$pants #Prints out default gateway and subnet
		else
			echo -e "netstat is \e[41mNOT\e[0m installed! Use \e[96msudo dnf netstat\e[0m to install. Skipping process for now" | tee -a /logs/netdump/$pants
		fi
	fi
	#End fetching dedault gateway and subnet mask info
	#Begin firewall check
	echo | tee -a /logs/netdump/$pants
	echo -e "\e[1;4m Checking to see if firewall is running... \e[0m" | tee -a /logs/netdump/$pants
	if [[ "$osflavor" == *"Ubuntu"* ]]; then #Checks OS flavor, will determine what command to run next and suggest for install if not located
	firewalldInstalled=$(sudo dpkg -s ufw | awk '/Package/ {print $2}')
		if [[ "$firewalldInstalled" == *"ufw"* ]]; then
			systemctl status ufw | awk '{ sub(/^[ \t]+/, ""); print }' | grep active | tee -a /logs/netdump/$pants #Checks firewall status
		else
			echo -e "ufw is \e[41mNOT\e[0m installed! Use \e[96msudo apt-get install ufw -y\e[0m to install. Skipping process for now" | tee -a /logs/netdump/$pants
		fi
	else
	firewalldInstalled=$(sudo dnf info firewalld | grep firewalld | awk '/Name/ {print $3}')
		if [[ "$firewalldInstalled" == *"firewalld"* ]]; then
			systemctl status firewalld.service | awk '{ sub(/^[ \t]+/, ""); print }' | grep active | tee -a /logs/netdump/$pants #Checks firewall status
		else
			echo -e "firewalld is \e[41mNOT\e[0m installed! Use \e[96msudo dnf firewalld\e[0m to install. Skipping process for now" | tee -a /logs/netdump/$pants
		fi
	fi
	#End firewall check    
	#Begin fail2ban check
	echo | tee -a /logs/netdump/$pants
	echo -e "\e[1;4m Checking to see if fail2ban is running... \e[0m" | tee -a /logs/netdump/$pants 
	if [[ "$osflavor" == *"Ubuntu"* ]]; then #Checks OS flavor, will determine what command to run next and suggest for install if not located
	fail2banInstalled=$(sudo dpkg -s fail2ban | awk '/Package/ {print $2}') 
		if [[ "$fail2banInstalled" == *"fail2ban"* ]]; then
			systemctl status fail2ban.service | awk '{ sub(/^[ \t]+/, ""); print }' | grep active | tee -a /logs/netdump/$pants #Checks fail2ban status
		else
			echo -e "fail2ban is \e[41mNOT\e[0m installed! Use \e[96msudo apt-get install fail2ban -y\e[0m to install. Skipping process for now" | tee -a /logs/netdump/$pants
		fi
	else
	fail2banInstalled=$(sudo dnf info fail2ban | grep fail2ban | awk '/Name/ {print $3}')
		if [[ "$fail2banInstalled" == *"fail2ban"* ]]; then
			systemctl status fail2ban.service | awk '{ sub(/^[ \t]+/, ""); print }' | grep active | tee -a /logs/netdump/$pants #Checks fail2ban status
		else
			echo -e "fail2ban is \e[41mNOT\e[0m installed! Use \e[96msudo dnf fail2ban\e[0m to install. Skipping process for now" | tee -a /logs/netdump/$pants
		fi
	fi
	#End fail2ban check
	
	echo | tee -a /logs/netdump/$pants
	echo -e "\e[1;4m Printing established ports with traffic... \e[0m" | tee -a /logs/netdump/$pants
	#Below line displays the currently used ports with active traffic
	ss state established | awk '$3 >0 || $4>0{print$0}' | awk 'BEGIN{FS=":"}; {print $1, "\t" $2 "\t" $3}' | sed '$d' | tee -a /logs/netdump/$pants
	#Begin nmap check
	echo | tee -a /logs/netdump/$pants
	echo -e "\e[1;4m Running nmap on local host $hostip ports... this might take a few! \e[0m " | tee -a /logs/netdump/$pants    
	if [[ "$osflavor" == *"Ubuntu"* ]]; then #Checks OS flavor, will determine what command to run next and suggest for install if not located
	nmapInstalled=$(sudo dpkg -s nmap >/dev/null 2>&1 | awk '/Package/ {print $2}')
		if [[ "$nmapInstalled" == *"nmap"* ]]; then
			nmap $hostip -sV | tee -a /logs/netdump/$pants #Runs nmap on the local machine
		else
			echo -e "nmap is \e[41mNOT\e[0m installed! Use \e[96msudo apt-get install nmap -y\e[0m to install. Skipping process for now" | tee -a /logs/netdump/$pants
		fi
	else
	nmapInstalled=$(sudo dnf info nmap | grep nmap | awk '/Name/ {print $3}')
		if [[ "$nmapInstalled" == *"nmap"* ]]; then
		nmap $hostip -sV | tee -a /logs/netdump/$pants #Runs nmap on the local machine
		else
			echo -e "nmap is \e[41mNOT\e[0m installed! Use \e[96msudo dnf nmap\e[0m to install. Skipping process for now" | tee -a /logs/netdump/$pants
		fi
	fi		
	#End nmap check		
		echo "Thanks for running netdump! Your logfile $logDir/$pants has been created" | tee -a /logs/netdump/$pants #Complete append to log file and prints name on screen