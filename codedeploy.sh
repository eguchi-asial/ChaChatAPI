# todo
cd /var/www/ChaChatAPI
# npm用意
export NVM_DIR="/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
npm install
/usr/local/bin/docker-compose stop
/usr/local/bin/docker-compose rm -f
/usr/local/bin/docker-compose up -d
