#!/bin/bash
echo -e "
      @@@@            @@@@
     @@@@@@          @@@@@@
     @@@@@@          @@@@@@
      @@@@            @@@@
@                             @
 @@                         @@
   @@@                   @@@
      @@@@@         @@@@@
         @@@@@@@@@@@@@
"
echo "HI master"
read -p " Would you like to create  task folder and pull appz images?  then press c ,else press any thing but c   !!!!" ch
ch=${ch:-"i"}
if [[ $ch == "c" ]];then
        read -p "enter n if your not in the path or just enter  " ans
        ans=${ans:-yes}
        if [[ $ans == "yes" ]];then
                read -p "enter the task number " task
                task=${task:-"temptask"}
                mkdir -p $task
                read -p "if u like to pull feature branch just type in... or if you want to pull master continue with enter !!!" branch
                branch=${branch:-"master"}
                if [[ $branch == "master" ]]; then
                        cd $PWD/$task && git clone https://github.com/Cloudbourne/AppZ-Images.git
                else
                        cd $PWD/$task && git clone https://github.com/Cloudbourne/AppZ-Images.git -b $branch
                fi
        fi
fi
echo "Have a nice day "
echo "{\__/}
(●_●)
( >:taco: Want a taco?   "
