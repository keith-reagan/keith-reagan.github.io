#Keith Reagan
#10/17/21
#!/usr/bin/awk -f
BEGIN{
    FS="[:]"	# Declare that the field separator will be a colon, will take place all through the script with being put in the BEGIN statement
}
{
lastname=$1;
total=$3+$4+$5;
	if($1 ~ /Took/){ # Prints the name of the Tooks followed by their total campaign contributions
            # "i" is the array key, each time the it loops the entry will be added to the array
            i++
            # Assign value to array position "i" in array "tooks", sprintf will hold this info and not print to the screen 
            tooks[i]=sprintf("%-30s $%s",lastname,total) # Formatting with %s to give 30 spaces until it prints the total
		}
	}
{
bullroarer=$1;
	if ($1 ~ /Bullroarer/){ # Prints "Bullroarer"'s contributions
	        # "i" is the array key, each time the it loops the entry will be added to the array
	        j++
	        # Assign value to array position "j" in array "bullroarers"
		    bullroarers[j]=sprintf("%-30s$%-6s$%-6s $%s",bullroarer,$3,$4,$5)
		}
	}
{
	if($5>175){ #to print those who contributed more than $175 in the last contribution
	    # "i" is the array key, each time the it loops the entry will be added to the array
	    k++
		# Assign value to array position "k" in array "overs" 
		overs[k]=sprintf($1)
	}
}
# The END statement will print out the arrays one by one in a clean format and only once unlike in the main body
END {
	printf "\033[1;4mTotal contributions from the Tooks:\033[0m\n"
	# Starting at 0, run the array "i" array until it reaches the last entry, incrementing each time the for loop passes through
    for (position = 0; position <= i; position++) {
        # Print the "tooks" array at array key "position"
        print tooks[position]
    }
	printf "\n\033[1;4mAll contributions from Bullroarer:\033[0m\n"
   # Starting at 0, run the array "j" array until it reaches the last entry, incrementing each time the for loop passes through
    for (position = 0; position <= j; position++) {
        # Print the "bullroarers" array at array key "position"
        print bullroarers[position]
    }
	printf "\n\033[1;4mPaid more than $175 on their last contribution:\033[0m\n"
    # Starting at 0, run the array "k" array until it reaches the last entry, incrementing each time the for loop passes through
    for (position = 0; position <= k; position++) {
        # Print the "overs" array at array key "position"
        print overs[position]
    }
}