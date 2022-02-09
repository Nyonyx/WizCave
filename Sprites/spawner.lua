local spriteManager = require("Sprites.sprite")

local mineCartManager = require("Sprites.minecart")


local spawnerManager = {}
spawnerManager.lst_spawners = {}
spawnerManager.newSpawner = function (pX,pY,pType,pObjvx,pObjvy)
    local spawner = spriteManager.newSprite(pX,pY)
    spawner.objVx = pObjvx
    spawner.objVy = pObjvy
    spawner.x = pX
    spawner.y = pY
    spawner.timer = 0
    spawner.type = pType

    spawner.Update = function (dt)
        spawner.timer = spawner.timer - dt
        if spawner.timer < 0 then
            spawner.timer = math.random(0.5,2)

            if spawner.type == "MineCart" then
                local cart = mineCartManager.newCart(spawner.x,spawner.y)
                cart.vx = spawner.objVx
                cart.vy = spawner.objVy
            end


        end
    end

    spawner.Draw = function ()
        
    end



    table.insert(spawnerManager.lst_spawners,spawner)
    return spawner
end


return spawnerManager