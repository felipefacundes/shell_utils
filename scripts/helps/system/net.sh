wget_help() {
echo '
# wget help
'
    tput setaf 9
    echo -e "\nAttention!\n"
    tput setaf 6
    echo -e "Download complete websites with WGET:\n"
    tput setaf 11
    echo -e "wget -r -p -E --execute=robots=off --limit-rate=100k --convert-links --random-wait -U mozilla\n"
    echo -e "wget --mirror -p --convert-links -P ./local-dir --user-agent='Mozilla/5.0 (Windows NT 6.3; WOW64; rv:107.0' http://www.domain.com/\n"
    echo -e "See more:
    https://www.pair.com/support/kb/paircloud-downloading-files-with-wget/\n"
    tput setaf 6
    echo -e "Download even with expired certificate:\n"
    tput setaf 11
    echo -e "wget --no-check-certificate URL\n"
    tput sgr0
}

scp_help() {
echo '
# scp help
'
    tput setaf 6
    echo -e "Send files and directories via scp:\n"
    tput setaf 11
    echo -e "scp file user@ip.x.x.x:/home/user/\n"
    echo -e "scp -r directorie user@ip.x.x.x:/home/user/\n"
    tput sgr0
}

rsync_help() {
echo '
# rsync help
'
    tput setaf 6
    echo -e "Send files and directories via rsync using port 22 (ssh):"
    echo -e "You can use parameter -e to specify the ssh port, e.g.:\n"
    tput setaf 11
    echo -e "rsync --progress -rvz -e 'ssh -p 22' /dir user@host:/home/user\n"
    echo -e "rsync -avzh --progress /dir user@192.168.1.XX:/home/user\n"
    echo -e "See more:
    https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories\n"
    tput sgr0
}

vnc() {  
cat <<'EOF'
# vnc tips

To use TigerVNC on Arch Linux, you will need to follow these steps:

Step 1: Install TigerVNC
$ sudo pacman -S tigervnc

Step 2: Firewall configuration
If you are using a firewall, you will need to allow the port used by VNC. 
By default, TigerVNC uses TCP port 5901. Therefore, run the following 
command to allow the port on the firewall:
$ sudo ufw allow 5901

Step 3: Generate the Certificate and Key
You will need to generate an X.509 certificate and key pair. 
You can use tools such as OpenSSL to generate the certificate and key. 
Here is an example command to generate a self-signed certificate:
$ mkdir ~/.vnc/ && cd ~/.vnc/
$ openssl req -x509 -nodes -newkey rsa:2048 -keyout key.key -out cert.crt
$ chmod 600 ~/.vnc/cert.crt ~/.vnc/key.key

Step 4: Configure the TigerVNC Configuration File
Edit or create the configuration file and add the following lines:~/.vnc/config

```
session=awesome
geometry=1024x768
localhost
alwaysshared
gnutlspriority
securitytypes=vncauth,tlsvnc,x509vnc
x509key=~/.vnc/key.key
x509cert=~/.vnc/cert.crt
```

Step 5: To ensure that the connection between the VNC client and the VNC server is encrypted, 
you can configure the SSH tunnel to use encryption.
When establishing the SSH tunnel, you can add the option to enable connection compression and encryption. 
This will ensure that the data transmitted between the client and the server is protected.-C
Here is the updated command to create the SSH tunnel with encryption:
$ ssh -c aes128-ctr -L 5901:localhost:5901 <user>@<192.168.X.X>

Step 6: Start the VNC Server
$ vncserver :1
EOF
}
