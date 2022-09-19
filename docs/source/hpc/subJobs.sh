#!/bin/bash


cat > run.jobs << \EOF
#!/bin/bash



EOF




myName=`cat  ~/scripts/AccountIdentification`
############################# NanJing #############################
if [ xp${myName}px == xptzq_xiangpanpx ];then
echo "run calculation on nj"

cat > runAseVASP.sh << EOF
#!/bin/bash
#BSUB -q 6140ib
#BSUB -n 72

# e5v3ib 24
# 7702ib 128
# 6140ib 72

bash run.jobs
rm run.jobs

EOF
bsub < runAseVASP.sh

############################# NingBo #############################
elif [ xp${myName}px == xpnbpx ];then
echo "run calculation on nb"

if [ xp${1}px == "xp16px" ];then
cat > runAseVASP.sh << EOF
#!/bin/bash
#PBS -q chenl192O
#PBS -l nodes=1:ppn=16
#PBS -S /bin/bash
#PBS -j oe
#PBS -N output

# chenl192O 16
# chenl216N 36


cd \${PBS_O_WORKDIR}

bash run.jobs
rm run.jobs

EOF
qsub runAseVASP.sh
else
cat > runAseVASP.sh << EOF
#!/bin/bash
#PBS -q chenl216N
#PBS -l nodes=1:ppn=36
#PBS -S /bin/bash
#PBS -j oe
#PBS -N output


# chenl192O 16
# chenl216N 36


cd \${PBS_O_WORKDIR}

bash run.jobs
rm run.jobs

EOF
fi
qsub runAseVASP.sh

############################# NingBo2 #############################
elif [ xp${myName}px == xpnb2px ];then
echo "run calculation on nb2"


if [ xp${1}px == "xp-mpx" ];then
n=`getNodes.sh |grep freeNodes |awk '{print $3}'`

if [[ "xp${n}" =~ "xpnode" ]]; then
echo $n
else
echo no node, exit...
exit
fi

echo ${n}":"`pwd` >> /public/home/xiangpan/scripts/tmp_pbs/runNodes

cat > runAseVASP.sh << EOF
#!/bin/bash
#PBS -q chenliang2021
#PBS -l nodes=1:ppn=48
#PBS -S /bin/bash
#PBS -j oe
#PBS -N output
#PBS -l walltime=1000:00:00

# chenliang2021 48 24

killall -9 vasp_gam
killall -9 vasp_std
sleep 2

echo \$HOSTNAME

while true;do
if [[ ! -n \`qnodes $n |grep "state = free"\` ]];then
echo "node busy, stopping..."
sed -i "/$n:/d" /public/home/xiangpan/scripts/tmp_pbs/runNodes
killall -u xiangpan
fi
if [[ -n \`cat ~/scripts/tmp_pbs/stopNodes |grep $n"$" \` ]];then
echo "node in stopNodes file, stopping..."
sed -i "/$n$/d" /public/home/xiangpan/scripts/tmp_pbs/stopNodes
sed -i "/$n:/d" /public/home/xiangpan/scripts/tmp_pbs/runNodes
killall -u xiangpan
fi
sleep 10
done > stop.out 2>&1 &

###########

bash run.jobs
rm run.jobs

###########

sed -i "/$n:/d" /public/home/xiangpan/scripts/tmp_pbs/runNodes
echo "job finished, exit..."
killall -u xiangpan
EOF

#bash runAseVASP.sh
ssh $n "cd `pwd` && pwd && nohup bash runAseVASP.sh > output_1231 &"


else

cat > runAseVASP.sh << EOF
#!/bin/bash
#PBS -q chenliang2021
#PBS -l nodes=1:ppn=48
#PBS -S /bin/bash
#PBS -j oe
#PBS -N output
#PBS -l walltime=1000:00:00

# chenliang2021 48 24


echo \$HOSTNAME

cd \${PBS_O_WORKDIR}

bash run.jobs
rm run.jobs

EOF
qsub runAseVASP.sh

fi
############################# BeiJing #############################
elif [ xp${myName}px == xpsc52140px ];then
echo "run calculation on bj"

cat > runAseVASP.sh << EOF
#!/bin/bash
#SBATCH -n 64
#SBATCH -p amd_256

bash run.jobs
rm run.jobs

EOF

sbatch runAseVASP.sh

############################# toSetup #############################
else
echo "unknown node, job not submitted"
rm runVASP.py
fi
