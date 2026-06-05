import express from "express";

const app = express();
const port = process.env.PORT || 3000;

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", timestamp: new Date().toISOString() });
});

app.get("/", (req, res) => {
  res.json({
    app: "CloudPulse",
    version: process.env.APP_VERSION || "1.0.0",
    deployed_by: "ShipGuard",
  });
});

app.listen(port, () => {
  console.log(`CloudPulse running on port ${port}`);
});
