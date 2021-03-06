- env

dpocker-componse 専用
.env.example を.env にして dev or prod で利用可能

- node 単体

```
$npm install
$npm run start:dev
```

- docker 単体(src をコピーしてしまうので、nodemon は有効にならない)

```
$docker build -t chachat-api .
$docker run  -e API_ENV=dev -p 3000:3000 -d chachat-api
```

- docker-compose でまとめて(volumes from しているので、local の変更が nodemon で有効になる)

docker-compose の場合は、.env ファイルの中身を参照する
https://docs.docker.jp/compose/environment-variables.html#env

```
$cd pj's root
$docker-compose up -d
```

- terraform

  - terraform plan
  - terraform apply

- ssh (鍵認証を引き継いで踏み台から web サーバに ssh する必要がある = AgentForward)

  - ssh -A ec2-user@fumidai の public ipaddress
  - ssh ec2-user@web サーバの private ipaddress

- deploy について
  - github に master ブランチを push すると actions が起動し、aws codedeploy に自動で deploy してくれます
    - codedeploy は appspec.yml を参照のこと

- 監視について

プロメテウス(https://prometheus.io/docs/prometheus/latest/getting_started/)を使ってます。

```
docker run -p 9090:9090 -v /path/to/your/ChaChatAPI/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus
```
