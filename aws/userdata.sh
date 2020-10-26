#!/bin/bash
# user_dataはrootで動くので注意
# yum
yum update -y
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
# npm (npxとnodeが欲しいので)
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh | bash
. /.nvm/nvm.sh
nvm install node
node -e "console.log('Running Node.js ' + process.version)"
npm install
echo 'API_ENV=prod' > .env
# usermodは一旦logoutしてからloginしないと有効にならないので注意
docker-compose up -d
