#Keith Reagan
#11-13-21
#Script to detect SSH login issues
#!/usr/bin/bash
#intruder_detect.sh
#Original script from https://www.golinuxcloud.com/linux-login-history/
# AUTHLOG=/var/log/secure
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
UNDERLINE=$(tput smul)
pants=$(date +"%A_%B_%d_%Y_%T").log #Defines var for log file using day of the week, month, day, 24hr time
logDir=/logs/logins #Defines var for logDir, used to check to see if dir exists before trying to write to it
osflavor=$(hostnamectl | grep Operating | awk 'BEGIN{FS=": "}; {print $2}') #Defines flavor of OS var to use with commands
[ -d /logs/logins/ ] || mkdir /logs/logins >/dev/null 2>&1 #Checks to see if log dir exists, if not makes it and sends error to null
sudo touch /logs/logins/$pants #Creating the log file
chmod 755 /logs/logins/$pants #Changing rights to the log file

if [[ "$osflavor" == *"Ubuntu"* ]]; then
	AUTHLOG=/var/log/auth.log
else	
	AUTHLOG=/var/log/secure
fi

if [[ -n $1 ]];
then
        AUTHLOG=$1
        echo Using Log file : $AUTHLOG
fi

# Collect the failed login attempts
FAILED_LOG=/tmp/failed.$$.log
#echo processing failed log #for testing
egrep "Failed pass" $AUTHLOG > $FAILED_LOG

# Collect the successful login attempts
SUCCESS_LOG=/tmp/success.$$.log
#echo processing success log #for testing
egrep "Accepted password|Accepted publickey|keyboard-interactive" $AUTHLOG > $SUCCESS_LOG
OOR_TIME=/tmp/oor_time.$$.log
#echo processing bad timing #for testing
egrep '[[:space:]][0][0-9]\:'  $SUCCESS_LOG > $OOR_TIME
OOR_IPS=/tmp/oor_ips.$$.log
#echo processing bad IP #for testing
egrep -v '192\.168\.187\.' $SUCCESS_LOG > $OOR_IPS

#FAILED_LOG=/home/kreagan/realfail.log                  # Collect the failed login attempts for testing
#SUCCESS_LOG=/home/kreagan/realsecure.log               # Collect the successful login attempts for testing
#OOR_IPS=/home/kreagan/oor_ips.log                              # Collect the successful login attempts for testing
#OOR_TIME=/home/kreagan/oor_time.log                    # Collect the successful login attempts for testing

# extract the users who failed
failed_users=$(cat $FAILED_LOG | awk '{ print $(NF-5) }' | sort | uniq)

# extract the users who successfully logged in
success_users=$(cat $SUCCESS_LOG | awk '{ print $(NF-5) }' | sort | uniq)
success_bad_time=$(cat $OOR_TIME | awk '{ print $(NF-5) }' | sort | uniq)
success_users_bad_ip=$(cat $OOR_IPS | awk '{ print $(NF-5) }' | egrep -v '192\.168\.187\.' | sort | uniq)

# extract the IP Addresses of successful and failed login attempts
failed_ip_list="$(egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" $FAILED_LOG | sort | uniq)"
#echo prcessing failed ip list
success_ip_list="$(egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" $SUCCESS_LOG | sort | uniq)"
#echo processing good ip list
success_bad_ip_list="$(egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" $OOR_IPS | sort | uniq)"
#echo processing bad ip list
success_bad_time_list="$(egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" $OOR_IPS | sort | uniq)"
#echo processing bad timing
# Print the heading
printf "${UNDERLINE}\nLogin log!\n${NORMAL}" > /logs/logins/$pants;
# Loop through IPs and Users who had success.
for ip in $success_ip_list;
do
        printf "\nAll successful sign ins\n">> /logs/logins/$pants;
        printf "${UNDERLINE}%-10s|%-10s|%-10s|%-15s|%-15s|%s\n" "Status" "User" "Attempts" "IP address" "Host" "Time range${NORMAL}" >> /logs/logins/$pants;
        for user in $success_users;
                do
                # Count successful login attempts by this user from this IP
                attempts=`grep $ip $SUCCESS_LOG | grep " $user " | wc -l`

                if [ $attempts -ne 0 ]
                        then
                                first_time=`grep $ip $SUCCESS_LOG | grep " $user " | head -1 | cut -c-16`
                                time="$first_time"
                                if [ $attempts -gt 1 ]
                                        then
                                                last_time=`grep $ip $SUCCESS_LOG | grep " $user " | tail -1 | cut -c-16`
                                                time="$first_time -> $last_time"
                                fi
                        HOST=$(host $ip 8.8.8.8 | tail -1 | awk '{ print $NF }' )
                        printf "%-10s|%-10s|%-10s|%-15s|%-15s|%-s\n" "Success" "$user" "$attempts" "$ip"  "$HOST" "$time"  >> /logs/logins/$pants;
                fi
        done
done

# Loop through IPs and Users who failed.
for ip in $failed_ip_list;
do
        printf "\n${RED}Failed sign in credentials${NORMAL}\n">> /logs/logins/$pants;
        printf "${UNDERLINE}%-10s|%-10s|%-10s|%-15s|%-15s|%s\n" "Status" "User" "Attempts" "IP address" "Host" "Time range${NORMAL}" >> /logs/logins/$pants;
        for user in $failed_users;
                do
                # Count failed login attempts by this user from this IP
                attempts=`grep $ip $FAILED_LOG | grep " $user " | wc -l`
                if [ $attempts -ne 0 ]

                        then
                        first_time=`grep $ip $FAILED_LOG | grep " $user " | head -1 | cut -c-16`
                        time="$first_time"
                        if [ $attempts -gt 1 ]
                                then
                                last_time=`grep $ip $FAILED_LOG | grep " $user " | tail -1 | cut -c-16`
                                time="$first_time -> $last_time"
                        fi
                        HOST=$(host $ip 8.8.8.8 | tail -1 | awk '{ print $NF }' )
                printf "${RED}%-10s${NORMAL}|%-10s|%-10s|%-15s|%-15s|%-s\n" "Failed!" "$user" "$attempts" "$ip"  "$HOST" "$time" >> /logs/logins/$pants;
                fi
        done
done

#Display successful logins from between the hours of midnight and 6am
File=$OOR_TIME
printf "\n${RED}Signed in successfully out of normal time range!${NORMAL}\n">> /logs/logins/$pants;
while read bad_time;
do
        printf "$bad_time\n" >> /logs/logins/$pants;
done < $OOR_TIME;

#Display successful logins from abnormal IPs
File=$OOR_IPS;
printf "\n${RED}Signed in successfully under an abby normal IP!${NORMAL}\n">> /logs/logins/$pants;
while read bad_ip;
do
        printf "$bad_ip\n" >> /logs/logins/$pants;
done < $OOR_IPS;

#Clean up the temp files
rm -f $FAILED_LOG ########uncomment later########
rm -f $SUCCESS_LOG ########uncomment later########
rm -f $OOR_IPS
rm -f $OOR_TIME
