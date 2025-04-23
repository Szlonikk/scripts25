const config = {
  type: Phaser.AUTO,
  width: 800,
  height: 600,
  physics: {
    default: 'arcade',
    arcade: {
      gravity: { y: 1000 },
      debug: false
    }
  },
  scene: {
    preload: preload,
    create: create,
    update: update
  }
};

const game = new Phaser.Game(config);
let player;
let ground;
let obstacles;
let jumpKey;

function preload() {
  // Ładowanie grafik
  this.load.image('player', 'assets/penguin2.png');
  this.load.image('tile', 'assets/tile.png');
}

function create() {
  // Tworzenie statycznej grupy podłoża
  ground = this.physics.add.staticGroup();
  const tileWidth = 32;
  // Generowanie podłoża z dziurami
  for (let i = 0; i < 20; i++) {
    // Dziury na pozycjach 5 i 12
    if (i === 5 || i === 12) continue;
    ground.create(i * tileWidth, config.height - tileWidth / 2, 'tile').setScale(1).refreshBody();
  }

  // Grupa przeszkód
  obstacles = this.physics.add.group();
  const obstaclePositions = [8, 15];
  obstaclePositions.forEach(i => {
    const obs = obstacles.create(
      i * tileWidth + tileWidth / 2,
      config.height - tileWidth - 16,
      'tile'
    );
    obs.setImmovable(true);
    obs.body.allowGravity = false;
    obs.setTint(0xff0000);
  });

  // Tworzenie gracza
  player = this.physics.add.sprite(100, config.height - tileWidth - 66, 'player').setScale(2.0);
  player.setCollideWorldBounds(true);

  // Kolizje
  this.physics.add.collider(player, ground);
  this.physics.add.collider(player, obstacles, hitObstacle, null, this);

  // Klawisz skoku
  jumpKey = this.input.keyboard.addKey('W');
}

function update() {
  // Ciągły ruch w prawo
  player.setVelocityX(200);

  // Skok
  if (Phaser.Input.Keyboard.JustDown(jumpKey) && player.body.touching.down) {
    player.setVelocityY(-500);
  }

  // Sprawdzanie upadku do dziury
  if (player.y > config.height-44) {
    this.scene.restart();
  }
}

function hitObstacle() {
  // Restart gry przy trafieniu przeszkodą
  this.scene.restart();
}