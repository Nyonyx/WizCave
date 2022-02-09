
io.stdout:setvbuf('no')                               -- Affiche trace console
love.graphics.setDefaultFilter("nearest")             -- Pixel art
love.window.setMode(1600,1000)                                      
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then -- Debuggeur
  require("lldebugger").start()
end
---------------------------------------------------------------

local util = require "util"
local json = require("./libs/json")
local Util = require("util")
local mapManager = require("map")
local playerManager = require("Sprites.player")
local slimeManager = require("Sprites.slime")
local gobelinManager = require("Sprites.gobelin")
local spriteManager = require("Sprites.sprite")
local bulletManager = require("Sprites.bullet")
local batManager = require("Sprites.bat")
local platformManager = require("Sprites.platforms")
local spikeManager = require("Sprites.spike")


local player = {}
local camera = {}
local currentMap = {}

-- TODO : notter tout les proprietes interfaces
-- Noter toutes les proprietes objets Tiled

--------------- Globals ------------
DEBUG = false
DEBUG_INFINITE_LIFE = false
DEBUG_STATE = false
DRAW_COLLIDER_BOXES = false
TILE_SIZE = 16
GRAVITY = 0.13
CAMERA_SCALING = 6
FIRSTMAP = "Temple.json"
--FIRSTMAP = "mine2.json"

LARGEUR_ECRAN = love.graphics.getWidth()
HAUTEUR_ECRAN = love.graphics.getHeight()

-----------------------------------

local function loadTilesProperties(file)
  local properties = {}
  for i, v in ipairs(file.tiles) do
    properties[v.id] = Util.EnsureObject(v.properties)
  end
  return properties
end

-------------------- Charge tout les tilesets ---------------------
local tilesetsDict = {}
local jsonFile = json.decode(love.filesystem.read("Maps/tileset.json"))
tilesetsDict["tileset.json"] = {}
tilesetsDict["tileset.json"].tiles = loadTilesProperties(jsonFile)
tilesetsDict["tileset.json"].img = love.graphics.newImage("Images/tilesetDungeon.png")

-- jsonFile = json.decode(love.filesystem.read("Maps/tileset2.json"))
-- tilesetsDict["tileset2.json"] = {}
-- tilesetsDict["tileset2.json"].tiles = loadTilesProperties(jsonFile)
-- tilesetsDict["tileset2.json"].img = love.graphics.newImage("Images/tileset2.png")
--------------------------------------------------------------------



function love.load()
  print("--------------DEBUT-------------------")

  -- Creation du joueur
  player = playerManager.newPlayer(0,0)
  if DEBUG_INFINITE_LIFE then player.maxLife = 1000; player.life = 1000 end


  --- Chargement du niveau
  LoadLevel(FIRSTMAP)
end

function LoadLevel(pLevelName)
  spriteManager.init(player)
  platformManager.init()
  playerManager.init(currentMap)
  slimeManager.init(currentMap,player)
  gobelinManager.init(currentMap,player)
  bulletManager.init(currentMap)
  batManager.init(currentMap,player)
  spikeManager.init(player)


  --------- Chargement de la map ------------------
  currentMap = mapManager.create(love.filesystem.read("Maps/"..pLevelName),tilesetsDict,pLevelName)
  --------------------------------------------------

  -- Positionne Joueur
  player.x = currentMap.playerSpawn.x
  player.y = currentMap.playerSpawn.y
  --
  camera = {x = 0, y = 0}

  
  
  ---------------
  -- TEST
  if DEBUG then
   -- batManager.newBat(player.x,player.y-32)
    --slimeManager.newSlime(player.x,player.y-32)
    --gobelinManager.newGobelin(player.x,player.y-32)
  end


end

