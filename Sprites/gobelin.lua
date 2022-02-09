local spriteManager = require("Sprites.sprite")
local bulletManager = require("Sprites.bullet")

local gobelinImg = love.graphics.newImage("Images/gobelin.png")
local gobelinPickAxeImg = love.graphics.newImage("Images/gobelinPickAxe.png")
local talk_Sign = love.graphics.newImage("Images/talk_sign.png")
local animSystem = require("animation_system")

local util = require("util")


-- Constantes IA
local giveUpDist = 110 -- distance abandon joueur
local detectPlayerDist = 60-- distance detection joueur
local talkDist = 40 -- distance pour parler a un autre gobelin
local alertDist = 90



-- TODO :  deplacer ces fonctions dans un fichier commun
--         pour eviter la duplication de code
local function AlignOnLine(pSprite)
    local lig = math.floor((pSprite.y + TILE_SIZE/2)/TILE_SIZE) + 1
    pSprite.y = ((lig-1)*TILE_SIZE) 
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
            --AlignOnLine(pPlayer)
            pPlayer.is_Grounded = true
		end
	elseif pPlayer.vy < 0 then
		if spriteManager.collide_map(pPlayer,"up",pMap) then
			pPlayer.vy = 0	
            --AlignOnLine(pPlayer)	
		end
	end
	if pPlayer.vx > 0 then
		if spriteManager.collide_map(pPlayer,"right",pMap) then
			pPlayer.vx = 0	
            --AlignOnColumn(pPlayer)	
            --pPlayer.x = pPlayer.x -8
    
		end
	elseif pPlayer.vx < 0 then
		if spriteManager.collide_map(pPlayer,"left",pMap) then
			pPlayer.vx = 0	
            --AlignOnColumn(pPlayer)	
            --pPlayer.x = pPlayer.x + 8	
		end
	end
end


local gobelinManager = {}
gobelinManager.lst_gobelin = {}
local map = nil -- map reference
local player = nil -- player reference

gobelinManager.init = function (pMap,pPlayer)
    gobelinManager.lst_gobelin = {}
    map = pMap
    player = pPlayer
end


--local detectPlayerDist = 0 

gobelinManager.newGobelin = function (pX,pY,pType)
    local gobelin = spriteManager.newSprite(pX,pY)
    gobelin.collideBox = {x=12, y=24, w=8, h=8}
    gobelin.is_Grounded = false
    gobelin.facingDirection = "right"
    gobelin.state = "PATROL" -- State Machine AI
    gobelin.isRunning = false
    gobelin.oldState = "" -- ancien etat
    gobelin.speed = (love.math.random() * 0.5)+0.5
    gobelin.followSPeed = (love.math.random() * 0.3)+0.8
    gobelin.timer = 0 -- All purpose Timer
    gobelin.jump = function ()
        gobelin.vy = -2.4
        gobelin.is_Grounded = false
    end
    gobelin.havePickAxe = false
    if pType == "PickAxe" then
        gobelin.havePickAxe = true
    end
    

    local function initGobelinAnims()
        ---------------------- Animations ------------------------
        animSystem.initAnimSystem(gobelin,gobelinImg,32,32)
        gobelin.walkAnim = animSystem.addAnim(gobelin,"WALK",{8,9,10,11,12,13,14,15},10,true)
        animSystem.addAnim(gobelin,"SURPRISE",{24,25,26,24},7,false)
        animSystem.addAnim(gobelin,"IDLE",{0,1},4,true)
        animSystem.addAnim(gobelin,"ATTACK",{16,17,18,19,20},10,true)
        animSystem.startAnimation(gobelin,"WALK")
        ---------------------------------------------------------     
    end


    if gobelin.havePickAxe then
        ---------------------- Animations ------------------------
        animSystem.initAnimSystem(gobelin,gobelinPickAxeImg,32,32)
        gobelin.walkAnim = animSystem.addAnim(gobelin,"WALK",{8,9,10,11,12,13,14,15},10,true)
        animSystem.addAnim(gobelin,"SURPRISE",{24,25,26,24},7,false)
        animSystem.addAnim(gobelin,"IDLE",{0,1},4,true)
        animSystem.addAnim(gobelin,"ATTACK",{32,33,34,35,36},10,true)
        animSystem.startAnimation(gobelin,"WALK")
        ---------------------------------------------------------
    else
        initGobelinAnims()
    end

    gobelin.shootAxe = function ()
        local bullet = bulletManager.newBullet(gobelin.x + 16,gobelin.y + 16,"pickAxe")
        if gobelin.facingDirection == "right" then
            bullet.vx = 2
        else
            bullet.vx = -2
        end
        gobelin.timer = 2
        gobelin.state = "ATTACK"
        gobelin.havePickAxe = false

    end





    -- apellé quand il recoit des dommages
    gobelin.damage = function ()
        gobelin.supprime = true
        util.removeSprite(gobelin,gobelinManager.lst_gobelin)
    end
    
