#!/usr/bin/python3

import pwd
import grp
import os
import crypt
import getpass
import sys
import string
import random
import secrets
import subprocess
import smtplib
#def randompassword():
 #   alphabet = string.ascii_letters + string.digits
  #  password = ''.join(secrets.choice(alphabet) for i in range(16))
   # print (password)
    #return password

def randomString(stringLength=10):
    """Generate a random string of fixed length """
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(stringLength))

def sshusradd(lgusr,password):
    os.system("sudo su - "+lgusr+" -c 'mkdir -p .ssh '")
    os.system("sudo su - "+lgusr+" -c 'chown -R "+lgusr+":"+lgusr+" /home/"+lgusr+"/.ssh'")
    os.system("sudo su - "+lgusr+" -c 'chmod 0700 /home/"+lgusr+"/.ssh'")
    #os.system("sudo su - "+lgusr+" -c 'chmod 0600 /home/"+lgusr+"/.ssh/authorized_keys'")
    #os.system("sudo chown -R "+lgusr+":"+lgusr+" /home/"+lgusr+"/.ssh")
    #os.system("sudo chmod 0700 /home/"+lgusr+"/.ssh")
    #os.system("sudo chmod 0600 /home/"+lgusr+"/.ssh/authorized_keys && logout")
    print("Enter the keys : ")
    os.system("sudo su - "+lgusr+" -c 'read x && echo $x > /home/"+lgusr+"/.ssh/authorized_keys'")
   # os.system("sudo su - "+lgusr+" -c 'ssh-keygen -t rsa -f /home/"+lgusr+"/.ssh/id_rsa -q -N"+password+" '")
    #os.system("exit")
    return

def mailall():
    ser = smtplib.SMTP('smtp.gmail.com', 587)
    ser.login("sarath.sankar@dinoct.com", "pzntrviitewwdonw")
    ser.ehlo()
    msg= "hello"
    ser.sendmail("sarathsankar.rs@gmail.com","sarathsankr37@gmail.com",msg)
    ser.quit()
    return

def addnewuser(strin):

    uname=str(strin)
    upass=randomString()
    #upass=getpass.getpass("Select Password :")

    #The encryption module seems to solve the obvious security leak,
    #but I still don't know whether even the exposed encrypted password is safe or not.
    ucrypt=crypt.crypt(upass,"123")
    x = subprocess.check_output("cut -d ' ' -f1 /etc/issue |head -1 >/tmp/os.txt", shell=True );
    x = subprocess.check_output("cat /tmp/os.txt", shell=True );
    x=x.decode("utf-8")
    #print(x)
    if os.path.isdir("/home/"+uname):
        os.system("sudo useradd -s /bin/bash -d /home/"+uname+" -m -p "+ucrypt+" "+uname)
        os.system("sudo chown -R "+uname+"."+uname+" /home/"+uname)
    else:
        os.system("sudo useradd -s /bin/bash -m -p "+ucrypt+" "+uname)
    if 'Ubuntu' in x:
        os.system("sudo usermod -aG sudo "+uname)
    else:
        os.system("sudo usermod -aG wheel "+uname)
    os.system("sudo touch /tmp/pertemp")
    #print (uname)
    #print (upass)
    #stat= uname + " ALL=(ALL) NOPASSWD:ALL "
    #print(stat)
    #persudo="echo ' "+uname+"  ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/pertemp"
    os.system(" sudo echo ' "+uname+"  ALL=(ALL) NOPASSWD:ALL' >> /tmp/pertemp ")
    os.system(" sudo cp /tmp/pertemp /etc/sudoers.d/ ")
#    os.system(" sudo su - root -c "+persudo)
    return upass

def crelog(n,p):
    os.system(" mkdir -p /home/$USER/.scriptlog")
    os.system(" echo ====================== >> /home/$USER/.scriptlog/log.txt")
    os.system(" echo $(date) >> /home/$USER/.scriptlog/log.txt ")
    os.system(" echo FQDN :: $(hostname -A) >> /home/$USER/.scriptlog/log.txt ")
    os.system(" echo IP :: $(hostname -I) >> /home/$USER/.scriptlog/log.txt ")
    os.system(" echo UserCreated is "+n+" >> /home/$USER/.scriptlog/log.txt ")
    os.system(" echo password ::"+p+"::   >> /home/$USER/.scriptlog/log.txt ")
    #os.system(" echo public key::   >> /home/$USER/.scriptlog/log.txt ")
    #os.system("sudo  cat /home/"+n+"/.ssh/id_rsa.pub >> /home/$USER/.scriptlog/log.txt ")
    return