local function update_camera(dt)
  -- Move Camera
  local posx = (player.x + (TILE_SIZE/2)) - ((LARGEUR_ECRAN/2)/CAMERA_SCALING)
	local posy = (player.y + (TILE_SIZE/2)) - ((HAUTEUR_ECRAN/2)/CAMERA_SCALING)

  camera.x = posx
  camera.y = posy

	-- Clamp camera
	if camera.x < 0 then
		camera.x = 0
	end
	if Util.screenToworldCoords(LARGEUR_ECRAN,camera.x) > currentMap.width * TILE_SIZE then
		camera.x = (currentMap.width * TILE_SIZE) - (LARGEUR_ECRAN/CAMERA_SCALING)
	end

	if camera.y < 0 then
		camera.y = 0
	end
	if Util.screenToworldCoords(HAUTEUR_ECRAN,camera.y) > currentMap.height * TILE_SIZE then
		camera.y = (currentMap.height * TILE_SIZE) - (HAUTEUR_ECRAN/CAMERA_SCALING)
	end
end


function love.update(dt)
  currentMap.Update(dt)

  spriteManager.updateAll(dt)
  
  -- check player Map changes
  local x1 = player.x + player.collideBox.x
  local y1 = player.y + player.collideBox.y
  local w1 = player.collideBox.w
  local h1 = player.collideBox.h

  local x2 = currentMap.endMap.x
  local y2 = currentMap.endMap.y
  local w2 = currentMap.endMap.w
  local h2 = currentMap.endMap.h
  if util.collide(x1,y1,w1,h1,x2,y2,w2,h2) then
    -- Change Map
    LoadLevel(currentMap.endMap.Next_Map)
  end

  update_camera(dt)
end


function love.draw()

  local mC = math.floor(Util.screenToworldCoords(love.mouse.getX(),camera.x)/TILE_SIZE)+1
  local mL = math.floor(Util.screenToworldCoords(love.mouse.getY(),camera.y)/TILE_SIZE)+1

  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle("fill",0,0,LARGEUR_ECRAN,HAUTEUR_ECRAN)
  love.graphics.setColor(1,1,1,1)
  love.graphics.push()
    love.graphics.scale(CAMERA_SCALING,CAMERA_SCALING)
    love.graphics.translate(-camera.x,-camera.y)

    currentMap.Draw(camera.x,camera.y,LARGEUR_ECRAN/CAMERA_SCALING,HAUTEUR_ECRAN/CAMERA_SCALING)
    player.Draw()
    spriteManager.drawAll()

    if DEBUG then
      love.graphics.setColor(1,1,1,0.3)
      love.graphics.rectangle("fill",(mC-1)*TILE_SIZE,(mL-1)*TILE_SIZE,TILE_SIZE,TILE_SIZE)
      love.graphics.setColor(1,1,1,1)
    end

  love.graphics.pop()

  -------------- Draw Debug UI ------------
  if DEBUG then
    local tileMouse = currentMap.grid[mL][mC]
    for i = 1, #tileMouse, 1 do
      local tile = tileMouse[i]
      love.graphics.print("Layer: "..i,128*i,0)
      love.graphics.print("tileset: "..tile.tilesheet,128*i,16)
      love.graphics.print("id: "..tile.id,128*i,32)

      local properties = tilesetsDict[tile.tilesheet].tiles[tile.id]
      if properties ~= nil then
        local i2 = 0
        for key, value in pairs(properties) do
          
          love.graphics.print(key..": "..tostring(value),128*i,48 + (i2*16) )
          i2 = i2 + 1
        end
        
      end
    end

    love.graphics.print("DEBUG MODE",0,0)
    love.graphics.print("x "..player.x,0,16)
    love.graphics.print("y "..player.y,0,32)
    love.graphics.print("life "..player.life,0,48)
    love.graphics.print("FPS "..love.timer.getFPS(),0,64)
  end
  -----------------------------------------


  -- Draw UI

  -- Life Bar
  love.graphics.setColor(1,0,0,1)
  love.graphics.rectangle("fill",0,0, 300 * (player.life/player.maxLife) ,32)
  love.graphics.setColor(1,1,1,1)

  -- Mana Bar

  love.graphics.setColor(0,0,1,1)
  love.graphics.rectangle("fill",0,34, 300 * (player.mana/player.maxMana) ,32)
  love.graphics.setColor(1,1,1,1)

end

function love.keypressed(key)
  
  print(key)
end
  