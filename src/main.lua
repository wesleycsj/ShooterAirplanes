function love.conf(t)
	t.title = "Teste" -- The title of the window the game is in (string)
	t.version = "0.9.1"         -- The LÖVE version this game was made for (string)
	t.window.width = 240        -- we want our game to be long and thin.
	t.window.height = 400

	-- For Windows debugging
	t.console = true
end
function love.load()
  -- Player definitions
  player = {
    x = 200,
    y = 500,
    speed = 250,
    points = 0,
    live = true,
    img = nil
  }
  player.img = love.graphics.newImage('plane.png')
  -- Sound of game
  shootSound = love.audio.newSource('gun-sound.wav','static')
  failSound = love.audio.newSource('fail.wav','static')
  bgSound = love.audio.newSource('background.mp3',"stream")
  -- BulletImg
  bulletImg = love.graphics.newImage('bullet.png')
  canShoot = true
  canShootTimeMax = 0.2
  canShootTime = canShootTimeMax
  bullets = {}
  -- Enemy definition
  createEnemyTimeMax = 1
  createEnemyTime = createEnemyTimeMax
  enemyImg = love.graphics.newImage('enemy.png')
  enemySpeed = 250
  enemies = {}
  -- Start game
  started = false
end
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end
function playGame(dt)
    -- Play background music
    love.audio.play(bgSound)
    -- Moviment of player
  if love.keyboard.isDown('left') then
    -- Test of window range
    if player.x > 0 then
      player.x = player.x - (player.speed * dt)
    end
  elseif love.keyboard.isDown('right') then
    if player.x < (love.window.getWidth() - player.img:getWidth()) then
      player.x = player.x + (player.speed * dt)
    end
  end
  -- Calculates the time to shoot
  canShootTime = canShootTime - (1 * dt)
  if canShootTime < 0 then
    canShoot = true
  end
  -- Test if can shoot at ctrl click
  if love.keyboard.isDown(' ') and canShoot and started then
    newBullet = {
      x = player.x + ((player.img:getWidth() / 2) - 5),
      y = player.y,
      img = bulletImg }
      table.insert(bullets, newBullet)
      canShoot = false
      canShootTime = canShootTimeMax
      love.audio.play(shootSound)
  end
  for i,bullet in ipairs(bullets) do
    bullet.y = bullet.y - (250 * dt)  
    if(bullet.y < 0) then
      table.remove(bullet, i)
    end
  end
  -- Enemies logic
  createEnemyTime = createEnemyTime - (1 * dt)
  if createEnemyTime < 0 then
    createEnemyTime = createEnemyTimeMax
    
    -- Create an enemy
    randomNumber = math.random(0,  love.graphics.getWidth() - enemyImg:getWidth())
    enemy = {
      x = randomNumber,
      y = -10,
      img = enemyImg
    }
    table.insert(enemies, enemy)
  end
  -- Update enemy position
  for i,enemy in ipairs(enemies) do
    enemy.y = enemy.y + (enemySpeed * dt)
    
    if enemy.y > love.graphics.getHeight() then
      table.remove(enemies,i)
      if (player.points > 0) then
        player.points = player.points - 25
      end
    end
  end
  -- Test collision between bullet and enemy and the enemy dies
 for i, enemy in ipairs(enemies) do
	for j, bullet in ipairs(bullets) do
	   if CheckCollision(bullet.x,bullet.y,bullet.img:getWidth(),bullet.img:getHeight(),
          enemy.x,enemy.y,enemy.img:getWidth(),enemy.img:getHeight()) then
        table.remove(bullets, j)
        table.remove(enemies, i)
        -- Increment the points of player
        player.points = player.points + 50
        -- Player more fast
        if player.speed < 350 then
          player.speed = player.speed + 10
        end
        -- More Enemies
        if createEnemyTimeMax > 0.4 then
            createEnemyTimeMax = createEnemyTimeMax - 0.04
            enemySpeed = enemySpeed + 10
        end
       end
    end
    if CheckCollision(player.x,player.y,player.img:getWidth(),player.img:getHeight(),
        enemy.x,enemy.y,enemy.img:getWidth(),enemy.img:getHeight()) then
      table.remove(enemies, i)
      player.live = false
      love.audio.stop(bgSound)
      love.audio.play(failSound)
    end
  end
  -- End of for-end
end
function love.update(dt)
  if love.keyboard.isDown(' ') and not started then
    started = true
  end
  if started then
    if player.live then
      playGame(dt)
    end
  end
  if not player.live and love.keyboard.isDown('a') then
    love.audio.stop(failSound)
    player.x = 200
    player.y = 500
    
    enemies = {}
    bullets = {}
    player.live = true
    player.points = 0
    createEnemyTimeMax = 1
    createEnemyTime = createEnemyTimeMax
    enemySpeed = 250
  end
end
function love.draw()
  if started and player.live then
    love.graphics.draw(player.img, player.x, player.y)
    love.graphics.printf("Points: " .. player.points, 50,50,200)
    for i,bullet in ipairs(bullets) do
      love.graphics.draw(bullet.img,bullet.x,bullet.y)
    end
    for i,enemy in ipairs(enemies) do
      love.graphics.draw(enemy.img,enemy.x,enemy.y)
    end
  elseif not started then
    love.graphics.printf("Press 'Space' to start the game", (love.graphics.getWidth() / 2 - 100),(love.graphics.getHeight() / 2),200);
  end
  if not player.live then
    love.graphics.printf("You Died with " .. player.points .. " points", (love.graphics.getWidth() / 2 - 100),(love.graphics.getHeight() / 2),200);
    love.graphics.printf("Press 'a' to play again", (love.graphics.getWidth() / 2 - 100),(love.graphics.getHeight() / 2 + 200),200);
  end
end