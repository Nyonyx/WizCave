local anim_system = {}

-- Ajoute un composant animation au sprite
anim_system.initAnimSystem = function (pSprite,pTileSheet,pTileWidth,pTileHeight)
    pSprite.animWidth = pTileWidth
    pSprite.animHeight = pTileHeight
    pSprite.currentAnim = ""
    pSprite.currentFrame = 1
    pSprite.animations = {}
    pSprite.tilesheet = pTileSheet
    pSprite.endAnim = false -- true si animation en cours est terminee au moins 1 fois
end
-- Ajoute animations sur le sprite
anim_system.addAnim = function (pSprite,pAnimName,frames,pSpeed,pLoop)
    pSprite.animations[pAnimName] = {}
    pSprite.animations[pAnimName].frames = frames
    pSprite.animations[pAnimName].speed = pSpeed
    pSprite.animations[pAnimName].loop = pLoop
    return pSprite.animations[pAnimName]
end
-- Update animation sur le sprite
anim_system.updateAnim = function (pSprite,dt)
    if pSprite.animations[pSprite.currentAnim] == nil then
        error("Impossible de demarrer le system animation car animation non existante !")
    end

    local speed = pSprite.animations[pSprite.currentAnim].speed
    pSprite.currentFrame = pSprite.currentFrame + (speed*dt)
    if pSprite.currentFrame > #pSprite.animations[pSprite.currentAnim].frames+1 then

        
        if pSprite.animations[pSprite.currentAnim].loop == true then
            pSprite.currentFrame = 1
            pSprite.endAnim = true
        else
            pSprite.currentFrame = #pSprite.animations[pSprite.currentAnim].frames
            pSprite.endAnim = true
        end
    end
end

anim_system.isEndAnim = function (pSprite)
    return pSprite.endAnim
end

anim_system.startAnimation = function (pSprite,pAnimName)
    if pSprite.animations[pAnimName] == nil then
        error("Animation non existante !")
        return
    end


    if pSprite.currentAnim == pAnimName then
        return
    else
        pSprite.currentFrame = 1
        pSprite.currentAnim = pAnimName
        pSprite.endAnim = false
    end


end

-- Dessine animation
anim_system.drawAnim = function (pSprite,bFlip)
    local index = pSprite.animations[pSprite.currentAnim].frames[math.floor(pSprite.currentFrame)]

    local nbCol = (pSprite.tilesheet:getWidth()/pSprite.animWidth)
    
    local l = math.floor(index/nbCol);
    local c = index - (l*nbCol);

    local quad = love.graphics.newQuad(c*pSprite.animWidth,l*pSprite.animHeight,pSprite.animWidth,pSprite.animHeight,pSprite.tilesheet:getWidth(),pSprite.tilesheet:getHeight())
    
    if bFlip ~= true then
        love.graphics.draw(pSprite.tilesheet,quad,pSprite.x,pSprite.y)
    else
        love.graphics.draw(pSprite.tilesheet,quad,pSprite.x+pSprite.animWidth,pSprite.y,0,-1,1)
    end
end

return anim_system