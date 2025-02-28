---@param size integer?
---@param name string?
---@return lootplot.targets.ShapeData
return function(size, name)
    size = size or 1
    local coords = {}

    for dx = -size, size do
        for dy = -size, size do
            if not (dx == 0 and dy == 0) then
                coords[#coords+1] = {dx, dy}
            end
        end
    end

    return {
        name = name or ("KING-"..size),
        relativeCoords = coords
    }
end
