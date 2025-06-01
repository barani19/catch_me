const express = require('express');
const mongoose = require('mongoose');
const socketIo = require('socket.io');
const http = require('http');
const Game = require('./model/game_model');
const cors = require('cors');

const app = express();
app.use(express.json());
app.use(cors());

const server = http.createServer(app);

const io = socketIo(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

const DB = 'mongodb+srv://mkbarani1234:Barani123@cluster0.ah0uc.mongodb.net/mydatabase?retryWrites=true&w=majority';

const connectDB = async () => {
  try {
    await mongoose.connect(DB);
    console.log("✅ MongoDB connected...");
  } catch (err) {
    console.error("❌ MongoDB Connection Error:", err.message);
    setTimeout(connectDB, 5000);
  }
};

connectDB();

const activeTimers = new Map(); // gameId -> timer

io.on('connection', (socket) => {
  console.log(`🔗 Connected: ${socket.id}`);

  socket.on('create-game', async ({ NickName }) => {
    try {
      let game = new Game();
      const player = {
        NickName,
        socketId: socket.id,
        currRow: 0,
        currCol: 0,
        isPartyLeader: true
      };
      game.players.push(player);
      game = await game.save();

      const gameId = game._id.toString();
      socket.join(gameId);

      io.to(gameId).emit('updateGame', game);
    } catch (e) {
      console.error(e);
    }
  });

  socket.on('join-game', async ({ NickName, gameId }) => {
    try {
      if (!gameId.match(/^[0-9a-fA-F]{24}$/)) {
        return socket.emit('not CorrectGame', "Please enter a valid game ID");
      }

      let game = await Game.findById(gameId);
      if (!game) return socket.emit('not CorrectGame', "Game not found.");

      if (game.isJoin && game.players.length < 2) {
        const player = {
          NickName,
          socketId: socket.id,
          currRow: 4,
          currCol: 4,
          isPartyLeader: false
        };
        game.players.push(player);
        game = await game.save();

        socket.join(gameId);
        io.to(gameId).emit('updateGame', game);
      } else {
        socket.emit('room-full', 'Room is full, try again later.');
      }
    } catch (e) {
      console.error(e);
      socket.emit('error', 'An error occurred while joining the game.');
    }
  });

  socket.on('timer', async ({ playerId, gameId }) => {
    let countDown = 5;
    let game = await Game.findById(gameId);
    if (!game) return;

    let player = game.players.id(playerId);
    if (!player?.isPartyLeader) return;

    if (activeTimers.has(`lobby-${gameId}`)) return; // prevent multiple lobbies
    const lobbyTimer = setInterval(async () => {
      if (countDown >= 0) {
        io.to(gameId).emit('timer', {
          countDown,
          Msg: 'Game starts soon...'
        });
        countDown--;
      } else {
        clearInterval(lobbyTimer);
        activeTimers.delete(`lobby-${gameId}`);

        game.isJoin = false;
        await game.save();
        io.to(gameId).emit('updateGame', game);
        startGame(gameId);
      }
    }, 1000);

    activeTimers.set(`lobby-${gameId}`, lobbyTimer);
  });

  const startGame = async (gameId) => {
    let game = await Game.findById(gameId);
    if (!game) return;

    game.startTime = Date.now();
    game = await game.save();

    let time = 120;
    const timer = setInterval(async () => {
      if (time >= 0) {
        const gameTime = calculateTime(time);
        io.to(gameId).emit('timer', {
          countDown: gameTime,
          Msg: 'Time Remaining'
        });
        time--;
      } else {
        clearInterval(timer);
        activeTimers.delete(gameId);

        game.isOver = true;
        await game.save();

        io.to(gameId).emit('updateGame', game);
        io.to(gameId).emit('done');
        cleanUpAfterGame(gameId);
      }
    }, 1000);

    activeTimers.set(gameId, timer);
  };

  socket.on('move', async ({ playerId, gameId, row, col }) => {
    try {
      let game = await Game.findById(gameId);
      if (!game) return;

      let player = game.players.id(playerId);
      if (!player) return;

      player.currRow = row;
      player.currCol = col;
      await game.save();

      // Check for catch
      if (game.players.length === 2) {
        const cat = game.players.find(p => p.isPartyLeader);
        const mouse = game.players.find(p => !p.isPartyLeader);
        if (cat.currRow === mouse.currRow && cat.currCol === mouse.currCol) {
          return await endGame(gameId, cat.NickName);
        }
      }

      io.to(gameId).emit('updateGame', game);
    } catch (e) {
      console.error('Error in move:', e);
      socket.emit('error', 'Error while moving.');
    }
  });

  socket.on('game-over', async ({ gameId, winner }) => {
    await endGame(gameId, winner);
  });

  socket.on('disconnect', () => {
    console.log(`❌ Disconnected: ${socket.id}`);
  });
});

// End game and cleanup
const endGame = async (gameId, winner = null) => {
  if (activeTimers.has(gameId)) {
    clearInterval(activeTimers.get(gameId));
    activeTimers.delete(gameId);
  }

  let game = await Game.findById(gameId);
  if (!game) return;

  game.isOver = true;
  await game.save();

  io.to(gameId).emit('done');
  io.to(gameId).emit('updateGame', {
    ...game.toObject(),
    winner: winner,
  });

  cleanUpAfterGame(gameId);
};

// Reset sockets and listeners
const cleanUpAfterGame = (gameId) => {
  const clients = io.sockets.adapter.rooms.get(gameId);
  if (clients) {
    for (const socketId of clients) {
      const socket = io.sockets.sockets.get(socketId);
      if (socket) {
        socket.leave(gameId);
        socket.removeAllListeners(); // crucial
        // Optional:
        // socket.disconnect(true);
      }
    }
  }
};

// Utility to format timer
function calculateTime(time) {
  const min = Math.floor(time / 60);
  const sec = time % 60;
  return `${min} : ${sec < 10 ? '0' + sec : sec}`;
}

const port = 3000;
server.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://192.168.81.54:${port}`);
});
