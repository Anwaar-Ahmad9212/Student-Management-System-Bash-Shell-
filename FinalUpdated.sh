#!/bin/bash


# files to keep the data and credentials of students
credentials_file="credentials.txt"
studentCount=0
filename="studentfile.txt"
#-----------------------------------------------------------------------------------------
# Function to dynamically update student count
function updateStudentCount() 
{    if [[ -f "$filename" ]]; then
        studentCount=$(wc -l < "$filename")
    else
        studentCount=0
    fi
}
#--------------------------------------------------------------------------------------------
# Function to add a new student
function addNewStudent() {
    #updating student count first
    updateStudentCount  
    # limit reached 
    if [[ "$studentCount" -ge 20 ]]; then
        echo "You cannot insert any more students (Limit: 20)."
        return 0
    fi

    read -p "Enter Student Name : " studentName
    read -p "Enter Roll Number : " rollNumber

    if grep -q ",$rollNumber," "$filename"; then
        echo "A student with Roll Number $rollNumber already exists!"
        return 1
    fi

    # Append student data (keeping only numerical subject scores)
    echo "$studentName,$rollNumber,Unknown,0.0,0.0,0.0,0.0" >> "$filename"

    echo "Student Successfully Added!"
    updateStudentCount 
    return 0
}
#-------------------------------------------------------------------------------------
# Function to remove a student
function removeStudent() {
    updateStudentCount 

    read -p "Enter Roll Number of student to remove: " rollNumber
    # if not found
    if ! grep -q ",$rollNumber," "$filename"; then
        echo "No student found with Roll Number $rollNumber!"
        return 1
    fi

    # Remove the student's entry
    grep -v ",$rollNumber," "$filename" > temp.txt && mv temp.txt "$filename"

    echo "Student with Roll Number $rollNumber has been removed."
    updateStudentCount 
    return 0
}
#---------------------------------------------------------------------------------------
# printing the grade based on the numbers in respective course
get_grade() {
    local num=$1

  num=$(awk "BEGIN {print int($num)}")
    if (( num >= 96 && num <= 100 )); then
        echo "A+"
    elif (( num >= 92 && num <= 95 )); then
        echo "A"
    elif (( num >= 87 && num <= 91 )); then
        echo "A-"
    elif (( num >= 83 && num <= 86 )); then
        echo "B+"
    elif (( num >= 78 && num <= 82 )); then
        echo "B"
    elif (( num >= 73 && num <= 77 )); then
        echo "B-"
    elif (( num >= 69 && num <= 72 )); then
        echo "C+"
    elif (( num >= 64 && num <= 68 )); then
        echo "C"
    elif (( num >= 60 && num <= 63 )); then
        echo "C-"
    elif (( num >= 55 && num <= 59 )); then
        echo "D+"
    elif (( num >= 50 && num <= 54 )); then
        echo "D"
    else
        echo "F"
    fi
}
#--------------------------------------------------------------------------------------------
#Function to calculate CGPA
get_gpa() {
    # printing the gpa based on the 
    local num=$1
    num=$(awk "BEGIN {print int($num)}") 

    if (( num >= 96 && num <= 100 )); then
        echo "4.0"
    elif (( num >= 92 && num <= 95 )); then
        echo "3.9"
    elif (( num >= 87 && num <= 91 )); then
        echo "3.7"
    elif (( num >= 83 && num <= 86 )); then
        echo "3.3"
    elif (( num >= 78 && num <= 82 )); then
        echo "3.0"
    elif (( num >= 73 && num <= 77 )); then
        echo "2.7"
    elif (( num >= 69 && num <= 72 )); then
        echo "2.3"
    elif (( num >= 64 && num <= 68 )); then
        echo "2.0"
    elif (( num >= 60 && num <= 63 )); then
        echo "1.7"
    elif (( num >= 55 && num <= 59 )); then
        echo "1.3"
    elif (( num >= 50 && num <= 54 )); then
        echo "1.0"
    else
        echo "0.0"
    fi
}

