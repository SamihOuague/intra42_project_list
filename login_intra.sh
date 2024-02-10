#!/bin/bash
# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    login_intra.sh                                     :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: souaguen <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/02/09 23:28:50 by souaguen          #+#    #+#              #
#    Updated: 2024/02/09 23:28:50 by souaguen         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

get_project () {
	response=$2
	n_line=$(echo "$response" | cat -n | grep "$1" | awk '{print $1}')
	for i in $n_line
	do
		rsp=$(echo "$response" | head -n $(($i + 6)) | tail -n 7 | grep "<a href=" | cut -c 24-)
		rest=${rsp#*\"}
		project=$(echo $rsp | cut -c -$((${#rsp} - ${#rest} - 1)) | grep -v "c-piscine-" | grep -v "exam-")
		if [[ $project ]]; then
			p_res=$(curl -s -b "cookie_session.out" -L "https://projects.intra.42.fr/${project}/mine")
			echo -e "$project\n"
			repo=$(echo "$p_res" | grep "<input" | grep "git@")
			echo "$repo" | cut -c 84- | sed -E -e "s/'>//g"
			echo
			sleep 1
		fi
	done

}

if [[ ! -f "cookie_session.out" ]]; then
	out=$(curl -s -c cookie.out -L "https://signin.intra.42.fr/users/sign_in")
	post_link=$(echo -e $out | sed -E -e "s/>/\n/g" | grep "action=" | sed -E -e "s/ /\n/g" | grep "action=" | cut -c 8- | sed -E -e "s/\"//g")
	login=
	password=
	echo -n "Login : "
	read login
	echo -n "Password : "
	read -s password
	curl -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -b "cookie.out" -d "username=${login}&password=${password}" -c "cookie_session.out" -b "cookie.out" -L --max-redirs 2 $post_link
fi

response=$(curl -s -b "cookie_session.out" -L "https://projects.intra.42.fr/projects/list")
echo -e "=============== FINISHED ==============\n"
get_project ">finish" "$response"
echo -e "\n============= IN PROGRESS =============\n"
get_project "in progress" "$response"
echo
