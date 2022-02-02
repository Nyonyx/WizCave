local spriteManager = require("Sprites.sprite")

local mineCartManager = require("Sprites.minecart")


local spawnerManager = {}
spawnerManager.lst_spawners = {}
spawnerManager.newSpawner = function (pX,pY,pType)
    local spawner = spriteManager.newSprite(pX,pY)
    spawner.x = pX
    spawner.y = pY
    spawner.timer = 5
    spawner.type = pType

    spawner.Update = function (dt)
        spawner.timer = spawner.timer - dt
        if spawner.timer < 0 then
            spawner.timer = math.random(0.3,1)

            if spawner.type == "MineCart" then
                mineCartManager.newCart(spawner.x,spawner.y)
            end


        end
    end

    spawner.Draw = function ()
        
    end



    table.insert(spawnerManager.lst_spawners,spawner)
    return spawner
end


return spawnerManager