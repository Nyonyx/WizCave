local spriteManager = require("Sprites.sprite")
local cartImg = love.graphics.newImage("Images/cart.png")
local util = require("util")



local cartManager = {}
cartManager.lst_carts = {}


cartManager.newCart = function (pX,pY)
    local cart = spriteManager.newSprite(pX,pY)
    cart.collideBox = {x=2,y=4,w=16,h=17}

    cart.Update = function (dt)

        -- TODO : supprimer les carts coter Droit (Map width)
        if cart.x < 0 then
            util.removeSprite(cart,cartManager.lst_carts)
            cart.supprime = true
        end

        cart.vx = -2

        cart.x = cart.x + cart.vx
    end

    cart.Draw = function ()
        love.graphics.draw(cartImg,cart.x,cart.y)
    end

    table.insert(cartManager.lst_carts,cart)
    return cart
end


return cartManager