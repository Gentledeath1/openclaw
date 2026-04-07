import express from "express";

const app = express();

const PORT = process.env.PORT || 3000;

app.get("/health", (req, res) => {
  res.send("OK");
});

app.listen(PORT, "0.0.0.0", () => {
  console.log("Health server running");
});
