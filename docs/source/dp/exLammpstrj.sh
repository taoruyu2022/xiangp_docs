#!/bin/bash

dir=`cat ~/scripts/envsDir|grep asePyDir|awk '{print $2}'`
pyDir=`eval ls -d $dir`
dir=`cat ~/scripts/envsDir|grep dnDir|awk '{print $2}'`
dnDir=`eval ls -d $dir`


if [ "xp"$1 == "xp" ];then
num=100
else
num=$1
fi

symSort=`grep Ag input.lammps |tail -n1 |sed "s/\"type_map\"://g"|sed "s/\[//g"|sed "s/\]//g"|sed "s/#//g"|sed "s/  */ /g"|sed "s/'/\"/g"|sed "s/^ //g"|sed "s/ $//g"|sed "s/,$//g"`
echo $symSort


readDir='"./traj/0.lammpstrj","./traj/1.lammpstrj","./traj/10.lammpstrj",'
numC=`cat model_devi.log|sed "/[a-zA-Z]/d" |sed "s/---//g"|sed "/^$/d" |sed "/-nan/d"|tail -n1|awk '{print $1}'|awk -v num=$num '{print int($1/num)}'`
for numD in `seq 1 $((numC))`;do
i=./traj/$((numD*num)).lammpstrj
readDir=${readDir}'"'${i}'",' ;done
readDir=`echo $readDir|sed "s/,$//g"`
echo $readDir



n=`pwd|xargs basename` &&  exName=ex_`pwd|sed "s/$n//g"|xargs basename`_${n}

echo '
readDir=['$readDir']
allL=[]
for i in readDir:
  with open(i, "r") as f:
    allL.append(f.readlines())

from ase.io import write
from ase import Atoms,Atom
from ase.io.xtd import write_xtd
strucs=[]
syms=[ '$symSort' ]
print(syms)
for n,all in enumerate(allL):
  allH=all[5:8]

  cL=[]
  for i in allH:
    cL.append(eval(i.strip("\n").split()[1]))

  allC=all[9:]
  #print(allC,allH)
  struc=Atoms(cell=cL,pbc=[1, 1, 1])

  for i in allC:
    iL=[eval(i) for i in i.strip("\n").split()]
    struc.append(Atom(syms[iL[1]-1], (iL[2], iL[3], iL[4])))

  print(readDir[n],": ",struc)
  strucs.append(struc)
  #write("'$readStr'.xsd",struc)


write_xtd("ex_'${exName}'_lammpstrj.xtd",strucs,moviespeed=8)

'>tmp.py

$pyDir tmp.py

rm tmp.py

# set format
sed -i "s/DisplayStyle=\"None\"/DisplayStyle=\"Ball and Stick\"/g" *.xsd *.xtd 1>/dev/null 2>&1
sed -i "s/DisplayStyle=\"Line\"/DisplayStyle=\"Ball and Stick\"/g" *.xsd *.xtd 1>/dev/null 2>&1
sed -i "s/DisplayStyle=\"Stick\"/DisplayStyle=\"Ball and Stick\"/g" *.xsd *.xtd 1>/dev/null 2>&1
sed -i "s/DisplayStyle=\"CPK\"/DisplayStyle=\"Ball and Stick\"/g" *.xsd *.xtd 1>/dev/null 2>&1
sed -i "s/DisplayStyle=\"Polyhedron\"/DisplayStyle=\"Ball and Stick\"/g" *.xsd *.xtd 1>/dev/null 2>&1
sed -i "s/Color=\".*,.*,.*,0\" A/ Color=\"0,0,0,0\" A/g" *.xsd *.xtd 1>/dev/null 2>&1
sed -i "s/PeriodicDisplayType=\"In-Cell\"/PeriodicDisplayType=\"Default\"/g" *.xsd *.xtd 1>/dev/null 2>&1
sed -i "s/PeriodicDisplayType=\"Original\"/PeriodicDisplayType=\"Default\"/g" *.xsd *.xtd 1>/dev/null 2>&1
sed -i "s/PeriodicDisplayType=\"None\"/PeriodicDisplayType=\"Default\"/g" *.xsd *.xtd 1>/dev/null 2>&1
sed -i "s/LabelAxes=\"1\"/LabelAxes=\"0\"/g" *.xsd *.xtd 1>/dev/null 2>&1

mv ex*.* $dnDir