local checkPlayer = function (pGobelin)
    local anglePlayer = util.angle(pGobelin.x+16,pGobelin.y+16,player.x+16,player.y+16)
    local distPlayer = util.dist(player.x + 16,player.y + 16,pGobelin.x + 16,pGobelin.y + 16)
    if distPlayer < detectPlayerDist then
        if pGobelin.facingDirection == "right" then
            if anglePlayer > (-math.pi/4) and anglePlayer < (math.pi/4) then                     
                pGobelin.state = "SURPRISE"
                pGobelin.jump()
            end
                
        elseif pGobelin.facingDirection == "left" then
            if (anglePlayer > (3*math.pi)/4 and anglePlayer <= math.pi) or (anglePlayer < -(3*math.pi)/4 and anglePlayer >= -math.pi) then
                
                pGobelin.state = "SURPRISE"
                pGobelin.jump()
            end
        end
    end
end
    
    gobelin.Update = function (dt)

        local distPlayer = util.dist(player.x + 16,player.y + 16,gobelin.x + 16,gobelin.y + 16)

        if distPlayer < 500 then
            animSystem.updateAnim(gobelin,dt)

            -- Saute pour monter les pentes
            
            local tileBehind = map.isSolidAt(gobelin.x + 16 + 32,gobelin.y + 24) == true
            if gobelin.facingDirection == "left" then
                tileBehind = map.isSolidAt(gobelin.x + 16 - 32,gobelin.y + 24) == true
            end


            -- MACHINE A ETAT IA
            if gobelin.state == "PATROL" then
                animSystem.startAnimation(gobelin,"WALK")

                gobelin.timer = gobelin.timer - dt
                if gobelin.timer < 0 then
                    gobelin.state = "IDLE"
                    gobelin.timer = (love.math.random()*3)+2 -- Timer pour passer en mode IDLE
                end

                gobelin.walkAnim.speed = 10
                
                    

                -- detecte les trous vides sous les pieds
                -- pour faire demi tour
                local tilevide = (map.isSolidAt(gobelin.x + 16 + TILE_SIZE,gobelin.y + 24) == false and
                                map.isSolidAt(gobelin.x + 16 + TILE_SIZE,gobelin.y + 24 + TILE_SIZE) == false)  

                if gobelin.facingDirection == "left" then
                        tilevide = (map.isSolidAt(gobelin.x + 16 - TILE_SIZE,gobelin.y + 24) == false and
                         map.isSolidAt(gobelin.x + 16 - TILE_SIZE,gobelin.y + 24 + TILE_SIZE) == false)
                end
                                
                -- change direction si obstacle devant
                if tilevide or tileBehind then
                    gobelin.vx = - gobelin.vx
                end


                -- Si il voit le joueur de ses yeux, suit le joueur
                checkPlayer(gobelin)
                
                -- Ajuste direction
                if gobelin.vx >= 0 then
                    gobelin.facingDirection = "right"
                else
                    gobelin.facingDirection = "left"
                end

                -- Regarde si il peut parler a un autre gobelin
                if gobelin.timer < 4 then
                    for i, gobelin2 in ipairs(gobelinManager.lst_gobelin) do
                        if gobelin ~= gobelin2 then
                            local dist = util.dist(gobelin.x+16,gobelin.y+16,gobelin2.x+16,gobelin2.y+16)
                            if dist < talkDist then
                                gobelin.state = "TALK"
                                gobelin.timer = love.math.random() + 3
                            end
                        end
                    end
                end
                

            elseif gobelin.state == "IDLE" then
                animSystem.startAnimation(gobelin,"IDLE")
                gobelin.vx = 0
                gobelin.timer = gobelin.timer - dt
                if gobelin.timer < 0 then
                    gobelin.state = "PATROL"
                    gobelin.timer = (love.math.random()*6)+10 -- Timer pour passer en mode Patrol
                    if love.math.random() < 0.5 then
                        gobelin.vx = gobelin.speed
                    else
                        gobelin.vx = -gobelin.speed
                    end
                end

                
                
                checkPlayer(gobelin)
                
            elseif gobelin.state == "FOLLOWPLAYER" then
                animSystem.startAnimation(gobelin,"WALK")
                gobelin.walkAnim.speed = 13

                gobelin.timer = gobelin.timer - dt
                if gobelin.timer < 0 then
                    -- Cours vers le joueur
                    gobelin.isRunning = not gobelin.isRunning

                    -- Tire pickaxe
                    if gobelin.havePickAxe then
                        gobelin.shootAxe()
                    else
                        if gobelin.isRunning then
                            gobelin.jump()
                            gobelin.followSPeed = gobelin.followSPeed + 0.5
                            gobelin.walkAnim.speed = gobelin.walkAnim.speed + 1
                            gobelin.timer = 2
                        else
                            gobelin.followSPeed = gobelin.followSPeed - 0.5
                            gobelin.walkAnim.speed = gobelin.walkAnim.speed - 1
                            gobelin.timer = 6 + (love.math.random()*4)
                        end
                    end



                end
                
                if tileBehind and gobelin.is_Grounded then
                   gobelin.jump()
                end

                if player.x > gobelin.x then
                    gobelin.vx = gobelin.followSPeed
                    gobelin.facingDirection = "right"
                end
        
                if player.x < gobelin.x then
                    gobelin.vx = -gobelin.followSPeed
                    gobelin.facingDirection = "left"
                end
                if distPlayer < 20 then
                    gobelin.state = "ATTACK"
                end



                -- Abandonne la proie
                if distPlayer > giveUpDist then
                    -- Passe a Idle ou Patrol
                    local nextState = love.math.random() > 0.5
                    if nextState then
                        gobelin.state = "IDLE"
                    else
                        gobelin.state = "PATROL"
                    end
                    gobelin.speed = (love.math.random() * 0.5)+0.5
                end
                -- test Jump
                --if distPlayer < 30 and gobelin.is_Grounded then
                --    gobelin.jump()
                --end

            elseif gobelin.state == "SURPRISE" then
                gobelin.vx = 0
                -- jouer animation surprise
                animSystem.startAnimation(gobelin,"SURPRISE")
                if animSystem.isEndAnim(gobelin) then
                    gobelin.state = "FOLLOWPLAYER"
                end

                -- Alerte les autres gobelins autour de lui
                for i, gobelin2 in ipairs(gobelinManager.lst_gobelin) do
                    if gobelin ~= gobelin2 then
                        local dist = util.dist(gobelin.x+16,gobelin.y+16,gobelin2.x+16,gobelin2.y+16)
                        if dist < alertDist then
                            gobelin2.state = "FOLLOWPLAYER"
                            --gobelin.timer = love.math.random() + 3
                        end
                    end
                end

            elseif gobelin.state == "TALK" then


                -- Parle avec un autre gobelin
                animSystem.startAnimation(gobelin,"IDLE")
                gobelin.vx = 0

                gobelin.timer = gobelin.timer - dt
                if gobelin.timer < 0 then
                    if love.math.random() > 0.5 then
                        gobelin.state = "PATROL"
                    else
                        gobelin.state = "IDLE"
                    end
                    gobelin.timer = love.math.random()*3
                end
                checkPlayer(gobelin)

            elseif gobelin.state == "ATTACK" then
                
                animSystem.startAnimation(gobelin,"ATTACK")



                gobelin.vx = 0
       
                if animSystem.isEndAnim(gobelin) then
                    gobelin.state = "FOLLOWPLAYER"

                    if gobelin.havePickAxe == false then
                        -- Remet les animations normales
                        initGobelinAnims()
                    end
                end
                


            end

            gobelin.oldState = gobelin.state


            -- Ajoute velocite + Gratite
            gobelin.vy = gobelin.vy + GRAVITY
            collide_with_map(gobelin,map)
            gobelin.x = gobelin.x + gobelin.vx
            gobelin.y = gobelin.y + gobelin.vy

        


            
        end

        table.insert(gobelinManager.lst_gobelin,gobelin)

    end

    gobelin.Draw = function ()
        if gobelin.facingDirection == "right" then
            animSystem.drawAnim(gobelin,true)
        else
            animSystem.drawAnim(gobelin,false)
        end

        if DEBUG_STATE then
            love.graphics.print(gobelin.state,gobelin.x,gobelin.y,0,0.3,0.3)
            local angle = util.angle(gobelin.x+16,gobelin.y+16,player.x+16,player.y+16)
            love.graphics.print(angle,gobelin.x,gobelin.y+8,0,0.3,0.3)
            love.graphics.print(gobelin.facingDirection,gobelin.x,gobelin.y+16,0,0.3,0.3)
            love.graphics.print(gobelin.timer,gobelin.x,gobelin.y+24,0,0.3,0.3)
            --love.graphics.line(player.x+16,player.y+16,gobelin.x+16,gobelin.y+16)
        end

        if gobelin.state == "TALK" then
            if gobelin.facingDirection == "left" then
                love.graphics.draw(talk_Sign,gobelin.x,gobelin.y + math.sin(love.timer.getTime()*10))
            else
                love.graphics.draw(talk_Sign,gobelin.x+32,gobelin.y + math.sin(love.timer.getTime()*10),0,-1,1)
            end
        end
    end

    table.insert(gobelinManager.lst_gobelin,gobelin)
    return gobelin
end


return gobelinManager