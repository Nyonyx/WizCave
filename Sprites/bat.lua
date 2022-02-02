local spriteManager = require("Sprites.sprite")
local batImg = love.graphics.newImage("Images/ennemy_bat.png")
local util = require("util")

local batManager = {}
batManager.lst_bat = {}

local player = nil
local map = nil
batManager.init = function (pMap,pPlayer)
    batManager.lst_bat = {}
    map = pMap
    player = pPlayer
end

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
			pPlayer.vy = -pPlayer.vy
            AlignOnLine(pPlayer)
            
            pPlayer.is_Grounded = true
            pPlayer.y = pPlayer.y + 4
		end
	elseif pPlayer.vy < 0 then
		if spriteManager.collide_map(pPlayer,"up",pMap) then
			pPlayer.vy = -pPlayer.vy
            AlignOnLine(pPlayer)	
            pPlayer.y = pPlayer.y - 4
		end
	end
	if pPlayer.vx > 0 then
		if spriteManager.collide_map(pPlayer,"right",pMap) then
			pPlayer.vx = -pPlayer.vx
            AlignOnColumn(pPlayer)	
            pPlayer.x = pPlayer.x + 4
		end
	elseif pPlayer.vx < 0 then
		if spriteManager.collide_map(pPlayer,"left",pMap) then
			pPlayer.vx = -pPlayer.vx
            AlignOnColumn(pPlayer)		
            pPlayer.x = pPlayer.x - 4
		end
	end
end

batManager.newBat = function (pX,pY)
    local bat = spriteManager.newSprite(pX,pY)
    bat.is_Damage = true -- donne des degats au joueur
    bat.directionTimer = 0
    bat.offset = 0
    bat.collideBox = {x = 4,y = 4,w = 8,h = 8}
    bat.speed = 1
    bat.excitedTimer = 0

    bat.state= "FLY"

    bat.damage = function ()
        bat.supprime = true
        util.removeSprite(bat,batManager.lst_bat)
    end

    bat.Update = function (dt)

        if util.dist(bat.x+8,bat.y+8,player.x+16,player.y+16) < 200 then

            if bat.state == "FLY" then
                bat.speed = 0.8
            
                local angle = util.angle(player.x + 16,player.y + 16,bat.x + 8,bat.y + 8)
                bat.directionTimer = bat.directionTimer - dt
                if bat.directionTimer < 0 then
                    bat.directionTimer = math.random(0.3,1)
                    bat.offset = math.random((-math.pi/4) ,math.pi/4)

                    bat.vx = -bat.speed*math.cos(angle + bat.offset)
                    bat.vy = -bat.speed*math.sin(angle + bat.offset)
                end


            elseif bat.state == "EXCITED"then
                
                bat.speed = 1.4

                local angle = util.angle(player.x + 16,player.y + 16,bat.x + 8,bat.y + 8)
                bat.directionTimer = bat.directionTimer - dt
                if bat.directionTimer < 0 then
                    bat.directionTimer = math.random(0.2,0.4)
                    bat.offset = math.random((-math.pi/8) ,math.pi/8)

                    bat.vx = -bat.speed*math.cos(angle + bat.offset)
                    bat.vy = -bat.speed*math.sin(angle + bat.offset)
                end

                bat.excitedTimer = bat.excitedTimer - dt
                if bat.excitedTimer < 0 then
                    bat.state = "FLY"
                end
            end

            local x1 = bat.x + bat.collideBox.x
            local y1 = bat.y + bat.collideBox.y
            local w1 = bat.collideBox.w
            local h1 = bat.collideBox.h
            
            local x2 = player.x + player.collideBox.x
            local y2 = player.y + player.collideBox.y
            local w2 = player.collideBox.w
            local h2 = player.collideBox.h

            if util.collide(x1,y1,w1,h1,x2,y2,w2,h2) then
                if bat.state ~= "EXCITED" then
                    bat.state = "EXCITED"
                    bat.directionTimer = 0
                    bat.excitedTimer = 5
                end
            end

            bat.x = bat.x + bat.vx
            bat.y = bat.y + bat.vy


            -- Collisions with map
            collide_with_map(bat,map)

        end


    end

    bat.Draw = function ()
        local quad = love.graphics.newQuad(0,2*TILE_SIZE,TILE_SIZE,TILE_SIZE,batImg:getWidth(),batImg:getHeight())
        love.graphics.draw(batImg,quad,bat.x,bat.y)
        --love.graphics.circle("fill",bat.x + 8,bat.y + 8,4)

    end

    table.insert(batManager.lst_bat,bat)
    return bat
end


return batManager