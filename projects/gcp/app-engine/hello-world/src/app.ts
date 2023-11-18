import express from "express";
import { GracefulShutdown } from "graceful-sd";

const app = express();
const port = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.send("Hello, World!");
});

const server = app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
GracefulShutdown.Instance.registerServer(server);
