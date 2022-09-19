==================
NWchem
==================

官网: 

手册: https://nwchemgit.github.io

GitHub主页: https://github.com/nwchemgit/nwchem


简介
==================


conda安装
==================
:: 
  mkdir -p  ~/app/miniconda3
  cd ~/app/miniconda3
  wget -O miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

  bash miniconda.sh -p ~/app/miniconda3/installDir -b
  . ~/app/miniconda3/installDir/bin/activate

  conda create -y -n nwchem -c conda-forge nwchem ase 
  
  conda activate 
