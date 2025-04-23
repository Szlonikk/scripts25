// Phaser 3 version of the Ruby2D “Mario Game”

const config = {
  type: Phaser.AUTO,
  width: 1040,
  height: 480,
  physics: {
    default: 'arcade',
    arcade: {
      gravity: { y: 500 },
      debug: false
    }
  },
  scene: {
    preload,
    create,
    update
  }
};

const game = new Phaser.Game(config);

let player;
let cursors;
let obstacles;
let holes;
let coins;
let enemies;
let lives = 3;
let points = 0;
let livesText;
let pointsText;
let gameOver = false;

const START_X = 50;
const START_Y = 300;
const MARIO_SPEED = 200;
const JUMP_POWER = -300;
const ENEMY_SPEED = 100;

function preload() {
  this.load.image('map', 'assets/map.png');
  this.load.image('mario', 'assets/mario.png');
}

function create() {
  this.add.image(0, 0, 'map')
    .setOrigin(0)
    .setDisplaySize(this.scale.width, this.scale.height);

  obstacles = this.physics.add.staticGroup();
  [
    { x: 0, y: 410, w: 200, h: 80 },
    { x: 250, y: 410, w: 200, h: 80 },
    { x: 420, y: 330, w: 50, h: 80 },
    { x: 540, y: 410, w: 500, h: 80 },
    { x: 650, y: 330, w: 50, h: 80 },
    { x: 960, y: 330, w: 50, h: 80 },
    { x: 222, y: 290, w: 83, h: 37 },
    { x: 158, y: 325, w: 28, h: 37 },
    { x: 735, y: 290, w: 83, h: 37 },
    { x: 874, y: 290, w: 28, h: 37 }
  ].forEach(obj => {
    const plat = this.add.rectangle(obj.x + obj.w/2, obj.y + obj.h/2, obj.w, obj.h);
    this.physics.add.existing(plat, true);
    obstacles.add(plat);
  });

  holes = this.physics.add.staticGroup();
  [
    { x: 200, y: 430, w: 50, h: 80 },
    { x: 480, y: 430, w: 37, h: 80 }
  ].forEach(h => {
    const hole = this.add.zone(h.x + h.w/2, h.y + h.h/2, h.w, h.h);
    this.physics.add.existing(hole, true);
    holes.add(hole);
  });


  
  player = this.physics.add.sprite(START_X, START_Y, 'mario')
    .setDisplaySize(30, 30)
    .setCollideWorldBounds(true);


  livesText = this.add.text(10, 10, `Lives: ${lives}`, { fontSize: '20px', fill: '#ff0000' });
  pointsText = this.add.text(10, 30, `Points: ${points}`, { fontSize: '20px', fill: '#ff0000' });

  cursors = this.input.keyboard.createCursorKeys();

  this.physics.add.collider(player, obstacles);
 
  this.physics.add.overlap(player, holes, fallInHole, null, this);
}

function update() {
  if (gameOver) {
    player.setVelocity(0);
    return;
  }

  if (cursors.left.isDown) {
    player.setVelocityX(-MARIO_SPEED);
  } else if (cursors.right.isDown) {
    player.setVelocityX(MARIO_SPEED);
  } else {
    player.setVelocityX(0);
  }

  if (cursors.space.isDown && player.body.blocked.down) {
    player.setVelocityY(JUMP_POWER);
  }

 
  const p = this.input.activePointer;
  console.log(`Kursor: x=${p.x}, y=${p.y}`);
}


function fallInHole(player, hole) {
  player.body.checkCollision.up = false;
  player.body.checkCollision.down = false;
  player.body.checkCollision.left = false;
  player.body.checkCollision.right = false;
  player.setVelocityY(200);
  this.time.delayedCall(300, () => resetPlayer.call(this), [], this);
}

function resetPlayer() {
  player.setPosition(START_X, START_Y);
  player.body.setVelocity(0);
  player.body.checkCollision.up = true;
  player.body.checkCollision.down = true;
  player.body.checkCollision.left = true;
  player.body.checkCollision.right = true;
}
