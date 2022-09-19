#!/bin/bash


if [ "as"$1 == "as" ];then
arr=_
else
arr=$1
fi

for i in *${arr}*;do if [ -d $i ];then cd $i

pwDir=`pwd` && while [ -d conCal ];do cd conCal ;done

ex > /dev/null 2>&1 && echo $i `cg -r -n1|tail -n1` && cd $pwDir/../

fi ;done|column -t
