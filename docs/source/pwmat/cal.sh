if [ -f final.config ];then
 echo "continue cal..."

 #CN; ex; mkdir conCal && mv ~/downDir_*/ex*xsd conCal/last.xsd
 mkdir conCal && cp final.config conCal/atom.config

 cd conCal && cp ../sub*sh .
 if [ ! -f POSCAR ];then config2poscar.x atom.config && mv POSCAR last.poscar;fi

 else

 echo "start from scratch..."
 # bak
 myDate=`date +%Y%m%d%H%M%S` && mkdir bak_$myDate
 cp -r `ls --ignore="*bak*"` bak_$myDate``

 fi
