#!/bin/bash
set -ex

#VARIABLES
passphrase="detect-pwd"
vpn_folder=/mnt/distr/vpn/

echo "Write down PFX full path with filename"
read pfx_folder


pfx_filename=$(echo $pfx_folder | awk -F '/' '{print $NF}')
echo $pfx_filename

name=$(echo $pfx_folder | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}')
echo $name

pfx_dir=$(echo $pfx_folder | awk 'BEGIN{ FS=OFS="/" } { n=$(NF); NF--; print $0" "n}' | awk '{print $1}')
echo $pfx_dir


echo "1.Extracting  .CRT and .KEY file from .PFX-cert to $pfx_path"
openssl pkcs12 -in $pfx_folder -nokeys -out $pfx_dir/$name.crt -passout pass:$passphrase
openssl pkcs12 -in $pfx_folder -nocerts -out $pfx_dir/$name.key -passout pass:$passphrase

echo "2.SHOW .crt AND .key FILES in the NEW LOCATION:" 
cd $pfx_dir && ls -lah | grep "$name"

echo "3.COPY new files to /etc/ssl/private/ /etc/ssl/certs/ /usr/local/share/ca-certificates/:"

sudo chmod 777 $name.key


mkdir -p /mnt/distr/vpn
cp $pfx_dir/$name.crt $vpn_folder
cp $pfx_dir/$name.key $vpn_folder


echo "YOUR CERTS ARE IN $vpn_folder"

echo "NOW YOU CAN ADD NEW VPN_CONNECTION in Linux Gnome GUI , and select following files as CERT and PASSWORD:"
echo "CERT: $vpn_folder$name.crt"
echo "KEY: $vpn_folder$name.key"

