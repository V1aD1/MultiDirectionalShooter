function love.load()
	screen = {}
	screen.length = 800
	screen.width = 800

	love.graphics.setBackgroundColor(0, 204, 0)

	timeFactor = 1
	enemySpeed = 100

	--love.window.setMode(screen.width, screen.length,
	--	{resizable = true, minwidth = 300, minheight=300})

	--default screen size: width = 800, height = 800

	player = {}
	player.x = screen.length/2
	player.y = screen.width/2
	player.radius = 15
	player.segments = 30
	player.speed = 200
	player.shots = {}
	player.shotSpeed = 300

	enemies = {}
	for i=1,4,3 do --x
		for j =1,4,3 do --j
			enemy = {}
			enemy.radius = 20
			enemy.segments = 30
			enemy.speed = enemySpeed
			enemy.x = (screen.length/5)*i
			enemy.y = (screen.width/5)*j
			enemy.rise = 0
			enemy.run = 0
			table.insert(enemies,enemy)
		end
	end


end

function love.update(dt)

	local playerSpeed
	local remEnemy = {}
	local remShot = {}

	-- keyboard actions for player
	if love.keyboard.isDown(" ") then
		timeFactor = 2
	else
		timeFactor = 1
	end

	if love.mouse.isDown("l") then
		shoot(dt*player.speed)
		playerSpeed = player.speed/2
	else 
		playerSpeed = player.speed
	end

	if love.keyboard.isDown("w") then
		player.y = player.y - dt*playerSpeed/timeFactor
	end

	if love.keyboard.isDown("s") then
		player.y = player.y + dt*playerSpeed/timeFactor
	end

	if love.keyboard.isDown("a") then
		player.x = player.x - dt*playerSpeed/timeFactor
	end

	if love.keyboard.isDown("d") then
		player.x = player.x + dt*playerSpeed/timeFactor
	end

	--update the shots
	for i,v in ipairs(player.shots) do
		v.y = v.y + v.rise/timeFactor
		v.x = v.x + v.run/timeFactor

		if(collision(v) ~= nil) then
			table.insert(remEnemy, collision(v))
			enemySpeed = math.random(100, 200)
			createEnemy()
		end

		-- mark shots that are not visible for removal
        if v.y > screen.length or v.y<0 
        	or v.x > screen.width or v.x< 0 then
            table.insert(remShot, i)
        end
	end



	--update enemy movement
	for i, v in ipairs(enemies) do

		v.run, v.rise = enemyMovement(player.x - v.x, 
					  player.y - v.y, 
					  dt*enemy.speed)
		v.y = v.y + v.rise/timeFactor
		v.x = v.x + v.run /timeFactor
	end

	--remove invalid enemies
	for i, v in ipairs(remEnemy) do
		table.remove(enemies, v)
	end

	--remove invalid shots
	for i, v in ipairs(remShot) do
		table.remove(player.shots, v)
	end

end

function love.draw()

    -- draw player
    love.graphics.setColor(255,255,0,255)
    love.graphics.circle("fill", player.x, player.y, player.radius, player.segments)

    -- draw shots
    love.graphics.setColor(255,255,255,255)
    for i, v in ipairs(player.shots) do
    	love.graphics.rectangle("fill", v.x, v.y, 2, 5)
    end

    --draw enemies
    love.graphics.setColor(255, 0, 0, 255)
    for i, v in ipairs(enemies) do
    	love.graphics.circle("fill", v.x, v.y, v.radius, v.segments)
    end


end

function shoot(distance)

    local shot = {}
    shot.x = player.x
    shot.y = player.y

    --must compute rise and run of shot
    mouseX, mouseY = love.mouse.getPosition()
    shot.run, shot.rise = shotMovement(mouseX-player.x, mouseY - player.y, distance)

    table.insert(player.shots, shot)

end

function shotMovement(xDiff, yDiff, distance)
	-- a is the constant between x/y
	a = math.abs(xDiff/yDiff)

	rise = math.sqrt(distance^2/(a^2+1))
	run = a*rise

	if xDiff < 0 then
		run = -1 * run
	end

	if yDiff < 0 then
		rise = -1 * rise
	end

	return run, rise

end

function collision(shot)
	
	-- check if shot collided with any enemy
	for i, v in ipairs(enemies) do
		if  shot.x < (v.x + v.radius) and 
			shot.x > (v.x - v.radius) and
			shot.y < (v.y + v.radius) and
			shot.y > (v.y - v.radius) then

			-- a shot has connected with an enemy,
			-- therefore must remove enemy from
			-- respective table

			return i
		end
	end
	return nil
end

function enemyMovement(xDiff, yDiff, distance)

	-- a is the constant between x/y
	a = math.abs(xDiff/yDiff)

	rise = math.sqrt(distance^2/(a^2+1))
	run = a*rise

	if xDiff < 0 then
		run = -1 * run
	end

	if yDiff < 0 then
		rise = -1 * rise
	end

	return run, rise

end

function createEnemy()
	-- randomly creates an enemy on the screen
	enemy = {}
	enemy.radius = 20
	enemy.segments = 30
	enemy.speed = enemySpeed
	enemy.x = (screen.length/math.random(1, 5))
	enemy.y = (screen.width/math.random(1, 5))
	enemy.rise = 0
	enemy.run = 0
	table.insert(enemies,enemy)
end
