- node 単体

```
$npm install
$npm run start:dev
```

- docker 単体(src をコピーしてしまうので、nodemon は有効にならない)

```
$cd api
$docker build -t chachat-api .
$docker run  -e API_ENV=dev -p 3000:3000 -d chachat-api
```

- docker-compose でまとめて(volumes from しているので、local の変更が nodemon で有効になる)

```
$cd pj's root
$docker-compose up -d
```
