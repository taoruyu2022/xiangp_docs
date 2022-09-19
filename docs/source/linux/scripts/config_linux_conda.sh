#!/bin/bash

mkdir -p  ~/app/miniconda3
cd ~/app/miniconda3
wget -O miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

bash miniconda.sh -p ~/app/miniconda3/installDir -b -y
. ~/app/miniconda3/installDir/bin/activate


# ase.
#conda create -y -n ase  ase matplotlib -c conda-forge

# conda operations.
#conda create -y -n envs_name
#conda activate envs_name
#conda deactivate envs_name
#conda remove --all -y -n envs_name
