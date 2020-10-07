#!/bin/bash
####Downloading files #####
set -a
echo -e "Dowinloading script to pwd ....\n"

wget https://raw.githubusercontent.com/sarath-sankar/codepull/master/docker.sh -O $PWD/docker.sh
wget https://raw.githubusercontent.com/sarath-sankar/codepull/master/pullappz.sh -O $PWD/pullappz.sh
wget https://raw.githubusercontent.com/sarath-sankar/codepull/master/setalias.sh -O $PWD/setalias.sh
wget https://raw.githubusercontent.com/sarath-sankar/codepull/master/user.py -O $PWD/user.py

##### installing #######
echo -e "Runing script ..........."
if [[ $? -eq 0 ]];then
	chmod u+x $PWD/docker.sh
	chmod u+x $PWD/pullappz.sh
	chmod u+x $PWD/setalias.sh
	chmod u+x $PWD/user.py
	bash $PWD/docker.sh && echo -e "Now setting alias ..."
	cmd="alias setal='$PWD/setalias.sh && source $HOME/.bashrc '"
	cmd2="alias appzpull='$PWD/pullappz.sh && source $HOME/.bashrc '"
	#echo $cmd
        grep -qF -- "$cmd" $HOME/.bashrc || echo $cmd >> $HOME/.bashrc
        grep -qF -- "$cmd2" $HOME/.bashrc || echo $cmd2 >> $HOME/.bashrc
        source $HOME/.bashrc 
	set +a
fi


echo -e " docker might be installed and other downloaded to " $PWD
