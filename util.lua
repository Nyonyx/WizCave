local Util = {}

Util.EnsureObject = function(obj)
    if obj == nil then return nil end
    local properties = {}
    for k, v in pairs(obj) do
      properties[v.name] = v.value
    end
    return properties
end

Util.screenToworldCoords = function (pCoords,pCamCoords)
  return (pCoords / CAMERA_SCALING) + pCamCoords
end

-- Returns the distance between two points.
Util.dist = function(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end
-- Returns the angle between two vectors assuming the same origin.
Util.angle = function(x1,y1, x2,y2) return math.atan2(y2-y1, x2-x1) end

-- Enleve une entitee dune list
Util.removeSprite = function(pSprite,pList)
  for i, sprite in ipairs(pList) do
      if sprite == pSprite then
          table.remove(pList,i)
      end
  end
end

-- Teste la collision entre 2 collide box
Util.collide = function(x1,y1,w1,h1,x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

return Util