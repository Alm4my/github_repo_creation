gh-create() {
  echo "####################################################################################################"
  echo "# Welcome to the GitHub Repository Creator Script. In order for it to work well, "
  echo "# There are some prerequisite. First, you need to generate an SSH key the ssh-keygen"
  echo "# command and add that key to your github account (Settings -> SSH and GPG keys -> New SSH Key) "
  echo "# Second, you need to generate a authentication token in your account as well (Settings -> " 
  echo "# Developper Settings -> Personal Access Tokens -> Generate New Tokens)"
  echo "####################################################################################################"
  echo

  repo_name=$1

  dir_name=`basename $(pwd)`
  invalid_credentials=0

  if [ "$repo_name" = "" ]; then
    printf "Repository name: (hit enter to use '$dir_name')? "
    read -r repo_name
  fi

  if [ "$repo_name" = "" ]; then
    repo_name=$dir_name
  fi

  username=`git config github.user`
  if [ "$username" = "" ]; then
    printf "Could not find username. Please enter it now: " 
    read -p username
  else
	  while true; do
      echo "Your username is $username" 
	  	read -p "You have a github username already set do you want to continue with it? [Y/n] (Enter: Yes): " yn
      case $yn in
	  		[Nn]* ) read -p "Enter your new username: " username ; break ;;
	  		* ) break ;;
	  	esac
	  done
  fi

  if [ "$username" = "" ]; then
	  echo "Error with your username. Please restart the process."
	  return 1
  else
	  git config --global github.user $username
  fi
  

  token=`git config github.token`
  if [ "$token" = "" ]; then
	  printf "We could not find any tokens. Please enter a generated token. Go in your GitHub account settings -> Developer settings -> Personal access tokens -> generate new token: "
	  read -s token
	  echo
  else
	  while true; do
	  	read -p "You have a token already set do you want to continue with it? [Y/n] (Enter: Yes) " yn
	  	case $yn in
	  		[Nn]* ) printf "Enter your new token: "; read -s token; echo; break ;;
	  		* ) break;;
	  	esac
	  done
  fi

  if [ "$token" = "" ]; then
  	echo "Your token is empty. We cannot continue. Please restart the process."
  	return 1
  else
  	git config --global github.token $token
  fi

  type=`git config github.tokentype`
  if [ "$type" = "" ]; then
	  echo "Your token type has not been set. Please select whether it is an ssh key (1) or a password (2): "
    PS3="Select an option: "
    select token_type in SSH HTTP; do
      case $token_type in
        SSH) type="ssh"; echo "The selected token type is SSH"; break ;;
        HTTP) type="http"; echo "The selected token type is HTTP"; break;;
	    esac
    done
  fi

  if [ "$type" = "ssh" ]; then
    conn_string="git@github.com:$username/$repo_name.git"
  elif [ "$type" = "http" ]; then
    conn_string="https://github.com/$username/$repo_name.git"
  else
    echo "Either token type was not enterred correctly or is empty.\n  It must be one of 'ssh' or 'http'.\n  Run git config --global github.tokentype <ssh|http>"
    invalid_credentials=1
  fi

  if [ "$invalid_credentials" -eq "1" ]; then
    return 1
  fi

  echo -n "Creating Github repository '$repo_name'..."
  status=`curl -u "$username:$token" https://api.github.com/user/repos -d '{"name":"'$repo_name'", "private":"true", "has_wiki":"true"}' -o /dev/null -s -w"%{http_code}\n"` 
  echo
  echo "The request returned with HTTP STATUS CODE $status"

  ## Trim status code
  status=${status##*( )}
  status=${status%%*( )}

  if [ "$status" == '200' ] || [ "$status" == '201' ] 
  then
    echo "Operation successful!"
  else 
    echo "There was an error. Please refer to the status code above."
    return 1
  fi

  #================
  # If you want to automatically send code to remote without being prompted; uncomment the following and comment the section below
  #================
   # echo -n "  Pushing local code to remote ..."
   # git init
   # git add .
   # git commit
   # git remote add origin $conn_string #> /dev/null 2>&1
   # git push -u origin master #> /dev/null 2>&1
   # echo " done."

  #================
  # If you want to be prompted to send code to remote after each repository creation; uncomment the following and comment the one above
  #================

  echo "Would you like to push the current code to remote?"
  PS3="Select an option: "
  select yn in "Yes" "No"; do
      case $yn in
        Yes )  git init;
        git add . ;
        git commit;
        git remote add origin $conn_string;
        echo "Pushing local code to remote...";
        git push -u origin master; echo "done.";
        break;;

        No ) exit;;
      esac
  done
  # ================

}
gh-create
