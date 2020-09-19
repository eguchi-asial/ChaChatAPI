'use strict';

import express from 'express';
import http from 'http';
import socketio from 'socket.io';
import { v4 as uuidv4 } from 'uuid';

const app: express.Express = express();
const server: http.Server = http.createServer(app);
const io: socketio.Server = socketio(server);

const PORT = process.env.PORT || 3000;

// http API
app.get('/', function (req, res) {
  res.send(uuidv4());
});

// ws API
io.on('connection', function (socket) {
  console.log('connected');
});

server.listen(PORT, function () {
  console.log('server listening. Port:' + PORT);
});
