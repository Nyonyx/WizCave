local spriteManager = require("sprite")
local platformManager = {}
platformManager.lst_platforms = {}

local function removePlatform(p)
    for i, plat in ipairs(platformManager.lst_platforms) do
        if plat == p then
            table.remove(platformManager.lst_platforms,i)
        end
    end
end


local tilesheet = {}

platformManager.newPlatform = function (pType,pX,pY,pStartY,pEndY,pTilesheet,pWidth)
    tilesheet = pTilesheet
    local platform = spriteManager.newSprite(pX,pY)
    platform.type = pType
    platform.is_Touch = false -- true if platform is touching player


    if pType == "Vertical" then
        platform.collideBox = {x = 0,y = 0,w = 32,h = 2}
        platform.endY = pEndY or 0
        platform.startY = pStartY or 0
        platform.vy = 0.6
    elseif pType == "Falling" then
        platform.collideBox = {x = 0,y = 0,w = 32,h = 2}
        platform.fallingTimer = 0.6
        platform.supprimeTimer = 1
        platform.is_Falling = false
    
    end



    platform.touchPlayer = function ()
        platform.is_Touch = true

    end

    platform.Update = function (dt)


        if platform.type == "Vertical" then
            if platform.y  > platform.endY then
                platform.vy = -0.6
            end

            if platform.y  < platform.startY then
                platform.vy = 0.6
            end
        elseif platform.type == "Falling" then
            if platform.is_Touch then
                platform.fallingTimer = platform.fallingTimer - dt
                if platform.fallingTimer < 0 then
                    platform.is_Falling = true

                end
            end

            if platform.is_Falling then
                platform.supprimeTimer = platform.supprimeTimer - dt
                if platform.supprimeTimer < 0 then
                    removePlatform(platform) -- remove from platform list
                    platform.supprime = true-- remove from sprite List
                end


                platform.vy = platform.vy + GRAVITY
            end


        end

        platform.y = platform.y + platform.vy



    end

    platform.Draw = function ()
        local quad = love.graphics.newQuad(11*TILE_SIZE,3*TILE_SIZE,TILE_SIZE,TILE_SIZE,tilesheet:getWidth(),tilesheet:getHeight())
        if platform.type == "Vertical" then
            -- platform
            love.graphics.draw(tilesheet,quad,platform.x,platform.y)
            love.graphics.draw(tilesheet,quad,platform.x+TILE_SIZE,platform.y)
            -- Chains
            local num = (platform.y-platform.startY)/TILE_SIZE
            local quadChain = love.graphics.newQuad(11*TILE_SIZE,2*TILE_SIZE,TILE_SIZE,TILE_SIZE,tilesheet:getWidth(),tilesheet:getHeight())
        
            for i = 1, math.floor(num), 1 do
                love.graphics.draw(tilesheet,quadChain,platform.x,platform.y - ((i-1) *TILE_SIZE) - TILE_SIZE )
            end        

            for i = 1, math.floor(num), 1 do
                love.graphics.draw(tilesheet,quadChain,platform.x+32,platform.y - ((i-1) *TILE_SIZE) - TILE_SIZE )
            end     

            local reste = (platform.y-platform.startY)%TILE_SIZE
            if num <= 0 then reste = 0 end
            local quadReste = love.graphics.newQuad(11*TILE_SIZE,2*TILE_SIZE,TILE_SIZE,reste,tilesheet:getWidth(),tilesheet:getHeight())
            love.graphics.draw(tilesheet,quadReste,platform.x,platform.startY) 
            love.graphics.draw(tilesheet,quadReste,platform.x+32,platform.startY) 
        elseif platform.type == "Falling" then
            -- platform
            love.graphics.setColor(1,1,1,platform.supprimeTimer)
            love.graphics.draw(tilesheet,quad,platform.x,platform.y)
            love.graphics.draw(tilesheet,quad,platform.x+TILE_SIZE,platform.y)
            love.graphics.setColor(1,1,1,1)
        end
        
    end

    table.insert(platformManager.lst_platforms,platform)
    return platform
end

return platformManager