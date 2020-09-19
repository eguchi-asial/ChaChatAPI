"use strict";

import express from "express";
import { v4 as uuidv4 } from "uuid";

const app: express.Express = express();

// body-parserに基づいた着信リクエストの解析
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORSの許可
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "http://localhost:8080");
  res.header(
    "Access-Control-Allow-Headers",
    "Origin, X-Requested-With, Content-Type, Accept"
  );
  next();
});

// GetとPostのルーティング
const router: express.Router = express.Router();

router.get("/", (req: express.Request, res: express.Response) => {
  res.send({
    message: "OK",
  });
});

router.post("/", (req: express.Request, res: express.Response) => {
  const userId: string = req.body.userId;
  const crypto = require("crypto");
  const md5 = crypto.createHash("md5");
  const hasheduserId: string = md5.update(userId, "binary").digest("hex");
  res.send({
    uuid: `${hasheduserId}.${uuidv4()}`,
  });
});

app.use(router);
app.listen(3000, () => {
  console.log("ChachatApi listening on port 3000!");
});
