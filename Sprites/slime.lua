local spriteManager = require("Sprites.sprite")
local slimeImg = love.graphics.newImage("Images/slime.png")
local animSystem = require("animation_system")
local util = require("util")
-- TODO : deplacer les fonctions AlignOnline et collide_with_map
-- du module slime et joueur vers un autre module


local function AlignOnLine(pSprite)
    local lig = math.floor((pSprite.y + TILE_SIZE/2)/TILE_SIZE) + 1
    pSprite.y = ((lig-1)*TILE_SIZE)
end

local function AlignOnColumn(pSprite)
    local col = math.floor((pSprite.x + (TILE_SIZE/2) )/TILE_SIZE) + 1
    pSprite.x = (col-1)*TILE_SIZE
end

-- Detection des collisions avec la map
local function collide_with_map(pSlime,pMap)
	if pSlime.vy > 0 then
		if spriteManager.collide_map(pSlime,"down",pMap) then
            --pSlime.y = pSlime.y - pSlime.vy
            AlignOnLine(pSlime)
			pSlime.vy = 0
            --AlignOnLine(pSlime)
            --pSlime.y = pSlime.y + TILE_SIZE-(pSlime.collideBox.y +pSlime.collideBox.h)
            pSlime.is_Grounded = true
            
		end
	elseif pSlime.vy < 0 then
		if spriteManager.collide_map(pSlime,"up",pMap) then
            
			pSlime.vy = 0	
		end
	end
	if pSlime.vx > 0 then
		if spriteManager.collide_map(pSlime,"right",pMap) then
			pSlime.vx = 0	
            --AlignOnColumn(pSlime)	
            --pSlime.x = pSlime.x + pSlime.collideBox.x
		end
	elseif pSlime.vx < 0 then
		if spriteManager.collide_map(pSlime,"left",pMap) then
			pSlime.vx = 0	
            --AlignOnColumn(pSlime)		
		end
	end
end


local slimeManager = {}
slimeManager.lst_slime = {}
local map = nil -- map reference
local player = nil -- player reference

slimeManager.init = function (pMap,pPlayer)
    slimeManager.lst_slime = {}
    map = pMap
    player = pPlayer
end

slimeManager.newSlime = function (pX,pY)
    local slime = spriteManager.newSprite(pX,pY)
    slime.collideBox = {x=2,y=7,w=13,h=9}
    slime.timerJump = math.random(2)
    slime.is_Grounded = false


    slime.is_Damage = true -- donne des degats au joueur
    animSystem.initAnimSystem(slime,slimeImg,16,16)
    animSystem.addAnim(slime,"IDLE",{0,1},3,true)
    animSystem.startAnimation(slime,"IDLE")
    -- apellé quand il recoit des dommages
    slime.damage = function ()
        slime.supprime = true
        util.removeSprite(slime,slimeManager.lst_slime)
    end

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
        animSystem.updateAnim(slime,dt)
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
        local quad = nil
        if slime.is_Grounded then
            animSystem.drawAnim(slime,false)
        else
            quad = love.graphics.newQuad(32,0,16,16,slimeImg:getWidth(),slimeImg:getHeight())
            love.graphics.draw(slimeImg,quad,slime.x,slime.y)
        end


    end

    table.insert(slimeManager.lst_slime,slime)
    return slime
end


return slimeManager