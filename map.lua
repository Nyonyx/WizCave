
local util = require "util"
-- Ce module permet de créer des maps composée de tuiles
-- Une map possède un tableau 3D de tuiles (Ligne,Colonne,Layer)
-- Une map peut avoir plusieurs couches de tuiles donc tableau 3D.
-- Une tuile est un objet crée par la fonction createTile

-- Import des modules pour creer les objets
local platformManager = require("Sprites.platforms")
local slimeManager = require("Sprites.slime")
local gobelinManager = require("Sprites.gobelin")
local SpawnerManager = require("Sprites.spawner")
local batManager = require("Sprites.bat")
local spikeManager = require("Sprites.spike")

local json = require("./libs/json")

local dict = {} -- Reference to tile Properties
local jsonMap = {} -- Reference Fichier Tiled Map Json

local MapManager = {}

-- Fonction pour créer une tuile
local createTile = function (pGlobalId,pTileSheet)
    local tile = {}
    tile.tilesheet = pTileSheet -- Nom du tileset de cette tuile
    tile.id = pGlobalId
    tile.currentFrame = 1
    tile.animations = {}; -- Animations de cette tuile

    return tile
end

-- retourne la position colone et ligne dune tuile à partir du numero index
local getPositionInTileset = function(pIndex,pTilesetWidth) 
    local c = pIndex%pTilesetWidth
    local l = math.floor(pIndex/pTilesetWidth)
    return {col = c+1,lig = l+1}
end

-- Renvoi le tileset et l'ID local d'une tuile (avec le numero pGlobalId)
-- Pour pouvoir l'identifier et l'afficher
local getTilesetInfo = function(pGlobalId,pMapTilesets)
    local tilesetSelect = nil
    for key, ts in pairs(pMapTilesets) do
        if pGlobalId >= ts.firstgid then
            tilesetSelect = ts
        else
            break
        end
    end
    if tilesetSelect == nil then tilesetSelect = pMapTilesets[1] end
    local localId = pGlobalId - tilesetSelect.firstgid
    return {name = tilesetSelect.source,id = localId}
end


