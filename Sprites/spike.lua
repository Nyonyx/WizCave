local spriteManager = require("Sprites.sprite")
local spikeImg = love.graphics.newImage("Images/spike.png")
local util = require("util")
local spikeManager = {}

local player = nil
spikeManager.init = function (pPlayer)
    player = pPlayer
end


spikeManager.newSpike = function (pX,pY)
    local spike = spriteManager.newSprite(pX,pY)
    spike.type = "spike"
    spike.is_active = false
    spike.is_Damage = true
    print("crate spike"..spike.x.." "..spike.y)
    spike.Update = function (dt)
        if util.dist(spike.x+8,spike.y+8,player.x+16,player.y+16) < 100 then
            if spike.x < player.x+16 and spike.x+16 > player.x+16 then
                spike.is_active = true
            end
        end


        if spike.is_active then
            spike.vy = spike.vy + GRAVITY
        end

        spike.y = spike.y + spike.vy

    end

    spike.Draw = function ()
        love.graphics.draw(spikeImg,spike.x,spike.y)
    end
    return spike
end


return spikeManager