def dellog(dn):
    err=os.system(" mkdir -p /home/$USER/.scriptlog")
    #err=subprocess.check_output(" mkdir /home/$USER/.scriptlog", shell=True)
    #print('error ::',err)
    os.system(" echo ====================== >> /home/$USER/.scriptlog/log.txt")
    os.system(" echo $(date) >> /home/$USER/.scriptlog/log.txt ")
    os.system(" echo FQDN :: $(hostname -A) >> /home/$USER/.scriptlog/log.txt ")
    os.system(" echo IP :: $(hostname -I) >> /home/$USER/.scriptlog/log.txt ")
    os.system(" echo DeletedUser is "+dn+" >> /home/$USER/.scriptlog/log.txt ")
    return

def usercheck(n):
    er=0
    stri=n
    #stri=input("username:")
    usernames = [x[0] for x in pwd.getpwall()]
    if  stri in usernames:
        print("Already exist")
        er=1
    else:
        p =str(addnewuser(stri))
        sshusradd(stri,p)
        crelog(stri,p)
        er=0
    return er

def olduserdel(n):
    user=n
    #user=input("Username:")
    userlist=[x[0] for x in pwd.getpwall()]
    if user in userlist:
        os.system("sudo userdel "+user)
        os.system("sudo rm -rf /home/"+user+"/.ssh/id_rsa*")
        print("done!!!")
        dellog(user)
        er=0
    else:
        print ("User not exist")
        er=1
    return er

def olduserdelhome(n):
    user=n
    #user=input("Username:")
    userlist=[x[0] for x in pwd.getpwall()]
    if user in userlist:
        os.system("sudo userdel -r "+user)
        print("done!!!")
        dellog(user)
    else:
        print ("User not exist")
    return



def choice(c,name,l):
    try:
        print('\n List of users Available \n')
        print('==========================\n')

        os.system("sudo awk -F':' '{ if ( $3 >= 500 && $3 <= 60000 ) print $0}' /etc/passwd | cut -d: -f1")
        print('==========================\n')
        #ch= int(input(" Enter 1 to create a user || Enter 2 to delete user:"))
        ch=int(c)
        if ch == 1 :
            #print('"Number of User to be created :: \n')
            #input("Enter Number of userto be created :: ")
            usrc=l
            usrcount=int(usrc)
            i=0
            while i < usrcount:
                n=name[i]
                eri=usercheck(n)
                #if eri == 0:
                i=i+1
                #else:
                 #   i=i
        elif ch == 2 :
            #input("Enter Number of users to be deleted :: ")
            usrc=l
            usrcount=int(usrc)
            i=0
            while i < usrcount:
                n=name[i]
                hd=0
                #hd=int(input("Press 1 to delete home dir and mail otherwise press any other number :: "))
                if hd == 1:
                    olduserdelhome(n)
                else:
                   olduserdel(n)
                #print(er)
                #if er == 0:
                i=i+1
                #else:
                #    i=i

        else:
            sys.exit()
            #ex=int(input("\t wrong choice \n if you want to exit press any letter or if you want to start over press 5 : "))
            #if ex==5 :
             #   choice()
    except:
        print("Unexpected error:", sys.exc_info()[0])
        print('Exit.')


    return
def main(args):
    try:
        c=args[1]
        name = args[2:]
        print(name)
        l = len(name)
        print(l)
        if not os.geteuid()==0:
            sys.exit("\nOnly root can run this script\n")
        else:
            choice(c,name,l)
    except:
        print("help sudo python user.py 1 <username> to create user  ")
        print("help sudo python user.py 2 <username> to delete user  ")
        print("Unexpected error:", sys.exc_info()[0])
        print('Exit.')

if __name__ == "__main__":
    main(sys.argv)