MapManager.create = function (pTiledJson,pTileDict,pName)
    jsonMap = json.decode(pTiledJson);
    dict = pTileDict
    
    print("Creating Map...")
    local Map = {}
    Map.playerSpawn = {x = 0,y = 0}
    Map.endMap = {x = -1,y = -1,w = 0,h = 0, Next_Map = ""}
    Map.width = jsonMap.width
    Map.height = jsonMap.height
    Map.nLayers = #jsonMap.layers
    Map.name = pName
    Map.grid = {} -- Tableau 3D de tuiles

    -- Retourne la propriete dune tuile
    -- renvoi nil si la propriete nexiste pas
    Map.getTilePropertie = function (pPropertieName,pTile)
        if pTile == nil then return nil end
        if dict[pTile.tilesheet].tiles[pTile.id] ~= nil then
            local tileProperties = dict[pTile.tilesheet].tiles[pTile.id]
            return tileProperties[pPropertieName]
        end
        return nil
    end

    -------------- Charge la Map ----------------

    -- Creation des tuiles
    local index = 1
    for l = 1, Map.height, 1 do
        Map.grid[l] = {}
        for c = 1, Map.width, 1 do
            Map.grid[l][c] = {}

            for lay = 1, Map.nLayers, 1 do
                if jsonMap.layers[lay].type == "tilelayer" then
                    local id = jsonMap.layers[lay].data[index]

                    local info = getTilesetInfo(id,jsonMap.tilesets)
                    Map.grid[l][c][lay] = createTile(info.id,info.name)              
                end  
            end

            index = index + 1
        end
    end

    -- Creation des objets
    for lay = 1, Map.nLayers, 1 do
        if jsonMap.layers[lay].type == "objectgroup" then
            for i, obj in ipairs(jsonMap.layers[lay].objects) do
                
                local props = util.EnsureObject(obj.properties)
                if props == nil then props = {} end
                if obj.type == "Player_Spawn" then
                    Map.playerSpawn = {x = obj.x, y = obj.y}

                elseif obj.type == "End_Map" then
                    Map.endMap = {x = obj.x,y = obj.y,w = obj.width,h = obj.height, Next_Map = props.Next_Map}
                elseif obj.type == "Platform1" then
                    platformManager.newPlatform(props.Subtype,obj.x,obj.y,props["StartY"],props["EndY"],dict["tileset.json"].img)
                elseif obj.type == "Slime" then
                    slimeManager.newSlime(obj.x,obj.y)
                elseif obj.type == "Bat" then
                    batManager.newBat(obj.x,obj.y)
                elseif obj.type == "Gobelin" then
                    gobelinManager.newGobelin(obj.x,obj.y-16,props.SubType)
                elseif obj.type == "Spawner" then
                    SpawnerManager.newSpawner(obj.x,obj.y,props.object,props.vx,props.vy)
                elseif obj.type == "Spike" then
                    spikeManager.newSpike(obj.x,obj.y)
                end
            end
        end
    end

    ---------------------------------------------

    Map.getTileAt = function (pX,pY,pLayer)
        local c = math.floor(pX/TILE_SIZE)+1
        local l = math.floor(pY/TILE_SIZE)+1
        if l >= 0 and c >= 0 and c < Map.width and l < Map.height then
            return Map.grid[l][c][pLayer]
        end
    end

    Map.isSolidAt = function(pX,pY)
        
        local lig = math.floor(pY/16)+1
        local col = math.floor(pX/16)+1
        
        -- Tile is solid outside world map (if there is no map)
        if lig < 1 then
            return true
        end
        if col < 1 then
            return true
        end
        if col > Map.width then
            return true
        end

        if lig >= 1 and col >= 1 and col <= Map.width and lig <= Map.height then
            -- Regarde si il y a une tuile solide a cette position
            for lay = 1, Map.nLayers, 1 do
                if jsonMap.layers[lay].type == "tilelayer" then -- Si la layer est de type tile

                    local tile = Map.grid[lig][col][lay]
                    local isSolid = Map.getTilePropertie("isSolid",tile)
                    if (tile ~= nil and isSolid)then
                        return true
                    end
                end
            end
        end
        return false
    end

    Map.Update = function (dt)
        
    end
    Map.Draw = function (pCameraX,pCameraY,pViewWidth,pViewHeight)

        local startC = math.floor(pCameraX/TILE_SIZE)
        local startL = math.floor(pCameraY/TILE_SIZE)

        local widthC = math.floor(pViewWidth/TILE_SIZE)+2
        local widthL = math.floor(pViewHeight/TILE_SIZE)+2

        for l = startL, startL + widthL, 1 do
            for c = startC, startC + widthC, 1 do
                
                for lay = 1, Map.nLayers, 1 do
                    if jsonMap.layers[lay].type == "tilelayer" then

                        if l >= 1 and c >= 1 and l <= Map.height and c <= Map.width then
                            -- Affiche la tuile
                            local tile = Map.grid[l][c][lay]
                            if Map.getTilePropertie("isVisible",tile) ~= false then

                                if tile.id ~= -1 then
                                    local imgSheet = dict[tile.tilesheet].img

                                    local pos = getPositionInTileset(tile.id,imgSheet:getWidth()/TILE_SIZE)
                                    local quad = love.graphics.newQuad((pos.col-1)*TILE_SIZE ,(pos.lig-1)*TILE_SIZE ,TILE_SIZE,TILE_SIZE,imgSheet:getWidth(),imgSheet:getHeight())
                                    love.graphics.draw(imgSheet,quad,(c-1)*TILE_SIZE,(l-1)*TILE_SIZE)
                                end
                            end
                        end

                    end
                end
            end
        end
    end

    return Map

end


return MapManager;