# Function to calculate CGPA from three subject marks
calculate_gpa() {
    #calculating gpa based on three subjects
    local marks1=$1
    local marks2=$2
    local marks3=$3

    gpa1=$(get_gpa "$marks1")
    gpa2=$(get_gpa "$marks2")
    gpa3=$(get_gpa "$marks3")

    cgpa=$(awk "BEGIN {print ($gpa1 + $gpa2 + $gpa3) / 3}")
echo "$cgpa"
 
}
#------------------------------------------------------------------------------------------------------------------
#Function to sort data according to requiments
sort_ascend()
{
# if a then ascending order otherwise descending order.
echo "Tell us for which criteria you want to display the sorted data press ( A for Ascending , D for Desending)"
read val
if [ $val == "a" ] || [ $val == "A" ]
then
val=n

else val=nr
fi

echo "------------------------------------------------------"
echo -e "Name\t\t| Roll\t| Class   | Math | OS  | DB  | GPA"
echo "------------------------------------------------------"


sort -t',' -k7,7"$val" "$filename" | while IFS=',' read -r name roll class math os db gpa; do
    printf "%-16s | %-4s | %-7s | %-4s | %-3s | %-3s | %-4s \n" "$name" "$roll" "$class" "$math" "$os" "$db" "$gpa"
done

echo "------------------------------------------------------"

}
#-----------------------------------------------------------------------------------------
#Function to view passed students
passed_std()
{
    # set the threshold to 2.0 to declare pass or fail.
threshold=2.0
echo "------------------------------------------------------"
echo -e "Name\t\t| Roll\t| Class   | Math | OS  | DB  | GPA"
echo "------------------------------------------------------"

while IFS=',' read -r name roll class math os db gpa; do
    if (( $(echo "$gpa >= $threshold" | bc -l) )); then
        printf "%-16s | %-4s | %-7s | %-4s | %-3s | %-3s | %-4s \n" "$name" "$roll" "$class" "$math" "$os" "$db" "$gpa"
    fi
done < "$filename"

echo "------------------------------------------------------"
}
#--------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------
#Function to view passed students
failed_std()
{
    #threshold for failed students
threshold=2.0
echo "------------------------------------------------------"
echo -e "Name\t\t| Roll\t| Class   | Math | OS  | DB  | GPA"
echo "------------------------------------------------------"

while IFS=',' read -r name roll class math os db gpa; do
    if (( $(echo "$gpa < $threshold" | bc -l) )); then
        printf "%-16s | %-4s | %-7s | %-4s | %-3s | %-3s | %-4s \n" "$name" "$roll" "$class" "$math" "$os" "$db" "$gpa"
    fi
done < "$filename"

echo "------------------------------------------------------"
}
#--------------------------------------------------------------------------------------
# Function to view student details
function view_details() {
    # view details studnet
    source="$1"

    data=$(grep "$source" "$filename")

    if [[ -z "$data" ]]; then
        echo "No student found with Roll Number or Name: $source"
        return 1
    fi

    IFS=',' read -r name roll_number class math os db cgpa <<< "$data"
    # printing the information of the studemt
    echo "Name        : $name"
    echo "Roll Number : $roll_number"
    echo "Class       : $class"
    echo "Math Score  : $math"
    echo -n "Math Grade : "
    get_grade $math
    echo "OS Score    : $os"
    echo -n "Os Grade : "
    get_grade $os
    echo "DB Score    : $db"
    echo -n "Db Grade : "
    get_grade $db
    echo "CGPA        : $cgpa"
}
#-----------------------------------------------------------------------------------
# update function
function update_student() {
    echo "Enter Roll Number of student to update: "
    read roll

    # Get the line number of the student entry
    line_num=$(grep -n ",$roll," "$filename" | cut -d: -f1)

    if [[ -z "$line_num" ]]; then
        echo "No student found with Roll Number $roll!"
        echo ""
	return 1
    fi

    # Extract student data
    data=$(sed -n "${line_num}p" "$filename")
    IFS=',' read -r name roll_number class math os db cgpa <<< "$data"
	echo ""
    echo "1: Change Name"
    echo "2: Change Class"
    echo "3: Change Marks"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            read -p "Enter new Name: " name
            echo "Name changed to $name"
		echo ""
            ;;
        2)
            read -p "Enter new Class: " class
            echo "Class changed to $class"
	   echo ""
            ;;
        3)
            echo "1: Change Math marks"
            echo "2: Change OS marks"
            echo "3: Change DB marks"
            read -p "Enter your choice: " marks_choice
	echo ""
            case $marks_choice in
                1)
                    read -p "Enter new Math marks: " math
                    echo "Math marks changed to $math"
                    ;;
                2)
                    read -p "Enter new OS marks: " os
                    echo "OS marks changed to $os"
                    ;;
                3)
                    read -p "Enter new DB marks: " db
                    echo "DB marks changed to $db"
                    ;;
                *)
                    echo "Invalid choice for marks"
                    return 1
                    ;;
            esac
            ;;
        *)
            echo "Invalid choice"
            return 1
            ;;
    esac

    # Auto-update CGPA after changing marks
 total_marks=$(echo "$math + $os + $db" | bc)
    new_cgpa=$(echo "scale=2; ($total_marks / 300) * 4" | bc)
    # Update the student record in the file
    new_data="$name,$roll_number,$class,$math,$os,$db,$new_cgpa"
    sed -i "${line_num}s/.*/$new_data/" "$filename"

    echo "Student record updated successfully! CGPA is now $new_cgpa"
	echo ""
}





