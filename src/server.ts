'use strict';

import express from 'express';
import http from 'http';
import socketio, { Socket } from 'socket.io';
import { v4 as uuidv4 } from 'uuid';
import Chat from './types/chat';
import { MD5, enc } from 'crypto-js';
import moment from 'moment';

const app: express.Express = express();
// SECURITY
app.disable('x-powered-by')

// CORSの許可
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', ['http://localhost:8080', 'https://chachat.netlify.app']);
  res.header(
    'Access-Control-Allow-Headers',
    'Origin, X-Requested-With, Content-Type, Accept'
  );
  next();
});
const server: http.Server = http.createServer(app);
const io: socketio.Server = socketio(server);

const PORT = process.env.PORT || 3000;

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
  // ルーム入室処理
  socket.join('test-room');
  // 自分以外に周知
  socket.broadcast.to('test-room').emit('receive-message', {
    type: 'system',
    name: 'システム',
    body: `${digestMessage(clientIpAddress)}さんが入室しました`,
    postId: 'system',
    postedAt: moment().format('YYYY-MM-DD h:m:s'),
  });
  // 自分に周知
  io.to(socket.id).emit('receive-message', {
    type: 'system',
    name: 'システム',
    body: `あなたは${digestMessage(clientIpAddress)}として入室しました`,
    postId: 'system',
    postedAt: moment().format('YYYY-MM-DD h:m:s'),
  });
  const { length: roomLength } = io.sockets.adapter.rooms['test-room'];
  io.to('test-room').emit('room-length', roomLength);

  /* クライアントからのメッセージ受信処理 */
  socket.on('post-message', async (msg: Chat) => {
    console.log(`from client: ${JSON.stringify({ ...msg, postId: digestMessage(clientIpAddress)})}`);
    /* 受信したメッセージをルームメンバーに通知pushする */
    socket.broadcast.to('test-room').emit('receive-message', {
      ...msg,
      type: 'chat',
      postId: digestMessage(clientIpAddress),
    });
    // 自分にも送っておく
    io.to(socket.id).emit('receive-message', {
      ...msg,
      type: 'chat',
      postId: digestMessage(clientIpAddress),
    });
  });
  /* disconnected */
  socket.on('disconnect', (reason: string) => {
    socket.leave('test-room');
    const roomInfo = io.sockets.adapter.rooms['test-room'];
    io.to('test-room').emit('room-length', roomInfo?.length ?? 0);
    // 自分以外に退室を知らせる
    socket.broadcast.to('test-room').emit('receive-message', {
      type: 'system',
      name: 'システム',
      body: `${digestMessage(clientIpAddress)}さんが退室しました`,
      postId: 'system',
      postedAt: moment().format('YYYY-MM-DD h:m:s'),
    });
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
function digestMessage(message: string) {
  return MD5(`${message}-${moment().format('YYYY-MM-DD')}`).toString(
    enc.Base64
  );
}
