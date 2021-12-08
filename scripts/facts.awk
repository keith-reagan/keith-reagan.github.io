#Keith Reagan
#10/17/21
#!/usr/bin/awk -f
BEGIN{
    FS="[:]" # Declare that the field separator will be a colon, will take place all through the script with being put in the BEGIN statement
}
{
lastname=$1;	# Declare var "lastname", associating it with the first column
total=$3+$4+$5;	# Declare var "sum", adding columns 3 through 5 together
    if($1 ~ /Took/){ # If regex search finds "Took" in column 1 the following will happen -
		# Below %s is the spacing with \n breaking to a new line. %-30s making the 2nd column print 30 spaces after the first one does for clean formatting
        printf "%-30s $%s\n", lastname,total # Prints the name of the Tooks followed by their total campaign contributions
        }
    }
{
bullroarer=$1;	# Declare var "bullroarer" associating it with the first column
    if ($1 ~ /Bullroarer/){ # Prints "Bullroarer"'s contributions # Check file for Bullroarer
        printf "%-30s$%-6s$%-6s $%s\n", bullroarer,$3,$4,$5  # Print Bullroarer contributions using columns 3 through 5
    }
}
{
    if($5>175){ # Print those who contributed more than $175 in the last contribution
        printf "%s %s\n","Paid more than $175 on their last contribution: ", $1
    }
}