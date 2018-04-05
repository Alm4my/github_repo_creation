#!/bin/bash -
#title           :delete_repo.sh
#description     :This script will builk delete your GitHub repositories.
#author		       :Ben-Abdul
#date            :20180405
#version         :0.1
#usage		       :bash delete_repo.sh <token> <path/to/repo.txt>
#notes           :Have token plus repo.txt in order for it to work.
#bash_version    :3.2.57(1)-release
#==============================================================================


<<INSTRUCTIONS
Script allowing you to builk delete your GitHub repositories.
You have to first create a file named "repo.txt" where you'll put your repositories' name under the format "username/repo_name"
You can use your Google Chrome with the "OneTab" extension to open all of your repositories in a tab then group them by clicking on the extension button
then copy their names into the file. They will be already formated, so you shouldn't have to waste time reformating them. :-)
You have to replace $TOKEN with a token generated in GitHub under
"Profile Picture -> Settings -> Developer settings -> Personal access tokens -> Generate new token"
The script accept 2 parameters which are your token first and the path to your repo.txt second. It runs as follow without the angle brackets:
bash delete_repo.sh <token> </path/to/repo.txt>
INSTRUCTIONS

TOKEN=$1
while read repo;
do curl -X DELETE -H "Authorization: token $TOKEN" "https://api.github.com/repos/$repo";
done < $2 #path/to/repo.txt
