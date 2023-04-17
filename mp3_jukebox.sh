#!bin/bash
# i. Author: Jenna Graham
# ii. Date Created: April 16, 2023
# Description of Shell Script: Shell script to create and run an MP3 Jukebox
#       Credits:
#       Music Player: mpg123
#       Original Menu Box adapted from: https://bash.cyberciti.biz/guide/A_menu_box

# Store menu options selected by the user in a temporary file
INPUT=/tmp/menu.sh.$$

# Temporary storage file for displaying command output
OUTPUT=/tmp/output.sh.$$

# Variables to hold user file selection
PLAY="/home/jgraham/Music/" # Holds user selection, or defaults to home music folder
TEMPPLAY=""  # Variable for play dialog box

# Shuffle options
SHUFFLETEXT="Off" # Shuffle defaul is off
SHUFFLEARG=""     # Variable to hold shuffle argument of on or off

# Trap and delete the temp files made when menu box used
trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

# Display output using msgbox, setting height, width and title defaults using variables 1, 2 & 3
function display_output(){
        local h=${1-10}
        local w=${2-51}
        local t=${3-Output}
        dialog --backtitle "MP3 Jukebox Application - Jenna Graham W0295111" --title "${t}" --clear --msgbox "$(<$OUTPUT)" ${h} ${w}
}

# Play a file from the folder the user has selected
# Uses an if statement to figure out if the file has an .mp3 extension.
# If so, tells mpg123 to play the file
# If not, it assumes the file is a folder containing mp3s and dumps them to a temporary playlist
# Tells mpg123 to play the temp playlist, passing in the shuffle variable
function play_file(){
        mp3file=${PLAY: -4}
        clear
        if [[ "$mp3file" == ".mp3" ]]
        then
                mpg123 "$PLAY" 2>&1
        else
                find $PLAY -type f > /tmp/playlist
                mpg123 $SHUFFLEARG -@ /tmp/playlist 2>&1
        fi
}

# Allow user to select a music folder to play from
# Uses an if statement to determine if the user selected a file, or selected cancel
# If selected a file (or folder), play
# If selected cancel, print error message that displays previous file selection (or default if none)
function file_selection(){
        #Give user instructions displayed in a msg box
        echo "\nPressing < OK > will bring you to the File Selection box\n\nFILE SELECTION BOX NAVIGATION:\n\nUse the up/down arrows to navigate\n\nPress the SPACEBAR twice to select a directory\n\nPress the SPACEBAR once to select a file\nThe file path selected appears at the bottom of the screen\n\nPress ENTER to confirm your choice" > $OUTPUT
        display_output 18 65 "FILE SELECTION"
        TEMPPLAY=$(dialog --stdout --title "Choose an MP3 or Folder Containing MP3s" --fselect $PLAY 14 48)
        result=$?
        if [[ result -eq 0 ]]
        then
                PLAY=$TEMPPLAY
                echo "\n\n${PLAY} file chosen." >$OUTPUT
        else
                echo "\n\nFile Selection Cancelled, retaining ${PLAY}" > $OUTPUT
        fi
        display_output 9 65 "FILE SELECTED"
}

# Toggle on shuffle mode for mp3s
# Shuffles if on using mpg123s built-in random play argument (-Z)
function shuffle_toggle(){
        if [[ "$SHUFFLETEXT" == "Off" ]]
        then
                SHUFFLETEXT="On"
                SHUFFLEARG="-Z"
        else
                SHUFFLETEXT="Off"
                SHUFFLEARG=""
        fi
}

# Set infinite loop for the menu box
while true
do

### Main Menu Box Display ###
#Title at top of screen when script is run, followed by title at top of menu box and instructions for navigating

dialog --clear  --backtitle "MP3 Jukebox Application - Jenna Graham W0295111" \
--title "[ MP3 JUKEBOX ]" \
--nocancel \
--menu "You can use the UP/DOWN arrow keys \n\
or the number keys 1-9 to choose an option.\n\
Choose your task and press ENTER\n\
\n\
Current Directory / File: $PLAY\n\
Shuffle Mode: $SHUFFLETEXT\n\
\n\
" 16 100 8 \
File_Selection "Pick the music folder to play" \
Play_MP3 "Plays an MP3 file" \
Shuffle_Mode "Toggles shuffle mode on/off" \
Exit "Exit to the shell" 2>"${INPUT}"
menuitem=$(<"${INPUT}")

# Case statement for options in menu box. User chooses an option and the associated function executes.
case $menuitem in
        File_Selection) file_selection;;
        Play_MP3) play_file;;
        Shuffle_Mode) shuffle_toggle;;
        Exit) clear; echo "Exited MP3 Jukebox"; echo ""; break;;
esac
done

# Delete any temp files from the input and output folders after the users choice has been executed
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT