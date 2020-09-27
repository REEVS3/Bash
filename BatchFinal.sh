#!/bin/bash

if [[ $# > 0 ]]; then
    file=$1
    if [[ $? -eq 0 ]]; then
        echo "Argument Supplied Is A File "
                savedfile=$file
        #Checks if argument was a local file


        if [[ ! -f $file ]]
         then
            #Checks if link
            echo $file | grep "http*"

            #If filename is a link
            if [[ $? -eq 0 ]]
            then
            echo "Downloading..."

            wget $file
                #checking for download
                if [[ $? -eq 0 ]]
                then
                    savedfile="users.csv"
                    echo "File downloaded "
                else
                    echo "File downlaod Fail"
                    exit 1
                fi
            else
                echo "Incorect Link"
                exit 1
            fi
        fi
    else
        echo "Error: The argument not a file"
                echo "Closing"
        exit 1
    fi
fi
echo "Loading...... "
makeUsers(){
        IFS=";"
        file=$savedfile
        i=0

		##Read CSV File with breaks between ;
		
        while read col1 col2 col3 col4
        do
                ((i++))
        if [[ $i > 1 ]]
        then
			##Splits Name form @ symbol then gets fisrt name behind .
                Fname=$(echo "$col1" | awk -F '@' '{print $1}' ) 
                Fname=$(echo "$Fname" | awk -F '.' '{print $1}')
                Fname=${Fname:1} ##Frist Char From Variable

			##Splits Name form . symbol then gets last name behind @ .	
                Lname=$(echo "$col1" | awk -F '.' '{print $2}')
                Lname=$(echo "$Lname" | awk -F '@' '{print $1}' )
			##Joins String together
                Name="$Fname$Lname"
			##Gets Password removes slashes and joins 
             
                p1=$(echo "$col2" | awk -F '/' '{print $1}')
                p2=$(echo "$col2" | awk -F '/' '{print $2}')
                p3=$p2$p1

				##Creates Group and Sudo Variablle after , and ,
                group=$(echo "$col3" | awk -F ',' '{print $2}')
                g=$(echo "$col3" | awk -F ',' '{print $1}')

             
                Folder=$(echo "$col4")

              
		##If User Group not null 
        if ! [[ -z "$group" ]]
        then
                     cat /etc/group | grep $group ##Checking if Group Exists 
                if [[ $? > 0 ]]
                then
                         groupadd $group ##Add Group 
                else
						echo ""
                        echo "Group Already Exists"
                fi
        fi
		
		##Look For Home Folder 
		
        find /home$Folder > /dev/null 2>&1
        if ! [[ $? -eq 0 ]]
        then
         mkdir /home$Folder ##Make Directory 
         chmod 760 /home$Folder
        if [[ $? -eq 0 ]]
        then
				echo ""
                echo "Made /home$Folder"
        fi
         chown root:$group /home$Folder ##Give Group Permmison for folder 
         if [[ $? -eq 0 ]]
        then
				echo ""
                echo "$group owns $Folder"
        fi

        else
				echo ""
                echo "$group  $Folder exists"
        fi

        if [[ -z "$group" ]] ##if user doesnt have a group
        then
        useradd -m -d /home/$Name -s /bin/bash  $Name 
                if [[ $? = 0 ]]
                then
				echo ""
                echo "Created user $Name"

                else
				echo ""
                echo "$Name Exists"

                fi

        else  useradd -m -d /home/$Name -s /bin/bash  $Name -G $g,$group ##if user does have a group
        fi
                 echo "$Name:$p3" | sudo chpasswd
                if [[ $? -eq 0 ]]
                then
				echo ""
                echo "Changed password"
                fi



        ln -s /home$Folder /home/$Name/shared ##Create Link to shared folder 
         if [[ $? -eq 0 ]]
        then
                echo "Made link in /home$Folder to /home/$Name/shared"
        else
		echo ""
        echo "link exists"
        fi


		##Set password to expire 
        passwd -e $Name
        echo "password set to  expire"







fi










        done < $file
}
makeUsers $1
