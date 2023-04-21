#!/bin/bash

usage() { echo "Usage: $0 [-p <port> ] [ -c <host> ] [ -R <remote port> ] [ -i <keyfile> ] [ -u <user> ] [ -a <authorized_keys file> ]" 1>&2; exit 1; }

KEY=${KEY:-~/.ssh/id_rsa}
AUTHORIZED_KEY=${AUTHORIZED_KEY:-~/.ssh/id_rsa.pub}
HOST=${HOST}
PORT=${PORT:-22}
REMOTE_PORT=${REMOTE_PORT:-8022}
SSH_USER=${SSH_USER:-root}

while getopts ":p:a:c:R:i:u:" o; do
    case "${o}" in
        a)
            AUTHORIZED_KEY=${OPTARG}
            ;;
        p)
            PORT=${OPTARG}
            ;;
        R)
            REMOTE_PORT=${OPTARG}
            ;;
	i)
            KEY=${OPTARG}
	    ;;
        c)
            HOST=${OPTARG}
            ;;
        u)
            SSH_USER=${OPTARG}	
            ;;
        h)
            usage
	    ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${HOST}" ]; then
    usage
fi
UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)

TMPDIR=$HOME/.$(mktemp)
CWD=$(pwd)

mkdir -p $TMPDIR
TMPSSHDIR=$TMPDIR/.ssh
mkdir $TMPSSHDIR
chmod 700 $TMPSSHDIR
cp $AUTHORIZED_KEY $TMPSSHDIR/authorized_keys
chmod 600 $TMPSSHDIR/authorized_keys
cat >> $TMPSSHDIR/config <<EOF
Host $UUID
  StrictHostKeyChecking no
  HostName tundroid
  Port $PORT
  User $SSH_USER
EOF
chmod 600 $TMPSSHDIR/config
cp $KEY $TMPSSHDIR/id_rsa
chmod 700 $TMPSSHDIR/id_rsa
cat > tundroid.shar <<EOF
#!/bin/sh
pkg update -y
pkg install -y autossh busybox openssh
mkdir ./.$UUID
cd ./.$UUID
EOF
cd $TMPDIR
shar .ssh | sed '1d' | sed '/^exit 0/d' | sed 's/uuencode/busybox uuencode/g' | sed 's/uudecode/busybox uudecode/g' >> $CWD/tundroid.shar
rm -rf $TMPSSHDIR
cd $CWD
chmod +x tundroid.shar
cat >> tundroid.shar <<EOF
mv .ssh ~/ 2> /dev/null
chmod -R 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_rsa*
chmod 600 ~/.ssh/config
mkdir -p ~/.termux/boot
cat > ~/.termux/boot/01tundroid <<WEOF
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sshd
autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -fN tundroif -R $REMOTE_PORT:localhost:8022
WEOF
chmod +x ~/.termux/boot/01tundroid
cd ..
mv -f ./.$UUID/.ssh/* ./.ssh/
rm -rf ./.$UUID
EOF
rm -rf $TMPDIR
echo done!
