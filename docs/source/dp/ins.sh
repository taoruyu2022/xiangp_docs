
conda
----------------------
ref: ../linux/linux.rst -- conda


. ~/app/miniconda3/installDir/bin/activate
cd $HOME/app/miniconda3/installDir/envs

cpu
----------------------
conda create -n deepmd_cpu_`date +%Y%m%d` deepmd-kit=*=*cpu libdeepmd=*=*cpu lammps -c https://conda.deepmodeling.com -c defaults -y

conda activate deepmd_cpu_`date +%Y%m%d`
pip3 install dpdata ase dpgen matplotlib

rm deepmd_cpu && ln -s deepmd_cpu_`date +%Y%m%d` deepmd_cpu

echo '#!/bin/bash

. /fsa/home/tzq_xiangpan/app/miniconda3/installDir/bin/activate
conda activate deepmd_cpu
export LD_LIBRARY_PATH="~/app/miniconda3/installDir/pkgs/libgfortran4-7.5.0-ha8ba4b0_17/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="~/app/miniconda3/installDir/pkgs/mpich-3.3.2-hc856adb_0/lib:$LD_LIBRARY_PATH"
'>~/scripts/deepmd_cpu



gpu
----------------------

export CONDA_OVERRIDE_CUDA=11.6
conda create -n deepmd_gpu_`date +%Y%m%d`  deepmd-kit=*=*gpu libdeepmd=*=*gpu lammps cudatoolkit=11.6 horovod -c https://conda.deepmodeling.com -c defaults -y

conda activate deepmd_gpu_`date +%Y%m%d`
pip3 install dpdata ase dpgen matplotlib
rm deepmd_gpu && ln -s deepmd_cpu_`date +%Y%m%d` deepmd_cpu

echo '#!/bin/bash

. /fsa/home/tzq_xiangpan/app/miniconda3/installDir/bin/activate
conda activate deepmd_gpu
export LD_LIBRARY_PATH="~/app/miniconda3/installDir/pkgs/libgfortran4-7.5.0-ha8ba4b0_17/lib:$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="~/app/miniconda3/installDir/pkgs/mpich-3.3.2-hc856adb_0/lib:$LD_LIBRARY_PATH"
'>~/scripts/deepmd_gpu



dispatcher
----------------------

cd ~/app/miniconda3/installDir/envs/deepmd_cpu/lib/python*/site-packages/dpgen/dispatcher/

LSF.py
~~~~~~~~~~~~~~~~~~~~~~~
""" add_xiangpan

#!/bin/bash
#BSUB -q 62v100ib
#BSUB -gpu num=1
#BSUB -R affinity[core:cpubind=core:membind=localprefer:distribute=pack]

#Example to exclude some nodes
# -R "select[hname!=g004 && hname!=g003 && hname!=g001]"


#!/bin/bash
#BSUB -q 7702ib
#BSUB -n 16

"""

    def sub_script_head(self, res):
        ret = ''
        ret += "#!/bin/bash -l\n#BSUB -e %J.err\n#BSUB -o %J.out\n"
        if res['numb_gpu'] == 0:
            ret += '#BSUB -n %d\n' % (res['numb_node'] * res['node_cpu']) # add_xiangpan
            #ret += '#BSUB -n %d\n#BSUB -R span[ptile=%d]\n' % (
            #    res['numb_node'] * res['task_per_node'], res['node_cpu'])
        else:
            ret += '#BSUB -gpu num=%d\n' % res['numb_gpu'] # add_xiangpan
            ret += '#BSUB -n %d\n' % (res['numb_node'] * res['node_cpu']) # add_xiangpan
            ret += '#BSUB -R affinity[core:cpubind=core:membind=localprefer:distribute=pack]\n' # add_xiangpan
            #ret += '#BSUB -R "select[hname!=g004 && hname!=g003 && hname!=g001]"\n' # add_xiangpan

            #if res['node_cpu']:
            #    ret += '#BSUB -R span[ptile=%d]\n' % res['node_cpu']
            #if res.get('new_lsf_gpu', False):
            #    # supported in LSF >= 10.1.0.3
            #    # ref: https://www.ibm.com/support/knowledgecenter/en/SSWRJV_10.1.0
            #    # /lsf_resource_sharing/use_gpu_res_reqs.html
            #    if res.get('exclusive', False):
            #        j_exclusive = "no"
            #    else:
            #        j_exclusive = "yes"
            #    ret += '#BSUB -n %d\n#BSUB -gpu "num=%d:mode=shared:j_exclusive=%s"\n' % (
            #        res['task_per_node'], res['numb_gpu'], j_exclusive)
            #else:
            #    ret += '#BSUB -n %d\n#BSUB -R "select[ngpus >0] rusage[ngpus_excl_p=%d]"\n' % (
            #        res['task_per_node'], res['numb_gpu'])
        #if res['time_limit']:
        #    ret += '#BSUB -W %s\n' % (res['time_limit'].split(':')[
        #        0] + ':' + res['time_limit'].split(':')[1])
        #if res['mem_limit'] > 0 :
        #    ret += "#BSUB -M %d \n" % (res['mem_limit'])
        ret += '#BSUB -J %s\n' % (res['job_name'] if 'job_name' in res else 'dpgen')
        if len(res['partition']) > 0 :
            ret += '#BSUB -q %s\n' % res['partition']
