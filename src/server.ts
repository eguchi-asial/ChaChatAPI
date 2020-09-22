'use strict';

import express from 'express';
import http from 'http';
import socketio, { Socket } from 'socket.io';
import { v4 as uuidv4 } from 'uuid';
import Chat from './types/chat';

const app: express.Express = express();
const server: http.Server = http.createServer(app);
const io: socketio.Server = socketio(server);

const PORT = process.env.PORT || 3000;

// CORSの許可
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', 'http://localhost:8080');
  res.header(
    'Access-Control-Allow-Headers',
    'Origin, X-Requested-With, Content-Type, Accept'
  );
  next();
});

// http API
app.get('/', (req, res) => {
  res.send(uuidv4());
});

// ws API
io.on('connection', (socket: Socket) => {
  console.log('connected');

  socket.on('post-message', (msg: Chat) => {
    console.log('post-message', msg);
    io.emit('receive-message', {
      ...msg,
      postId: msg?.postId || uuidv4(),
    });
  });
});

server.listen(PORT, () => {
  console.log('server listening. Port:' + PORT);
});
