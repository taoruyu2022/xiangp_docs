#!/bin/bash

#################
compEvs=/public/software/profile.d/compiler_intel-compiler-2019u5.sh # Replace as appropriate!
#################

###### file ######
# all vasp file
#wget http://theory.cm.utexas.edu/code/vtstscripts.tgz # vtst
#wget http://theory.cm.utexas.edu/code/vtstcode-184.tgz # vtst
#wget https://github.com/henniggroup/VASPsol/archive/master.zip # VASPsol
# VASPsol issue:Unable to build VASP 6.2.0 with GPU support #50
#wget https://github-repository-files.githubusercontent.com/23792558/6553933?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20211105%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20211105T051731Z&X-Amz-Expires=300&X-Amz-Signature=54cc20cf147fe65966c6d05120204c4078e81b390e5486f02155a21a214b6fe2&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=23792558&response-content-disposition=attachment%3Bfilename%3DVASPsol_VASP620.zip&response-content-type=application%2Fzip
#http://theory.cm.utexas.edu/henkelman/code/bader/download/bader_lnx_64.tar.gz # bader

# softwarePackages dir
#   $ ls softwarePackages/
#   bader_lnx_64.tar.gz   vasp.6.2.1.tgz       vdw_kernel.bindat.big_endian.gz  vtstcode-184.tgz
#   potpaw_LDA.54.tar.gz  VASPsol-master.zip   vdw_kernel.bindat.gz             vtstscripts.tgz
#   potpaw_PBE.54.tar.gz  VASPsol_VASP620.zip  vtotav.py


mkdir ~/app/vasp/v_6.2.1/cpu ||
echo failed to create installation directory, exit... &&
exit

cp ./softwarePackages/* ~/app/vasp/v_6.2.1/cpu
cd ~/app/vasp/v_6.2.1/cpu

source $compEvs
tar -zvxf vasp.6.2.1.tgz



# VASPsol
unzip VASPsol-master.zip
cp VASPsol-master/src/solvation.F ./vasp.6.2.1/src/

toContinue=""
while [ "xp"$toContinue != "xpY" ];do
cat -n ./vasp.6.2.1/src/.objects |grep -E "solvation.o|pot.o"
read -p '
if "solvation.o" appears before "pot.o"(Y/N): ' toContinue
if [ "xp"$toContinue == "xpN" ];then
read -p '
please modify the file by ensuring that "solvation.o" appears before "pot.o".
(Press enter to continue): '
vi ./vasp.6.2.1/src/.objects
fi
done

unzip VASPsol_VASP620.zip
cd ./vasp.6.2.1
cp arch/makefile.include.linux_intel makefile.include
sed -i "s/Dtbdyn/Dtbdyn -Dsol_compat/g" makefile.include

cd src
patch -p0 < ../../VASPsol_VASP620.patch

cd ../../



# VTST
tar -zvxf vtstcode-184.tgz
tar -zvxf vtstscripts.tgz
cd vasp.6.2.1/src/

cp main.F bak_main.F
repN=`cat -n main.F |grep "CALL CHAIN_FORCE(T_INFO%NIONS,DYN%POSION,TOTEN,TIFOR, &" |awk '{print $1}'` &&
sed -i $((repN+1))"s/LATT_CUR%A,LATT_CUR%B,IO%IU6/TSIF,LATT_CUR%A,LATT_CUR%B,IO%IU6/g" main.F &&
sed -i 's/IF (LCHAIN) CALL chain_init( T_INFO, IO)/CALL chain_init( T_INFO, IO)/g' main.F

cp chain.F bak_chain.F
cp ../../vtstcode-184/*.F .

cp .objects bak_.objects
sed -i 's/chain.o/bfgs.o dynmat.o  instanton.o  lbfgs.o sd.o   cg.o dimer.o bbm.o fire.o lanczos.o neb.o  qm.o opt.o chain.o/g' .objects

cd ../



# FixOpt
cd ./src
cp constr_cell_relax.F bak_constr_cell_relax.F
sed -i "/RETURN/d" constr_cell_relax.F && sed -i "/END SUBROUTINE/d" constr_cell_relax.F
echo '      LOGICAL FILFLG
      INTEGER ICELL(3,3)
      INQUIRE(FILE="OPTCELL",EXIST=FILFLG)
      IF (FILFLG) THEN
         OPEN(67,FILE="OPTCELL",FORM="FORMATTED",STATUS="OLD")
         DO J=1,3
            READ(67,"(3I1)") (ICELL(I,J),I=1,3)
         ENDDO
         CLOSE(67)
         DO J=1,3
         DO I=1,3
            IF (ICELL(I,J)==0) FCELL(I,J)=0.0
         ENDDO
         ENDDO
      ENDIF

      RETURN
      END SUBROUTINE' >> constr_cell_relax.F
cd ../../

echo '111
111
111' > OPTCELL



# Bader Charge Analysis
tar -zvxf bader_lnx_64.tar.gz && rm bader_lnx_64.tar.gz && chmod +x bader



# Make
cd vasp.6.2.1/ && make all && cd ../ && mv ./vasp.6.2.1/bin/* . && cp VASPsol-master/docs/USAGE.md ./VASPsol_USAGE.md



# Pseudopotentials
mkdir pseudopotentials && mv potpaw_* pseudopotentials && cd pseudopotentials
# ASE: potpaw (LDA XC) potpaw_GGA (PW91 XC) and potpaw_PBE (PBE XC)
mkdir potpaw potpaw_GGA potpaw_PBE
mv potpaw_LDA.54.tar.gz potpaw && cd potpaw && tar -zvxf potpaw_*.tar.gz && chmod u+w * && cd ../
mv potpaw_PBE.54.tar.gz potpaw_PBE && cd potpaw_PBE && tar -zvxf potpaw_*.tar.gz && chmod u+w * && cd ../
cd ../
ln -s `pwd`/pseudopotentials ~/scripts/pseDir

# delete
rm -rf VASPsol-master VASPsol-master.zip VASPsol_VASP620.patch vtstscripts.tgz
rm -rf VASPsol_VASP620.zip vasp.6.2.1 vasp.6.2.1.tgz vtstcode-184 vtstcode-184.tgz
mv vtstscripts-974 vtstscripts



# Work function
echo '# Work function calculation

cp CONTCAR to POSCAR and then perform a single point calculaion
INCAR: LVHAR =.TRUE. IBRION = -1 NSW=0

fermi level: "grep E-fermi OUTCAR"
python vtotav.py LOCPOT z # generate LOCPOT_Z file
' > vtotav_USAGE.md

cd ~/app/vasp/v_6.2.1/cpu



# run script
echo '#!/bin/bash

if [ "xp"$1 == "xp"std ] ||
   [ "xp"$1 == "xp"s ] ||
   [ "xp"$1 == "xp"vasp_std ]
then
  runVer=vasp_std
elif [ "xp"$1 == "xp"gam ] ||
   [ "xp"$1 == "xp"g ] ||
   [ "xp"$1 == "xp"vasp_gam ]
then
  runVer=vasp_gam
else
  runVer=vasp_std
fi


source '$compEvs'

mpirun '`pwd`'/$runVer
' > ~/scripts/runVasp_621_cpu.sh
chmod +x ~/scripts/runVasp_621_cpu.sh

# set to default.
rm -rf ~/scripts/runVasp.sh
ln -s ~/scripts/runVasp_621_cpu.sh ~/scripts/runVasp.sh
