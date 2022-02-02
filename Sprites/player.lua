local spriteManager = require("Sprites.sprite")

local platformManager = require("Sprites.platforms") -- pour detecter les colisions avec les plateformes
local bulletManager = require("Sprites.bullet") -- pour tirer bullet
local util = require("util")

local playerImg = love.graphics.newImage("Images/Character.png")
local playerManager = {}
playerManager.map = nil

local function AlignOnLine(pSprite)
    local lig = math.floor((pSprite.y + TILE_SIZE/2)/TILE_SIZE) + 1
    pSprite.y = (lig-1)*TILE_SIZE
end

local function AlignOnColumn(pSprite)
    local col = math.floor((pSprite.x + (TILE_SIZE/2) )/TILE_SIZE) + 1
    pSprite.x = (col-1)*TILE_SIZE
end

-- Detection des collisions avec la map
local function collide_with_map(pPlayer,pMap)
	if pPlayer.vy > 0 then
		if spriteManager.collide_map(pPlayer,"down",pMap) then
			pPlayer.vy = 0
            AlignOnLine(pPlayer)
            pPlayer.is_Grounded = true
		end
	elseif pPlayer.vy < 0 then
		if spriteManager.collide_map(pPlayer,"up",pMap) then
			pPlayer.vy = 0	
            AlignOnLine(pPlayer)	
		end
	end
	if pPlayer.vx > 0 then
		if spriteManager.collide_map(pPlayer,"right",pMap) then
			pPlayer.vx = 0	
            AlignOnColumn(pPlayer)	
            pPlayer.x = pPlayer.x - 8
		end
	elseif pPlayer.vx < 0 then
		if spriteManager.collide_map(pPlayer,"left",pMap) then
			pPlayer.vx = 0	
            AlignOnColumn(pPlayer)		
            pPlayer.x = pPlayer.x + 8 
		end
	end
end

playerManager.init = function (pMap)
    playerManager.map = pMap
end



