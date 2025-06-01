const express = require("express");
const http = require("http");
const mongoose = require("mongoose");
const { Server } = require("socket.io");
const Game = require("./models/game"); // adjust to your model path

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
  },
});

mongoose.connect("mongodb://127.0.0.1:27017/catchMe")
  .then(() => console.log("MongoDB connected"))
  .catch(err => console.error("MongoDB error:", err));

const activeTimers = new Map(); // Map of gameId -> setInterval

const startCountdown = (gameId) => {
  let timeLeft = 30;

  const timer = setInterval(async () => {
    timeLeft--;
    io.to(gameId).emit("timer", { timeLeft });

    if (timeLeft <= 0) {
      clearInterval(timer);
      activeTimers.delete(gameId);
      await endGame(gameId);
    }
  }, 1000);

  activeTimers.set(gameId, timer);
};

const endGame = async (gameId, winner = null) => {
  if (activeTimers.has(gameId)) {
    clearInterval(activeTimers.get(gameId));
    activeTimers.delete(gameId);
  }

  const game = await Game.findById(gameId);
  if (!game) return;

  game.isOver = true;
  await game.save();

  io.to(gameId).emit("done");
  io.to(gameId).emit("updateGame", {
    ...game.toObject(),
    winner: winner,
  });

  cleanUpAfterGame(gameId);
};

const cleanUpAfterGame = (gameId) => {
  const room = io.sockets.adapter.rooms.get(gameId);
  if (room) {
    for (const socketId of room) {
      const socket = io.sockets.sockets.get(socketId);
      if (socket) {
        socket.leave(gameId);
        console.log(`Socket ${socket.id} removed from game ${gameId}`);
      }
    }
  }

  if (activeTimers.has(gameId)) {
    clearInterval(activeTimers.get(gameId));
    activeTimers.delete(gameId);
  }
};

io.on("connection", (socket) => {
  console.log(`⚡ Client connected: ${socket.id}`);

  socket.on("create-game", async ({ catId, ratId, board }) => {
    const game = new Game({
      players: [catId, ratId],
      board,
      turn: catId,
    });

    await game.save();
    socket.join(game._id.toString());
    socket.emit("game-created", game);
    console.log(`Game created: ${game._id}`);
  });

  socket.on("join-game", async ({ gameId }) => {
    const game = await Game.findById(gameId);
    if (game) {
      socket.join(gameId);
      socket.emit("joined-game", game);
      console.log(`Socket ${socket.id} joined game ${gameId}`);
    } else {
      socket.emit("error", { message: "Game not found." });
    }
  });

  socket.on("start-timer", ({ gameId }) => {
    if (!activeTimers.has(gameId)) {
      console.log(`Starting timer for game ${gameId}`);
      startCountdown(gameId);
    }
  });

  socket.on("move", async ({ gameId, board, turn }) => {
    const game = await Game.findById(gameId);
    if (!game || game.isOver) return;

    game.board = board;
    game.turn = turn;
    await game.save();

    io.to(gameId).emit("updateGame", game);
  });

  socket.on("caught", async ({ gameId, winner }) => {
    await endGame(gameId, winner);
  });

  socket.on("disconnect", () => {
    console.log(`❌ Disconnected: ${socket.id}`);

    // Remove this socket from all rooms
    for (const [roomId, room] of io.sockets.adapter.rooms.entries()) {
      if (room.has(socket.id)) {
        socket.leave(roomId);
        console.log(`Socket ${socket.id} left room ${roomId}`);
      }
    }
  });
});

server.listen(3000, () => {
  console.log("🚀 Server running on http://localhost:3000");
});
