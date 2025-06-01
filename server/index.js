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
    methods: ["GET", "POST"]
  }
})

const DB = 'mongodb+srv://mkbarani1234:Barani123@cluster0.ah0uc.mongodb.net/mydatabase?retryWrites=true&w=majority';

const connectDB = async () => {
  try {
    await mongoose.connect(DB);
    console.log("✅ MongoDB connected...");
  } catch (err) {
    console.error("❌ MongoDB Connection Error:", err.message);
    // Retry after 5 seconds
    setTimeout(connectDB, 5000);
  }
};

connectDB();

const activeTimers = new Map(); // Store active timers per game

io.on('connection', (socket) => {
  console.log(`🔗 Connected: ${socket.id}`);

  socket.on('create-game', async ({ NickName }) => {
    try {
      console.log('Creating game for:', NickName);
      let game = new Game();
      const player = {
        NickName: NickName,
        socketId: socket.id,
        currRow: 0,
        currCol: 0,
        isPartyLeader: true
      }
      game.players.push(player);
      game = await game.save();

      const gameId = game._id.toString();
      socket.join(gameId);

      io.to(gameId).emit('updateGame', game);
    } catch (e) {
      console.log(e);
    }
  });

  socket.on('join-game', async ({ NickName, gameId }) => {
    try {
      if (!gameId.match(/^[0-9a-fA-F]{24}$/)) {
        socket.emit('not CorrectGame', "Please enter a valid game ID");
        return;
      }

      let game = await Game.findById(gameId);
      if (!game) {
        socket.emit('not CorrectGame', "Game not found.");
        return;
      }

      if (game.isJoin && game.players.length < 2) {
        console.log('Joining game:', NickName);

        const player = {
          NickName: NickName,
          socketId: socket.id,
          currRow: 4,
          currCol: 4,
          isPartyLeader: false
        };

        socket.join(gameId);
        game.players.push(player);
        game = await game.save();

        io.to(gameId).emit('updateGame', game);
      } else {
        socket.emit('room-full', 'Room is full, try again later.');
      }
    } catch (e) {
      console.log(e);
      socket.emit('error', 'An error occurred while joining the game.');
    }
  });

  socket.on('timer', async ({ playerId, gameId }) => {
    let countDown = 5;
    let game = await Game.findById(gameId);
    let player = game.players.id(playerId);
    if (player.isPartyLeader) {
      const time = setInterval(async () => {
        if (countDown >= 0) {
          io.to(gameId).emit('timer', {
            countDown,
            Msg: 'Game starts soon...'
          });
          console.log('Countdown:', countDown);
          countDown--;
        } else {
          game.isJoin = false;
          game = await game.save();
          io.to(gameId).emit('updateGame', game);
          startGame(gameId);
          clearInterval(time);
        }
      }, 1000);
    }
  });

  const startGame = async (gameId) => {
    let game = await Game.findById(gameId);
    game.startTime = new Date().getTime();
    game = await game.save();
    let time = 120;

    const timer = setInterval(async () => {
      if (time >= 0) {
        const gameTime = calculateTime(time);
        io.to(gameId).emit('timer', {
          countDown: gameTime,
          Msg: 'Time Remaining',
        });
        console.log('Game Time:', gameTime);
        time--;
      } else {
        clearInterval(timer);
        activeTimers.delete(gameId); // Remove timer when game ends

        game.isOver = true;
        game = await game.save();
        io.to(gameId).emit('updateGame', game);

        // After game over, clean up room
        cleanUpAfterGame(gameId);
      }
    }, 1000);

    activeTimers.set(gameId, timer);
  };

  // Update player position on move
  socket.on('move', async ({ playerId, gameId, row, col }) => {
    try {
      let game = await Game.findById(gameId);
      if (!game) return socket.emit('error', 'Game not found.');

      let player = game.players.id(playerId);
      if (!player) return socket.emit('error', 'Player not found.');

      player.currRow = row;
      player.currCol = col;

      await game.save();

      // Check if cat caught the mouse
      if (game.players.length === 2) {
        const cat = game.players.find(p => p.isPartyLeader);
        const mouse = game.players.find(p => !p.isPartyLeader);

        if (cat.currRow === mouse.currRow && cat.currCol === mouse.currCol) {
          await endGame(gameId, cat.NickName);
          return;
        }
      }

      io.to(gameId).emit('updateGame', game);
    } catch (e) {
      console.log('Error in move:', e);
      socket.emit('error', 'Error while moving.');
    }
  });

  // Handle game-over event from client
  socket.on('game-over', async ({ gameId, winner }) => {
    await endGame(gameId, winner);
  });

  // Handle socket disconnect
  socket.on("disconnect", () => {
    console.log(`❌ Disconnected: ${socket.id}`);
  });
});

// Helper: Calculate mm:ss format from seconds
function calculateTime(time) {
  const min = Math.floor(time / 60);
  const sec = time % 60;
  return `${min} : ${sec < 10 ? '0' + sec : sec}`;
}

// End game & notify players
const endGame = async (gameId, winner = null) => {
  if (activeTimers.has(gameId)) {
    clearInterval(activeTimers.get(gameId));
    activeTimers.delete(gameId);
  }

  let game = await Game.findById(gameId);
  if (!game) return;

  game.isOver = true;
  await game.save();

  io.to(gameId).emit('done'); // notify clients to reset UI
  io.to(gameId).emit('updateGame', {
    ...game.toObject(),
    winner: winner,
  });

  // Clean up after game ends
  cleanUpAfterGame(gameId);
};

// Remove all players from the room after game ends to avoid conflicts on new game
const cleanUpAfterGame = (gameId) => {
  const clients = io.sockets.adapter.rooms.get(gameId);
  if (clients) {
    for (const socketId of clients) {
      const socket = io.sockets.sockets.get(socketId);
      if (socket) {
        socket.leave(gameId);
        // Optionally disconnect sockets fully:
        // socket.disconnect(true);
      }
    }
  }
};

// CREATE PORT & START SERVER
const port = 3000;
server.listen(port, '0.0.0.0', () => {
  console.log(`🚀 Server running on http://192.168.81.54:${port}`);
});
