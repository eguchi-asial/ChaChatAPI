FROM node:14.11-stretch

LABEL maintainer="Yu Eguchi"

WORKDIR /opt/app/api/

# アプリケーションの依存関係をインストールする
# ワイルドカードを使用して、package.json と package-lock.json の両方が確実にコピーされるようにします。
# 可能であれば (npm@5+)
COPY package*.json ./

RUN npm install
# 本番用にコードを作成している場合
# RUN npm install --only=production
COPY . /opt/app/api

EXPOSE 8080

# TODO ENVで切り替えできるようにする
CMD npm run start:$API_ENV