#---------------------------------------------------------------------------------------------

function teacherMenu(){
	while true; do
	echo "-----------------------------------"
	echo "Enter 1 to add student."
	echo "Enter 2 to remove student."
	echo "Enter 3 to update student."
	echo "Enter 4 to view Student details."
	echo "Enter 5 to generate report."
	echo "Enter 6 to list Passed students."
	echo "Enter 7 to list Failed students."
	echo "Enter 8 to logout..."
	echo "-----------------------------------"
	read option

case $option in
	# calling the add new student function here
1) clear
	addNewStudent ;;

	#calling the remove studnet function here
2) clear 
	removeStudent ;;

	# calling the update function here
3) clear 
	update_student ;;

4) clear 
	# calling the view student  function here
	echo "Enter student to view details (Name or Roll Number):"
	read var
	view_details "$var"
				;;

	# calling the genearte report function here
5) clear
 	sort_ascend;;

6) clear
 	passed_std ;;

7) clear
         failed_std ;;

#exiting the teacher MENu..
8)
	break ;;


*)
	clear
echo "Invalid input." ;;

	esac

	done


}
#-----------------------------------------------------------------------
function viewStudentDetails() {
    rollNumber=$1

    data=$(grep ",$rollNumber," "$filename")
	 if [[ -z "$data" ]]; then
        echo " No student found with Roll Number $rollNumber!"
        return
    fi
    IFS=',' read -r name roll_number class math os db cgpa <<< "$data"

    echo "----------------------------------"
    echo "Student Details"
    echo "----------------------------------"
    echo "Name        : $name"
    echo "Roll Number : $roll_number"
    echo "Class       : $class"
    echo "Math Marks  : $math"
    echo "OS Marks    : $os"
    echo "DB Marks    : $db"
    echo "CGPA        : $cgpa"
    echo "----------------------------------"
}

# Function to Change Password
function changePassword() {
    rollNumber=$1

    echo "You must change your default password."
    read -s -p "Enter New Password: " newPassword
    echo ""
    read -s -p "Confirm New Password: " confirmPassword
    echo ""

    if [[ "$newPassword" != "$confirmPassword" ]]; then
        echo "Passwords do not match. Try again."
        return 1
    fi

    # Update credentials file
    sed -i "/^$rollNumber,/d" "$credentials_file"  # Remove old entry
    echo "$rollNumber,$newPassword" >> "$credentials_file"

    echo "Password successfully updated!"
    return 0
}

# Function for Student Login
function studentLogin() {
    read -p "Enter your Roll Number: " rollNumber
    read -s -p "Enter your Password: " studentPassword
    echo ""

    # Check if student exists in student file
    if ! grep -q ",$rollNumber," "$filename"; then
        echo "No student found with Roll Number $rollNumber!"
        return 1
    fi

    storedPassword=$(grep "^$rollNumber," "$credentials_file" | cut -d',' -f2)

    if [[ -z "$storedPassword" ]]; then
        storedPassword="123"  # Default password for first login
    fi

    # Validate password
    if [[ "$studentPassword" != "$storedPassword" ]]; then
        echo "Incorrect Password!"
        return 1
    fi

    # If first-time login, ask to change password
    if [[ "$storedPassword" == "123" ]]; then
        changePassword "$rollNumber"
    fi

    echo "Login Successful!"
    viewStudentDetails "$rollNumber"
}

#------------------------------------------------------------------------
function studentMenu(){

	echo ".......Student Menu........ "
	studentLogin
}
#----------------------------------------------------------------------------

	adminName="admin"
	password="123"
    echo "========================================"
    echo "      STUDENT MANAGEMENT SYSTEM"
    echo "========================================"
    echo "  1. Login as a Teacher"
    echo "  2. Login as a Student"
    echo "  3. Exit"
    echo "========================================"
    read -p " Enter your choice: " option1

	if [[ "$option1" == 1 ]]; then
	
	read -p "Enter UserName :  " name
	read -s -p "Enter password : " pass

		if [[ $name != $adminName || $pass != $password ]]; then

		echo "No such User Found..... "
		echo "Exiting the Program......"
		exit 1
		fi
	echo ""
	echo "Login successfull......"
	# transferring control to the teacher.....
	teacherMenu
	elif [[ "$option1" == 2 ]]; then
	# student can also login and then view their details

	studentMenu

	elif [[ "$option1" == 3 ]]; then
	echo "Existing the programmmmm....."
	exit 0
	else
	echo "Invalid input."

	fi
