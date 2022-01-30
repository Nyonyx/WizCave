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

-- Teste la collision entre 2 collide box
Util.collide = function(x1,y1,x2,y2,x3,y3,x4,y4)
  return x1 < x3+x4 and
         x3 < x1+x2 and
         y1 < y3+y4 and
         y3 < y1+y2
end

return Util