

components.project("text", "drawable")
--[[

ent.text = "my_txt" 

OR 

ent.text = {
    text = "my_txt",
    getText = function(ent) return "txt_dynamic" end
    ox = 0,
    oy = 0
}

]]

local function getText(ent, tabl)
    if tabl.text then
        return tabl.text
    end

    if tabl.component and ent[tabl.component] then
        -- component referencing idiom:
        return ent[tabl.component]
    end

    if tabl.getText then
        return tabl.getText(ent)
    end

    return tabl.default or ""
end



local ORDER=1 -- draw on top of ent

umg.on("rendering:drawEntity", ORDER, function(ent, x,y, rot, sx,sy)
    if not ent.text then
        return
    end

    local limit = 0xfffff
    local font = love.graphics.getFont()
    local txt = ent.text
    local align = "center"
    local dx, dy = 0,0

    if type(txt) == "table" then
        dx, dy = txt.ox or 0, txt.oy or 0
        font = txt.font or love.graphics.getFont()
        align = txt.align or align
        txt = getText(ent, txt)
    end

    assert(type(txt)=="string", "???")
    local escpTxt = text.stripEffects(txt)
    local ox, lines = font:getWrap(escpTxt, limit)
    local oy = font:getHeight() * #lines
    local offsetX = 0

    if align == "center" then
        offsetX = ox / 2
    elseif align == "right" then
        offsetX = ox
    elseif align ~= "justify" then
        align = "left"
    end

    text.printRich(txt, font, x+dx,y+dy, ox, align, rot, sx,sy, offsetX, oy/2)
end)

