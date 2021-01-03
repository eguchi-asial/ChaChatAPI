'use strict';

import express from 'express';
import http from 'http';
import socketio, { Socket } from 'socket.io';
import { v4 as uuidv4 } from 'uuid';
import Chat from './types/chat';
import moment from 'moment';
import { TYPES } from './utils/const';
import { digestMessage } from './utils/util';
import Parser from 'rss-parser';

const app: express.Express = express();
// SECURITY
app.disable('x-powered-by')

// CORSの許可
const origin = 'https://chachat.netlify.app';
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', req.hostname === 'localhost' ? '*' : origin);
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

app.get('/news-feed', async (req, res) => {
  const feed = await new Parser().parseURL('https://news.google.com/rss?hl=ja&gl=JP&ceid=JP:ja');
  res.send(feed);
})

app.get('/hatena-tech-feed', async (req, res) => {
  const feed = await new Parser().parseURL('https://developer.hatenastaff.com/rss');
  res.send(feed);
})

app.get('/classmethod-tech-feed', async (req, res) => {
  const feed = await new Parser().parseURL('https://dev.classmethod.jp/feed');
  res.send(feed);
})

app.get('/itmedia-feed', async (req, res) => {
  const feed = await new Parser().parseURL('https://rss.itmedia.co.jp/rss/2.0/news_bursts.xml#_ga=2.195895146.753925528.1609642173-313186526.1609642173');
  res.send(feed);
})

app.get('/webcreatorbox-feed', async (req, res) => {
  const feed = await new Parser().parseURL('https://www.webcreatorbox.com/feed');
  res.send(feed);
})

// ws API
io.on('connection', (socket: Socket) => {
  const clientIpAddress =
    socket.request.headers['x-forwarded-for'] ||
    socket.request.connection.remoteAddress;
  console.log('connected', clientIpAddress);
  // 検索処理
  console.log('room search?: ', socket.handshake.query?.searchFlg ? 'Yes' : 'No');
  console.log('room searchStr: ', socket.handshake.query?.searchStr);
  if (socket.handshake.query?.searchFlg) {
    // io.sockets.adapter.roomsの中から、Chachatシステム上で作られたroomのみを取得する
    const availableRooms:string[] = [];
    const rooms = io.sockets.adapter.rooms;
    for (const room in rooms) {
      // 部屋名がsocketsのkeyに含まれていないroomが作成した部屋になる
      if (!Object.keys(rooms[room].sockets).includes(room)) {
        availableRooms.push(room);
      }
    }
    io.to(socket.id).emit('receive-message', {
      type: 'system',
      body: availableRooms,
      postId: null
    });
    socket.on('disconnect', (reason: string) => {
      console.log('search disconnected:', reason);
    });
    return;
  }
  // ルーム入室処理
  socket.join(socket.handshake.query?.room);
  console.log('room name: ', socket.handshake.query?.room);
  // 自分以外に周知
  socket.broadcast.to(socket.handshake.query?.room).emit('receive-message', {
    type: TYPES.SYSTEM,
    name: 'システム',
    body: `${digestMessage(clientIpAddress)}さんが入室しました`,
    postId: TYPES.SYSTEM,
    postedAt: moment().format('YYYY-MM-DD h:m:s'),
  });
  // 自分に周知
  io.to(socket.id).emit('receive-message', {
    type: TYPES.SYSTEM,
    name: 'システム',
    body: `あなたは${digestMessage(clientIpAddress)}として入室しました`,
    postId: 'system',
    postedAt: moment().format('YYYY-MM-DD h:m:s'),
  });
  const { length: roomLength } = io.sockets.adapter.rooms[socket.handshake.query?.room];
  io.to(socket.handshake.query?.room).emit('room-length', roomLength);

  /* クライアントからのメッセージ受信処理 */
  socket.on('post-message', async (msg: Chat) => {
    console.log(`from client: ${JSON.stringify({ ...msg, postId: digestMessage(clientIpAddress)})}`);
    /* 受信したメッセージをルームメンバーに通知pushする */
    socket.broadcast.to(socket.handshake.query?.room).emit('receive-message', {
      ...msg,
      postId: digestMessage(clientIpAddress),
    });
    // 自分にも送っておく
    io.to(socket.id).emit('receive-message', {
      ...msg,
      postId: digestMessage(clientIpAddress),
    });
  });
  /* disconnected */
  socket.on('disconnect', (reason: string) => {
    socket.leave(socket.handshake.query?.room);
    const roomInfo = io.sockets.adapter.rooms[socket.handshake.query?.room];
    io.to(socket.handshake.query?.room).emit('room-length', roomInfo?.length ?? 0);
    // 自分以外に退室を知らせる
    socket.broadcast.to(socket.handshake.query?.room).emit('receive-message', {
      type: TYPES.SYSTEM,
      name: 'システム',
      body: `${digestMessage(clientIpAddress)}さんが退室しました`,
      postId: TYPES.SYSTEM,
      postedAt: moment().format('YYYY-MM-DD h:m:s'),
    });
    console.log(`disconnect: ${reason}`);
  });
});

server.listen(PORT, () => {
  console.log('server listening. Port:' + PORT);
});
