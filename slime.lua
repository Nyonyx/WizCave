local spriteManager = require("sprite")
local slimeImg = love.graphics.newImage("Images/slime.png")
local util = require("util")
-- TODO : deplacer les fonctions AlignOnline et collide_with_map
-- du module slime et joueur vers un autre module


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
		end
	elseif pPlayer.vx < 0 then
		if spriteManager.collide_map(pPlayer,"left",pMap) then
			pPlayer.vx = 0	
            AlignOnColumn(pPlayer)		
		end
	end
end


local slimeManager = {}
slimeManager.lst_slime = {}
local map = nil -- map reference
local player = nil -- player reference

slimeManager.init = function (pMap,pPlayer)
    map = pMap
    player = pPlayer
end

slimeManager.newSlime = function (pX,pY)
    local slime = spriteManager.newSprite(pX,pY)
    slime.collideBox = {x=2,y=7,w=13,h=9}
    slime.timerJump = math.random(2)
    slime.is_Grounded = false
    slime.jump = function (pDir)
        if slime.is_Grounded then
            slime.is_Grounded = false
            slime.vy = math.random(-4,-2.5)
            if pDir == "right" then
                slime.vx = 1
            elseif pDir == "left" then
                slime.vx = -1
            end
        end
    end

    slime.Update = function (dt)

        -- si le joueur proche, peut commencer a sauter
        if util.dist(slime.x + 8,slime.y + 8,player.x + 16,player.y + 16) < 300 then
            slime.timerJump = slime.timerJump - dt
            if slime.timerJump < 0 then
                slime.timerJump = math.random(2)

                local distX = (slime.x + 8) - (player.x + 16)
                local dir = "right"
                if distX >= 0 then
                    dir = "left"
                end

                slime.jump(dir)
            end

        end

        if slime.is_Grounded then
            slime.vx = 0
        end
        slime.vy = slime.vy + GRAVITY
        slime.x = slime.x + slime.vx
        slime.y = slime.y + slime.vy
        collide_with_map(slime,map)

    end

    slime.Draw = function ()
        love.graphics.draw(slimeImg,slime.x,slime.y)
    end

    table.insert(slimeManager.lst_slime,slime)
    return slime
end


return slimeManager