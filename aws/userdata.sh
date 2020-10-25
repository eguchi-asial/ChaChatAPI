#!/bin/bash
# yum
yum update -y
# npm (npxとnodeが欲しいので)
## TODO うまくいかない nvmが入らない。sshしてから手動だと入る
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install node
node -e "console.log('Running Node.js ' + process.version)"
# change workspace
cd /var
mkdir www
cd www
# docker
yum install -y docker
service docker start
usermod -aG docker $USER
docker info
curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version
# git
yum install -y git
git --version
git clone https://github.com/eguchi-asial/ChaChatAPI.git
cd ChaChatAPI
npm install
echo 'API_ENV=prod' > .env
# usermodは一旦logoutしてからloginしないと有効にならないので注意
docker-compose up -d
