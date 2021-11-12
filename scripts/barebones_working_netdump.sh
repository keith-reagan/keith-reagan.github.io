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
            if [[ "$osflavor" == *"Ubuntu"* ]]; then
                echo "youre running ubuntu $osflavor "
                else
                echo "youre not running ubuntu $osflavor"
            fi

        echo #Giving some space
        echo
        sudo touch /logs/netdump/$pants #Creating the log file
        chmod 755 /logs/netdump/$pants #Changing rights to the log file
        #Below line greets the user with their name, the host they're logged into, os version, and the hosts IP. It then starts appending to the log file
        echo -e "\e[34m Greetings $currentUser, I'm going to run a few commands on your host machine $hostMachine running $osflavor with the IP $hostip\e[0m " | tee -a /logs/netdump/$pants
        echo | tee -a /logs/netdump/$pants #Giving some space for cleaner look
        echo -e "\e[1;4m Your current IP address is: $hostip \e[0m" | tee -a /logs/netdump/$pants #Tells user current hosts IP underlined
        echo  | tee -a /logs/netdump/$pants
        echo -e "\e[1;4m Printing default gateway and subnet... \e[0m" | tee -a /logs/netdump/$pants
		netstat -r | sed -n '2,4p' | awk '{print $1, "\t" $2, "\t" $3}' | tee -a /logs/netdump/$pants #Prints out default gateway and subnet
        echo | tee -a /logs/netdump/$pants
        echo -e "\e[1;4m Checking to see if firewall is running... \e[0m" | tee -a /logs/netdump/$pants
		systemctl status firewalld.service | awk '{ sub(/^[ \t]+/, ""); print }' | grep active | tee -a /logs/netdump/$pants #Checks firewall status
        echo | tee -a /logs/netdump/$pants
		echo -e "\e[1;4m Checking to see if fail2ban is running... \e[0m" | tee -a /logs/netdump/$pants
        systemctl status fail2ban.service | awk '{ sub(/^[ \t]+/, ""); print }' | grep active | tee -a /logs/netdump/$pants #Checks fail to ban status
        echo | tee -a /logs/netdump/$pants
        echo -e "\e[1;4m Printing established ports with traffic... \e[0m" | tee -a /logs/netdump/$pants
        #Below line displays the currently used ports with active traffic
        ss state established | awk '$3 >0 || $4>0{print$0}' | awk 'BEGIN{FS=":"}; {print $1, "\t" $2 "\t" $3}' | sed '$d' | tee -a /logs/netdump/$pants
        echo | tee -a /logs/netdump/$pants
        echo -e "\e[1;4m Running nmap on local host $hostip ports... this might take a few! \e[0m " | tee -a /logs/netdump/$pants    
		nmap $hostip -sV | tee -a /logs/netdump/$pants #Runs nmap on the local machine	
		echo "Thanks for running netdump! Your logfile $logDir/$pants has been created" | tee -a /logs/netdump/$pants