local spriteManager = require("sprite")

local platformManager = require("platforms") -- pour detecter les colisions avec les plateformes

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
    player.isFlip = true
    player.life = 10
    player.is_dead = false
    player.damageTimer = 0.5
    player.is_Damage = false

    player.takeDamage = function (pdamage)
        if player.is_Damage == false then -- if we can take damage
            player.is_Damage = true
            player.life = player.life - 1
            player.vx = player.vx - 2

            if player.life <= 0 then
                player.is_dead = true
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



        -- Check Collisions avec les plateformes
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

            local x1 = player.x + player.collideBox.x
            local y1 = player.y + player.collideBox.y
            local w1 = player.collideBox.w
            local h1 = player.collideBox.h

            local x2 = sprite.x + sprite.collideBox.x
            local y2 = sprite.y + sprite.collideBox.y
            local w2 = sprite.collideBox.w
            local h2 = sprite.collideBox.h

            if sprite ~= player then
                if util.collide(x1,y1,w1,h1,x2,y2,w2,h2) then
                    player.takeDamage(1)
                end
            end
        end

    end

    player.Draw = function ()

        if player.is_Damage then
            love.graphics.setColor(1,0,0)
        end
        if player.isFlip then
            love.graphics.draw(playerImg,player.x + 32,player.y,0,-1,1)
        else
            love.graphics.draw(playerImg,player.x,player.y,0,1,1)
        end
        love.graphics.setColor(1,1,1,1)
        


        --love.graphics.rectangle("fill",player.x + player.collideBox.x,player.y + player.collideBox.y,player.collideBox.w,player.collideBox.h)
    end

    return player
end



return playerManager