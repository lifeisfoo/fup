#!/bin/sh

#########################################################################
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#########################################################################

#[Author] Alessandro Miliucci <lifeisfoo@gmail.com>
#[Website] Alessandro Miliucci <http://forkwait.net>
#[Project Website] https://github.com/lifeisfoo/fup
#[Year] 2013

##############################################################################
# EXAMPLE CONFIGURATION                                                      #
#                                                                            #
# Place these variables assignement in a .fup file in your project directory #
#                                                                            #
# SSH_USR_HOST=user@host                                                     #
# REMOTE_DIR=public_html/plugins                                             #
#                                                                            #
## OPTIONAL CONFIGURATION                                                    #
##                                                                           #
## SSH_PORT=21                                                               #
## TMP_DIR=/tmp                                                              #
## ARCHIVE_NAME=fup-to-upload.tar.bz2                                        #
## comma separated (no spaces)                                               #
## vcs directories and files are excluded by default. See tar man pages.     #
## EXCLUDED_DIRS=compiler                                                    #
## comma separated (no spaces)                                               #
## backup files are excluded by default. See tar man pages.                  #
## EXCLUDED_FILES=js/compiled.js                                             #
##############################################################################

# Text color variables
txtund=$(tput sgr 0 1)          # Underline
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldblu=${txtbld}$(tput setaf 4) #  blue
bldwht=${txtbld}$(tput setaf 7) #  white
txtrst=$(tput sgr0)             # Reset

#Common functions

#$0 file path, $1 exit status, $2 error message to display on error
func_exit_on_error () {
    if test "$1" -ne "0"; then
        if test -z "$2"; then
            echo "$bldred $2 $txtrst"
        else
            echo "$bldred Error during upload $txtrst"
        fi
        echo "$bldred Upload interrupted $txtrst";
        exit 1
    fi
}
CURRENT_PATH=`pwd`
CURRENT_DIR=`basename $CURRENT_PATH`
#DEFAULT CONFIGURATION
TMP_DIR=/tmp
ARCHIVE_NAME=fup-to-upload.tar.bz2

#LOAD PROJECT CONFIGURATION
CONF_FILE=.fup

if [ -f $CONF_FILE ]; then
    echo "$blkwht Conf file found $txtrst"
    eval "$(cat $CONF_FILE)"
else
    echo "Not a fup project (missing .fup file)"
    exit 1
fi

#CHECK FOR BASE CONFIGURATION
if [ "$SSH_USR_HOST" = "" ]; then
    func_exit_on_error 1 "Please set SSH_USR_HOST variable in your .fup file"
fi

save_IFS=$IFS
IFS=,
set -- $EXCLUDED_DIRS
IFS=$save_IFS

if test "$#" -gt "0"; then
    echo "$bldwht These directories will be excluded $txtrst"
fi

for i
do
    EXCLUDE_CMD="$EXCLUDE_CMD --exclude=$i/* --exclude=$i"
    echo "-> $txtbld $i $txtrst"
done

save_IFS=$IFS
IFS=,
set -- $EXCLUDED_FILES
IFS=$save_IFS

if test "$#" -gt "0"; then
    echo "$bldwht These files will be excluded $txtrst"
fi

for i
do
    EXCLUDE_CMD="$EXCLUDE_CMD --exclude=$i"
    echo "-> $txtbld $i $txtrst"
done

LOCAL_ARCHIVE=$TMP_DIR/$ARCHIVE_NAME
if [ -f $LOCAL_ARCHIVE ]; then
    rm $LOCAL_ARCHIVE
    func_exit_on_error $? "Error during local archive deletion"
fi

cd ..

tar --exclude-vcs --exclude-backups $EXCLUDE_CMD -jcf $LOCAL_ARCHIVE $CURRENT_DIR
func_exit_on_error $? "Error during local archive creation"
cd $CURRENT_DIR

SCP_PORT_CMD="-P $SSH_PORT"
if [ "$SCP_PORT_CMD" = "-P " ]; then
    SCP_PORT_CMD=""
fi

echo "$bldwht Uploading $LOCAL_ARCHIVE to $SSH_USR_HOST:$REMOTE_DIR/ $txtrst"
scp $SCP_PORT_CMD $LOCAL_ARCHIVE $SSH_USR_HOST:$REMOTE_DIR/
func_exit_on_error $? "Error during archive uploading"

SSH_PORT_CMD="-p $SSH_PORT"
if [ "$SSH_PORT_CMD" = "-p " ]; then
    SSH_PORT_CMD=""
fi

echo "$bldwht Extracting $ARCHIVE_NAME to $SSH_USR_HOST:$REMOTE_DIR/ $txtrst"
REMOTE_COMMAND="tar -xjf $REMOTE_DIR/$ARCHIVE_NAME -C $REMOTE_DIR;rm $REMOTE_DIR/$ARCHIVE_NAME"
ssh -t $SSH_PORT_CMD $SSH_USR_HOST $REMOTE_COMMAND
func_exit_on_error $? "Error remote archive extraction"
