#!/bin/bash



# Handle suffixes
if  [[   "xp$@" == "xp"*"xsd"* ]];then
st=xsd
elif  [[   "xp$@" == "xp"*"vasp"* ]];then
st=vasp
elif  [[   "xp$@" == "xp"*"cif"* ]];then
st=cif
elif  [[   "xp$@" == "xp"*"poscar"* ]];then
st=poscar
else

echo "automatic detection of suffixes..."
echo "suffixe list: "
ls * -d|grep '\.'|sed "/sh/d"|awk -F '.' '{print $NF}'|sort |uniq -c|sort -n -k1
st=`ls * -d|grep '\.'|sed "/sh/d"|awk -F '.' '{print $NF}'|sort |uniq -c|sort -n -k1 | tail -n1|awk '{print $2}'`
echo "use suffixe: "$st

if [ "xp"$st == "xp" ];then echo no suffixe file, exiting... && exit ;fi
echo -ne "\n\n"

fi





# Batch submission
ls *.$st && for i in *.$st ;do r=$st && a=`echo $i |sed "s/.$r//g"`

mkdir $a && mv $i $a && cp sub*.sh $a && cd $a

pwd && ls

if  [[   "xp$@" == "xp"*"-m"* ]];then
echo "not submitted"
else
./sub*.sh
fi

ls && echo "" && cd ../; done
