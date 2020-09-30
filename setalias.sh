#!/bin/bash
echo "Hello sarath "
read -p " Would you like to set project alias then press c or any other !!!!" ch
ch=${ch:-"i"}
if [[ $ch == "c" ]];then
        read -p "enter n if your not in the path or just enter  " ans
        ans=${ans:-yes}
        if [[ $ans == "yes" ]];then
                read -p "enter the project number " project
                project=${project:-"temppro"}
                cmd="alias $project='cd $PWD'"
                echo $cmd
                grep -qF -- "$cmd" $HOME/.bashrc || echo $cmd >> $HOME/.bashrc
                source $HOME/.bashrc
        fi
fi
echo "Have a nice day "
