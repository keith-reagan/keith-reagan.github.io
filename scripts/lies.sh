#Keith Reagan
#12/8/21
#!/usr/bin/bash
NORMAL=$(tput sgr0)		# Var for removing formatting if there is any 
UNDERLINE=$(tput smul)	# Var for underlining words
# Print header
printf "\n${UNDERLINE}Total contributions from the Tooks:${NORMAL}\n"
# Find each person with the last name Took and get their first name, piping into printing first name and sum of contributions
awk -F":" '/Took/ {print $1" "$3" "$4" "$5 }' AwkLab.data  | awk '{print $1" $" $2+$3+$4}'
# Print header
printf "\n${UNDERLINE}All contributions from Bullroarer:${NORMAL}\n"
# Find Bullroarer and display each contribution
awk  '/Bullroarer/ {print $2" "$3" "$4" "$5 }' AwkLab.data  | awk -F":" '{print $1" $"$3" $"$4" $"$5 }'
# Print header
printf "\n${UNDERLINE}Paid more than 175 on their last contribution:${NORMAL}\n"
# Find anyone that contributed more than 175 on their last contribution
awk -F":" '$5 >175{print $1}' AwkLab.data