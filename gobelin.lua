local spriteManager = require("sprite")
local gobelinImg = love.graphics.newImage("Images/gobelin.png")

-- TODO :  deplacer ces fonctions dans un fichier commun
--         pour eviter la duplication de code
local function AlignOnLine(pSprite)
    local lig = math.floor((pSprite.y + TILE_SIZE/2)/TILE_SIZE) + 1
    pSprite.y = ((lig-1)*TILE_SIZE) - (32-24)
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


local gobelinManager = {}
gobelinManager.lst_gobelin = {}
local map = nil -- map reference
local player = nil -- player reference

gobelinManager.init = function (pMap,pPlayer)
    map = pMap
    player = pPlayer
end


gobelinManager.newGobelin = function (pX,pY)
    local gobelin = spriteManager.newSprite(pX,pY)
    gobelin.collideBox = {x=0, y=0, w=21, h=24}
    gobelin.is_Grounded = false

    gobelin.state = "PATROL" -- State Machine AI

    gobelin.Update = function (dt)


        if gobelin.state == "PATROL" then
        
        -- Choisi une direction au hazard
        


        -- si collision horizontale ou si case vide
            -- change direction

        -- Si il voit le joueur de ses yeux
            -- passe a FOLLOWPLAYER



        elseif gobelin.state == "FOLLOWPLAYER" then

        end

        if player.x > gobelin.x then
            gobelin.vx = 1
        end

        if player.x < gobelin.x then
            gobelin.vx = -1
        end

        gobelin.vy = gobelin.vy + GRAVITY
        gobelin.x = gobelin.x + gobelin.vx
        gobelin.y = gobelin.y + gobelin.vy
        collide_with_map(gobelin,map)
    end

    gobelin.Draw = function ()
        love.graphics.draw(gobelinImg,gobelin.x,gobelin.y)
    end

    table.insert(gobelinManager.lst_gobelin,gobelin)
    return gobelin
end


return gobelinManager