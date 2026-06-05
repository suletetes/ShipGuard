import express from "express";
import http from "http";

const app = express();

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

app.get("/", (req, res) => {
  res.json({ app: "CloudPulse", version: "1.0.0" });
});

describe("CloudPulse", () => {
  let server: http.Server;

  beforeAll((done) => {
    server = app.listen(0, done);
  });

  afterAll((done) => {
    server.close(done);
  });

  function getPort(): number {
    const addr = server.address();
    if (addr && typeof addr === "object") return addr.port;
    return 3000;
  }

  test("GET /health returns 200", (done) => {
    http.get(`http://localhost:${getPort()}/health`, (res) => {
      expect(res.statusCode).toBe(200);
      done();
    });
  });

  test("GET / returns app info", (done) => {
    http.get(`http://localhost:${getPort()}/`, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        const body = JSON.parse(data);
        expect(body.app).toBe("CloudPulse");
        done();
      });
    });
  });
});
