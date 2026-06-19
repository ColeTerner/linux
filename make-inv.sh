#!/bin/bash
inv_name='inv'
path=.

#0.Define SSH port
echo "SSH_PORT:"
read ssh_port

if [ "$ssh_port" != '' ] && [[ ! "$ssh_port" =~ ^[0-9]{2,5}$ ]]; then
    echo "Error: SSH port must be a 2-5 digit number"
    exit 1
elif [ "$ssh_port" = '' ]; then
    ssh_port=22
fi
echo "YOUR SSH-PORT IS: $ssh_port"

#1.Define SSH user/password
echo "USERNAME:"
read user_name

if [ $user_name = 'svk' ]
then
	user_pass='1'
elif [ $user_name = 'detect' ]
then
	user_pass='detect-pwd'
else
	echo "INCORRECT USER_NAME!"
	exit 1
fi

#2.Create inv file
cd $path
touch $inv_name && >$inv_name


#3.Fill inv file
echo '[all]' > $inv_name

echo "To break from input loop - print 0 / q instead of any IP or token fields"
i=0
while true
do
	echo "write IP: "
	read ip
	echo "write TOKEN: "
	read token

	if [[ $ip = "0" || $ip = "q" || $token = "0" || $token = "q" ]]; then
		break
	fi
	echo "$ip token=' $token '" >> $inv_name
	i=$((i+1))
done
echo "You are installing $i shops"

all_vars=("[all:vars]" "ansible_user=$user_name" "ansible_port=$ssh_port" "become-user=root" "ansible_password=$user_pass" "ansible_become_pass=$user_pass" "ansible_sudo_pass=$user_pass" "license_ntls_server=face452k.bit-tech.co:3144" "ansible_python_interpreter=/usr/bin/python3" "timesrv=0.pool.ntp.org" "skip=1" "ansible_shell_executable=/bin/bash")

for string in ${all_vars[@]}
do
	echo $string >> $inv_name
done

cat $inv_name
echo "INVENTORY_PATH: $path/$inv_name"
