local spriteManager = require("sprite")
local cartImg = love.graphics.newImage("Images/cart.png")




local cartManager = {}
cartManager.lst_carts = {}

local function removeCart(pCart)
    for i, cart in ipairs(cartManager.lst_carts) do
        if cart == pCart then
            table.remove(cartManager.lst_carts,i)
        end
    end
end

cartManager.newCart = function (pX,pY)
    local cart = spriteManager.newSprite(pX,pY)
    cart.collideBox = {x=2,y=4,w=16,h=17}

    cart.Update = function (dt)

        -- TODO : supprimer les carts coter Droit (Map width)
        if cart.x < 0 then
            removeCart(cart)
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