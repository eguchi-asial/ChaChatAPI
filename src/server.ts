'use strict';

import express from 'express';
import http from 'http';
import socketio, { Socket } from 'socket.io';
import { v4 as uuidv4 } from 'uuid';
import Chat from './types/chat';
import { MD5, enc } from 'crypto-js';
import moment from 'moment';

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
  const clientIpAddress =
    socket.request.headers['x-forwarded-for'] ||
    socket.request.connection.remoteAddress;
  console.log('connected', clientIpAddress);
  /* クライアントからのメッセージ受信処理 */
  socket.on('post-message', async (msg: Chat) => {
    /* 受信したメッセージをルームメンバーに通知pushする */
    io.emit('receive-message', {
      ...msg,
      postId: msg?.postId || (await digestMessage(clientIpAddress)),
    });
  });
  /* disconnected */
  socket.on('disconnect', (reason: string) => {
    console.log(`disconnect: ${reason}`);
  });
});

server.listen(PORT, () => {
  console.log('server listening. Port:' + PORT);
});

/**
 * ハッシュ関数
 * セキュリティ用途なし
 * https://developer.mozilla.org/ja/docs/Web/API/SubtleCrypto/digest
 * @param message string ハッシュ化したい文字列
 */
async function digestMessage(message: string) {
  return MD5(`${message}-${moment().format('YYYY-MM-DD')}`).toString(
    enc.Base64
  );
}