playerManager.newPlayer = function(pX,pY)
    local player = spriteManager.newSprite(pX,pY)
    player.collideBox = {x = 8,y = 16,w = 16,h = 16}
    player.is_Grounded = false
    player.platformUnder = nil
    player.isFlip = false
    player.life = 10
    player.damageTimer = 0.5
    player.is_Damage = false
    player.state = "WALK" -- State Machine

    player.hitbox = {x = 0,y = 0,h = 0,w = 0} -- boite attaque corp a corps
    player.attackTimer = 0.3 -- attack timeout

    player.respawn = function ()
        LoadLevel(playerManager.map.name)
    end


    player.takeDamage = function (pdamage)
        if player.is_Damage == false then -- if we can take damage
            player.is_Damage = true
            player.life = player.life - 1

            if player.life <= 0 then
                player.state = "DEAD"
            end


        end
    end


    player.Update = function (dt)
        if player.is_Damage then
            player.damageTimer = player.damageTimer - dt
            if player.damageTimer < 0 then
                player.damageTimer = 0.5
                player.is_Damage = false
            end
        end

        -- Attack corp a corp
        if love.keyboard.isDown("x") then
            player.state = "ATTACK"
        end

        -- shoot bullet
        if love.keyboard.isDown("c") then
            if player.state ~= "SHOOT" then



                local bullet = nil
                if player.isFlip then
                    bullet = bulletManager.newBullet(player.x+8,player.y+8)
                    bullet.vx = -2
                else
                    bullet = bulletManager.newBullet(player.x+8,player.y+8)
                    bullet.vx = 2
                end

                player.state = "SHOOT"
            end
        end


        if player.state == "WALK" then
            player.vx = 0
            if love.keyboard.isDown("right") then
                player.vx = 1.7
                player.isFlip = false
            end
            if love.keyboard.isDown("left") then
                player.vx = -1.7
                player.isFlip = true
            end
            if love.keyboard.isDown("space") then
                if player.is_Grounded then
                    player.platformUnder = nil
                    player.vy = -3
                    player.is_Grounded = false
                end
            end

        -- Melee Attack
        elseif player.state == "ATTACK" then
            player.vx = 0
            player.attackTimer = player.attackTimer - dt
            if player.attackTimer < 0 then
                player.attackTimer = 0.3
                player.state = "WALK"
            end

            if player.isFlip then
                player.hitbox = {x=0,y=16,w=7,h=16}
            else
                player.hitbox = {x = 25,y=16,w=7,h=16}
            end

            -- Detection collisions
            for i, sprite in ipairs(spriteManager.lst_sprites) do
                if sprite.damage ~= nil and sprite ~= player then

                    local x1 = player.x + player.hitbox.x
                    local y1 = player.y + player.hitbox.y
                    local w1 = player.hitbox.w
                    local h1 = player.hitbox.h
        
                    local x2 = sprite.x + sprite.collideBox.x
                    local y2 = sprite.y + sprite.collideBox.y
                    local w2 = sprite.collideBox.w
                    local h2 = sprite.collideBox.h

                    if util.collide(x1,y1,w1,h1,x2,y2,w2,h2) then
                        sprite.damage() -- Apelle methode damage si le sprite possede la methode
                    end
                end
            end

        elseif player.state == "SHOOT" then
            player.vx = 0
            player.attackTimer = player.attackTimer - dt
            if player.attackTimer < 0 then
                player.attackTimer = 0.3
                player.state = "WALK"
            end
    

        elseif player.state == "DEAD" then
            player.respawn()
        end

        if player.y > playerManager.map.height*TILE_SIZE then
            player.state = "DEAD"
        end

        -- check collisions avec tuiles domagables

        local x1 = player.x + player.collideBox.x
        local y1 = player.y + player.collideBox.y
        local w1 = player.collideBox.w
        local h1 = player.collideBox.h


        local tile1 = playerManager.map.getTileAt(x1,y1,1)
        local tile2 = playerManager.map.getTileAt(x1+w1,y1,1)
        local tile3 = playerManager.map.getTileAt(x1+w1,y1+h1,1)
        local tile4 = playerManager.map.getTileAt(x1,y1+h1,1)
        if playerManager.map.getTilePropertie("damagePlayer",tile1) == true or
           playerManager.map.getTilePropertie("damagePlayer",tile2) == true or 
           playerManager.map.getTilePropertie("damagePlayer",tile3) == true or
           playerManager.map.getTilePropertie("damagePlayer",tile4) == true  then
            player.takeDamage(1)
        end



        -- Check collisions avec echelles
        local tilePlayer1 = playerManager.map.getTileAt(player.x + 16,player.y + 32,1)
        local tilePlayer2 = playerManager.map.getTileAt(player.x + 16,player.y + 30,1)
        local isStair = playerManager.map.getTilePropertie("type",tilePlayer1) == "Stairs" or
                        playerManager.map.getTilePropertie("type",tilePlayer2) == "Stairs"


        if isStair then
            player.vy = 0
            player.y = player.y - GRAVITY
        end
    
        if love.keyboard.isDown("down") then
            if isStair then
                player.vy = 1.7
            end
        end

        if love.keyboard.isDown("up") then
            if isStair then
                player.vy = -1.7
            end
        end




        player.vy = player.vy + GRAVITY

        player.x = player.x + player.vx
        player.y = player.y + player.vy

        collide_with_map(player,playerManager.map)

        -- check Collisions avec plateformes fixes
        local tile = playerManager.map.getTileAt(player.x+16,player.y+32,1)
        local underPlatform = playerManager.map.getTilePropertie("type",tile) == "Platform"
        if underPlatform and player.vy >=0 then
            player.vy = 0
            player.is_Grounded = true
            AlignOnLine(player)
        end



        -- Check Collisions avec les plateformes mobiles
        player.platformUnder = nil
        for i, platform in ipairs(platformManager.lst_platforms) do

            local x1 = player.x + 4
            local y1 = player.y + 30
            local w1 = 24
            local h1 = 3

            local x2 = platform.x + platform.collideBox.x
            local y2 = platform.y + platform.collideBox.y
            local w2 = platform.collideBox.w
            local h2 = platform.collideBox.h


            if util.collide(x1,y1,w1,h1,x2,y2,w2,h2) and player.vy >=0 then
                platform.touchPlayer()
                player.platformUnder = platform
            end
        end

        if player.platformUnder ~= nil then
            player.vy = 0
            player.is_Grounded = true
            player.y = player.platformUnder.y - 32
        end


        -- Detection des collisions avec ennemis et obstacles
        for i, sprite in ipairs(spriteManager.lst_sprites) do

            if sprite.is_Damage and sprite ~= player then
                local x1 = player.x + player.collideBox.x
                local y1 = player.y + player.collideBox.y
                local w1 = player.collideBox.w
                local h1 = player.collideBox.h

                local x2 = sprite.x + sprite.collideBox.x
                local y2 = sprite.y + sprite.collideBox.y
                local w2 = sprite.collideBox.w
                local h2 = sprite.collideBox.h

            
                if util.collide(x1,y1,w1,h1,x2,y2,w2,h2) then
                    player.takeDamage(1)
                end
            end
        end

    end

    player.Draw = function ()
        if player.state ~= "DEAD" then
            if player.is_Damage then
                love.graphics.setColor(1,0,0)
            end
            if player.isFlip then
                love.graphics.draw(playerImg,player.x + 32,player.y,0,-1,1)
            else
                love.graphics.draw(playerImg,player.x,player.y,0,1,1)
            end
            love.graphics.setColor(1,1,1,1)
            
            if DEBUG and player.state == "ATTACK" then
                love.graphics.rectangle("line",player.x + player.hitbox.x,player.y + player.hitbox.y,player.hitbox.w,player.hitbox.h)

            end

            
        end

    end

    return player
end



return playerManager