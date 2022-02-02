local spriteManager = {}
spriteManager.lst_sprites = {}

spriteManager.init = function ()
	spriteManager.lst_sprites = {}
end

spriteManager.newSprite = function (pX,pY)
    local sprite = {}
    sprite.x = pX
    sprite.y = pY
	sprite.supprime = false
	sprite.isFlip = false
    sprite.collideBox = {x = 0,y = 0,w = TILE_SIZE,h = TILE_SIZE} -- Boite de collision du sprite
    sprite.vx = 0
    sprite.vy = 0

    ------ Virtual Functions -------
    sprite.Update = function (dt) end
    sprite.Draw  = function () end
    --------------------------------
    table.insert(spriteManager.lst_sprites,sprite)
    return sprite
end

spriteManager.updateAll = function (dt)
	-- Purge des sprites
	for i = #spriteManager.lst_sprites, 1, -1 do
		local sprite = spriteManager.lst_sprites[i]
		if sprite.supprime then
			table.remove(spriteManager.lst_sprites,i)
		end
	end
	-- Update des sprites
	for i, sprite in ipairs(spriteManager.lst_sprites) do
		sprite.Update(dt)
	end
end

spriteManager.drawAll = function ()
	for i, sprite in ipairs(spriteManager.lst_sprites) do
		sprite.Draw()

		if DEBUG then
			love.graphics.rectangle("line",sprite.x + sprite.collideBox.x,sprite.y + sprite.collideBox.y,
			sprite.collideBox.w,sprite.collideBox.h)
		end
	end
end

-- check if pSprite collides a solid object on tile map 
-- Return true or false 
-- pSprite = object to check collision
-- pDir = direction to check collision
spriteManager.collide_map = function(pSprite,pDir,pMap)
	local x = pSprite.x + pSprite.collideBox.x
	local y = pSprite.y + pSprite.collideBox.y
	local w = pSprite.collideBox.w
	local h = pSprite.collideBox.h
	
	local x1 = 0; local y1 = 0
	local x2 = 0; local y2 = 0

	if pDir == "left" then
	   x1=x-0    y1=y+3
	   x2=x-0    y2=y+h-3

	elseif pDir == "right" then
	   x1=x+w+0  y1=y+3
	   x2=x+w+0  y2=y+h-3

	elseif pDir == "up" then
	   x1=x+3    y1=y-0
	   x2=x+w-3  y2=y-0

	elseif pDir == "down" then
	   x1=x+3    y1=y+h+0
	   x2=x+w-3  y2=y+h+0
	end

	if pMap.isSolidAt(x1,y1) or pMap.isSolidAt(x2,y2) then
		return true
	else
		return false
	end
end

return spriteManager