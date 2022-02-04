local anim_system = {}

-- Ajoute un composant animation au sprite
anim_system.initAnimSystem = function (pSprite,pTileSheet,pTileWidth,pTileHeight)
    pSprite.animWidth = pTileWidth
    pSprite.animHeight = pTileHeight
    pSprite.currentAnim = ""
    pSprite.currentFrame = 0
    pSprite.animations = {}
    pSprite.tilesheet = pTileSheet
end
-- Ajoute animations sur le sprite
anim_system.addAnim = function (pSprite,pAnimName,frames,pSpeed,pLoop)
    pSprite.animations[pAnimName] = {}
    pSprite.animations[pAnimName].frames = frames
    pSprite.animations[pAnimName].speed = pSpeed
    pSprite.animations[pAnimName].loop = pLoop

end
-- Update animation sur le sprite
anim_system.updateAnim = function (pSprite,dt)
    pSprite.currentFrame = pSprite.currentFrame + (dt*10)
    if pSprite.currentFrame >= #pSprite.animations[pSprite.currentAnim]+1 then
        pSprite.currentFrame = 1
    end
end

anim_system.startAnimation = function (pSprite,pAnimName)
    if pSprite.animations[pAnimName] == nil then
        error("Animation non existante !")
        return
    end


    if pSprite.currentAnim == pAnimName then
        return
    else
        pSprite.currentFrame = 0
        pSprite.currentAnim = pAnimName
    end


end

-- Dessine animation
anim_system.drawAnim = function (pSprite)
    local index = pSprite.animations[pSprite.currentAnim].frames[math.floor(pSprite.currentFrame)]

    local nbCol = (pSprite.tilesheet:getWidth()/pSprite.animWidth)
    
    local l = math.floor(index/nbCol);
    local c = index - (l*nbCol);

    local quad = love.graphics.newQuad(c*pSprite.animWidth,l*pSprite.animHeight,pSprite.animWidth,pSprite.animHeight,pSprite.tilesheet:getWidth(),pSprite.tilesheet:getHeight())
    love.graphics.draw(pSprite.tilesheet,quad,pSprite.x,pSprite.y)
end

return anim_system