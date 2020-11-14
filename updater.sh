#!/bin/bash 

## Colours variables for the installation script
RED='\033[1;91m' # WARNINGS
YELLOW='\033[1;93m' # HIGHLIGHTS
WHITE='\033[1;97m' # LARGER FONT
LBLUE='\033[1;96m' # HIGHLIGHTS / NUMBERS ...
LGREEN='\033[1;92m' # SUCCESS
NOCOLOR='\033[0m' # DEFAULT FONT

function systemd_ison () {
if systemctl list-units --state=running | grep nym-mixnode1
then echo "stopping nym-mixnode1.service to update the node ..." && systemctl stop nym-mixnode1
else echo " nym-mixnode1.service is inactive or not existing. Downloading new binaries ..."
fi
}
function downloader () {
#set -x
cd /home/nym1/
# set vars for version checking and url to download the latest release of nym-mixnode1
VERSION=$(curl https://github.com/nymtech/nym/releases/latest --cacert /etc/ssl/certs/ca-certificates.crt 2>/dev/null | egrep -o "[0-9|\.]{5}(-\w+)?")
URL="https://github.com/nymtech/nym/releases/download/v$VERSION/nym-mixnode_linux_x86_64"

# Check if the version is up to date. If not, fetch the latest release.
if [ ! -f nym-mixnode_linux_x86_64 ] || [ "$(./nym-mixnode_linux_x86_64 --version | grep Nym | cut -c 13- )" != "$VERSION" ]
   then
       if systemctl list-units --state=running | grep nym-mixnode1
          then echo "stopping nym-mixnode1.service to update the node ..." && systemctl stop nym-mixnode1
                curl -L -s "$URL" -o "nym-mixnode_linux_x86_64" --cacert /etc/ssl/certs/ca-certificates.crt && echo "Fetching the latest version" && pwd
          else echo " nym-mixnode1.service is inactive or not existing. Downloading new binaries ..." && pwd
    		curl -L -s "$URL" -o "nym-mixnode_linux_x86_64" --cacert /etc/ssl/certs/ca-certificates.crt && echo "Fetching the latest version" && pwd
	   # Make it executable
   chmod +x ./nym-mixnode_linux_x86_64 && chown nym1:nym1 ./nym-mixnode_linux_x86_64
   fi
else
   echo "You have the latest version of Nym-mixnode $VERSION"

fi
}
function upgrade_nym () {
#set -x
cd /home/nym1
#select d in /home/nym1/.nym/mixnodes/* ; do test -n "$d" && break; printf "%b\n\n\n" "${WHITE} >>> Invalid Selection"; done
#directory=$(echo "$d" | rev | cut -d/ -f1 | rev)
#printf "%b\n\n\n"
#printf "%b\n\n\n" "${WHITE} You selected ${YELLOW} $directory"
sleep 2
printf "%b\n\n\n" "${WHITE} Enter the Liquid-BTC address for the incentives rewards"
vireward=(VJLHWz9kxr1j3YFt3HGPyNhtDLNaqgFXpsdvyj2EUxFCCtZyVAr9oeeT7a6ECKcSDkPwHv5hckqfEBJZ)
printf "%b\n\n\n"
printf "%b\n\n\n" "${WHITE} Address for the incentives rewards will be ${YELLOW} ${vireward} "
printf "%b\n\n\n" "${WHITE} You may later change it in config.toml if needed, but you need to stop the node first and then edit it with an editor such as nano"

current_version='0.8.1'
printf "%b\n\n\n" "${WHITE} Your curent version ${current_version}"
sudo -u nym1 -H ./nym-mixnode_linux_x86_64 upgrade --id 'NymMixNode' --incentives-address $vireward --current-version $current_version
}

downloader && sleep 2 && upgrade_nym && sleep 5 && systemctl start nym-mixnode1.service
