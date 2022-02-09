local spriteManager = require("Sprites.sprite")
local bulletImg = love.graphics.newImage("Images/fireball.png")
local pickAxeImg = love.graphics.newImage("Images/pickaxe.png")


local util = require("util")
local bulletManager = {}
bulletManager.lst_bullets = {}

local map = nil
bulletManager.init = function (pMap)
    bulletManager.lst_bullets = {}
    map = pMap
end


bulletManager.newBullet = function (pX,pY,pType)
    local bullet = spriteManager.newSprite(pX,pY)
    bullet.type = pType
    bullet.collideBox = {x=4,y=4,w=8,h=8}

    if bullet.type == "pickAxe" then
        bullet.rotation = 0
        bullet.img = pickAxeImg
    else
        bullet.img = bulletImg
    end

    bullet.Update = function (dt)
       
        if bullet.type == "pickAxe" then
            if bullet.vx < 0 then
                bullet.rotation = bullet.rotation - (dt*12)
            else
                bullet.rotation = bullet.rotation + (dt*12)
            end
        else


        end

        bullet.x = bullet.x + bullet.vx
        bullet.y = bullet.y + bullet.vy

        -- Collisions with map
        if map.isSolidAt(bullet.x + 8,bullet.y + 8) then
            --bullet.supprime = true
            --util.removeSprite(bullet,bulletManager.lst_bullets)
        end
        
        -- Detection collisions Entites
        for i, sprite in ipairs(spriteManager.lst_sprites) do
            if sprite.damage ~= nil and sprite ~= bullet then
                
                local x1 = bullet.x + bullet.collideBox.x
                local y1 = bullet.y + bullet.collideBox.y
                local w1 = bullet.collideBox.w
                local h1 = bullet.collideBox.h
                
                local x2 = sprite.x + sprite.collideBox.x
                local y2 = sprite.y + sprite.collideBox.y
                local w2 = sprite.collideBox.w
                local h2 = sprite.collideBox.h
                
                if util.collide(x1,y1,w1,h1,x2,y2,w2,h2) then
                    --sprite.damage() -- Apelle methode damage si le sprite possede la methode
                    --bullet.supprime = true
                    --util.removeSprite(bullet,bulletManager.lst_bullets)
                end
            end
        end
        
    end

    bullet.Draw = function ()
        if bullet.type == "pickAxe" then
            
            love.graphics.draw(bullet.img,bullet.x,bullet.y,bullet.rotation,1,1,8,8)
        else
            love.graphics.draw(bullet.img,bullet.x,bullet.y)
        end
        

    end

    table.insert(bulletManager.lst_bullets,bullet)
    return bullet
end


return bulletManager