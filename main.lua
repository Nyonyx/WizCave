io.stdout:setvbuf('no')                               -- Affiche trace console
love.graphics.setDefaultFilter("nearest")             -- Pixel art
love.window.setMode(1600,1000)                                      
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then -- Debuggeur
  require("lldebugger").start()
end
---------------------------------------------------------------

local json = require("./libs/json")
local Util = require("util")
local mapManager = require("map")
local playerManager = require("player")
local slimeManager = require("slime")
local gobelinManager = require("gobelin")
local spriteManager = require("sprite")

local cartManager = require("minecart")

local player = {}
local camera = {}
local currentMap = {}



--------------- Globals ------------
DEBUG = true
TILE_SIZE = 16
GRAVITY = 0.13
CAMERA_SCALING = 5
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

  --------- Chargement du jeu
  currentMap = mapManager.create(love.filesystem.read("Maps/map1.json"),tilesetsDict)

  
  player = playerManager.newPlayer(22,200)
  camera = {x = 0, y = 0}
  ---------------

  playerManager.init(currentMap)
  slimeManager.init(currentMap,player)
  gobelinManager.init(currentMap,player)

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
  --player.Update(dt,currentMap)
  update_camera(dt)
end


function love.draw()

  local mC = math.floor(Util.screenToworldCoords(love.mouse.getX(),camera.x)/TILE_SIZE)+1
  local mL = math.floor(Util.screenToworldCoords(love.mouse.getY(),camera.y)/TILE_SIZE)+1

  love.graphics.setColor(0.1,0.1,0.2,1)
  love.graphics.rectangle("fill",0,0,LARGEUR_ECRAN,HAUTEUR_ECRAN)
  love.graphics.setColor(1,1,1,1)
  love.graphics.push()
  love.graphics.scale(CAMERA_SCALING,CAMERA_SCALING)
  love.graphics.translate(-camera.x,-camera.y)

  currentMap.Draw()
  player.Draw()
  spriteManager.drawAll()


  love.graphics.setColor(1,1,1,0.3)
  love.graphics.rectangle("fill",(mC-1)*TILE_SIZE,(mL-1)*TILE_SIZE,TILE_SIZE,TILE_SIZE)
  love.graphics.setColor(1,1,1,1)
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
  end
  -----------------------------------------

end

function love.keypressed(key)
  
  print(key)
end
  