#Keith Reagan
#11-20-21
#Script to make a hash and ls -lR diff
#!/usr/bin/bash

pants=$(date +"%A_%B_%d_%Y_%T") 				#Defines var for log file using day of the week, month, day, 24hr time

diffVarHash="/logs/misc/var_hash_$pants.log"	#Defines putting hash difference for /var/log/ into dated file
diffVarLs="/logs/misc/var_ls_$pants.log"		#Defines putting ls difference for /var/log/ into dated file
diffEtcHash="/logs/misc/etc_hash_$pants.log"	#Defines putting hash difference for /etc/ into dated file
diffEtcLs="/logs/misc/etc_ls_$pants.log"		#Defines putting ls difference for /etc/ into dated file

logDir=/logs/misc #Defines var for logDir, used to check to see if dir exists before trying to write to it
[ -d /logs/misc ] || mkdir /logs/misc >/dev/null 2>&1 #Checks to see if log dir exists, if not makes it and sends error to null

#Continuously overwritten files used for comparing day after day
newVarHash="/logs/misc/todays-var-md5sum.log"		#Defines today continuously overwritten file for var hash
oldVarHash="/logs/misc/yesterdays-var-md5sum.log"	#Defines yesterdays continuously overwritten file for var hash
newVarLs="/logs/misc/todays-var-ls.log"				#Defines today continuously overwritten file for var ls
oldVarLs="/logs/misc/yesterdays-var-ls.log"			#Defines yesterdays continuously overwritten file for var ls

newEtcHash="/logs/misc/todays-etc-md5sum.log"		#Defines today continuously overwritten file for etc hash
oldEtcHash="/logs/misc/yesterdays-etc-md5sum.log"	#Defines yesterdays continuously overwritten file for etc hash
newEtcLs="/logs/misc/todays-etc-ls.log"				#Defines today continuously overwritten file for etc ls
oldEtcLs="/logs/misc/yesterdays-etc-ls.log"			#Defines yesterdays continuously overwritten file for etc ls

 
if [ -f $newVarHash ] && [ -f $oldVarHash ]; then 	#If loop checks for existing files
        sudo cat $newVarHash > $oldVarHash 			#Writes over old file with new file
        sudo find /var/log/ -type f -exec md5sum {} + | LC_ALL=C sort > $newVarHash		#Gets updated info for new file
        sudo diff $newVarHash $oldVarHash > $diffVarHash		#Then does a compare, sending the differences to a daily file
        #echo "did if"

else 
        sudo touch $oldVarHash
        sudo find /var/log/ -type f -exec md5sum {} + | LC_ALL=C sort > $newVarHash
        sudo diff $newVarHash $oldVarHash > $diffVarHash
        #echo "did else "
fi 

if [ -f $newVarLs ] && [ -f $oldVarLs ]; then
        sudo cat $newVarLs > $oldVarLs
        sudo ls -lR /var/log/ > $newVarLs
        sudo diff $newVarLs $oldVarLs > $diffVarLs
        #echo "did if"

else 
        sudo touch $oldVarLs
        sudo ls -lR /var/log/ > $newVarLs
        sudo diff $newVarLs $oldVarLs > $diffVarLs
        #echo "did else "
fi 

if [ -f $newEtcHash ] && [ -f $oldEtcHash ]; then
        sudo cat $newEtcHash > $oldEtcHash
        sudo find /var/log/ -type f -exec md5sum {} + | LC_ALL=C sort > $newEtcHash
        sudo diff $newEtcHash $oldEtcHash > $diffEtcHash
        #echo "did if"

else 
        sudo touch $oldEtcHash
        sudo find /var/log/ -type f -exec md5sum {} + | LC_ALL=C sort > $newEtcHash
        sudo diff $newEtcHash $oldEtcHash > $diffEtcHash
        #echo "did else "
fi 

if [ -f $newEtcLs ] && [ -f $oldEtcLs ]; then
        sudo cat $newEtcLs > $oldEtcLs
        sudo ls -lR /etc/ > $newEtcLs
        sudo diff $newEtcLs $oldEtcLs > $diffEtcLs
        #echo "did if"

else 
        sudo touch $oldEtcLs
        sudo ls -lR /etc/ > $newEtcLs
        sudo diff $newEtcLs $oldEtcLs > $diffEtcLs
        #echo "did else "
fi 
