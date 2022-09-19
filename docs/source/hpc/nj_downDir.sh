#!/bin/bash

name=replace_to_your_username   # Replace as appropriate!
token=replace_to_your_taken     # Replace as appropriate!

echo '[account]
server = https://box.nju.edu.cn
username = '${name}'@hpc.nju.edu.cn
token = '${token}'
is_pro = true
[general]
client_name = hpc-login
[cache]
size_limit = 10GB
clean_cache_interval = 10' > ~/.seadrive.conf

rm -rf ~/downDir_nj
mkdir -p ~/.SeaDrive

seadrive -c ~/.seadrive.conf -f -d ~/.seadrive/data -l ~/.seadrive/data/logs/seadrive.log ~/.SeaDrive &

ln -s ~/.SeaDrive/My\ Libraries/downDir_nj ~/downDir_nj
