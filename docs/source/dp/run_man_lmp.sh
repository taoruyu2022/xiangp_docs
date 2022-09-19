#!/bin/bash

cat > run.sh << \EOF
#!/bin/bash -l
#PBS -l nodes=1:ppn=4:gpus=1
#PBS -q gpu_test

source ~/scripts/deepmd_cpu

if [ xp$PBS_O_WORKDIR == xp"" ];then PBS_O_WORKDIR=`pwd` ;fi && cd $PBS_O_WORKDIR


mkdir traj && wait

{ if [ ! -f tag_0_finished ] ;then
  /bin/sh -c '{ if [ ! -f dpgen.restart.10000 ]; then lmp -i input.lammps -v restart 0; else lmp -i input.lammps -v restart 1; fi }'  1>> model_devi.log 2>> model_devi.log
  if test $? -ne 0; then touch tag_failure_0; fi
  touch tag_0_finished
fi }


rm ./run.sh
EOF

bash run.sh
