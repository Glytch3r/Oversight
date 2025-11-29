Oversight = Oversight or {}

function Oversight.setTrailingLightMode(activate, pl)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    if string.lower(pl:getAccessLevel()) == "admin" then
        if activate ~= nil then
            pl:getModData().isTrailLight = activate
        end
    end
end

function Oversight.toggleTrailingLightMode(pl, activate)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    if string.lower(pl:getAccessLevel()) ~= "admin" then return end
    local md = pl:getModData()
    if activate ~= nil then
        md.isTrailLight = activate
    else
        md.isTrailLight = not (md.isTrailLight or false)
    end
end

function Oversight.isTrailingLightMode(pl)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    local md = pl:getModData()
    md.isTrailLight = md.isTrailLight or false
    return md.isTrailLight
end

local ticks = 0

function Oversight.TrailingLight(pl)
    ticks = ticks + 1
    if ticks % 4 ~= 0 then return end

    if not pl then return end
    local cell = pl:getCell()

    local function removeTrail()
        if Oversight.TrailLight then
            cell:removeLamppost(Oversight.TrailLight)
            Oversight.TrailLight = nil
        end
        if Oversight.TrailingMarker then
            Oversight.TrailingMarker:remove()
            Oversight.TrailingMarker = nil
        end
    end

    if string.lower(pl:getAccessLevel()) ~= "admin" then return end

    if not Oversight.isTrailingLightMode(pl) then
        removeTrail()
        return
    end

    local csq = pl:getCurrentSquare()
    if not csq then
        removeTrail()
        return
    end

    if Oversight.trailX and Oversight.trailY and Oversight.trailZ then
        if Oversight.trailX ~= round(csq:getX()) or
           Oversight.trailY ~= round(csq:getY()) or
           Oversight.trailZ ~= round(csq:getZ()) then

            if not pl:isAlive() then
                removeTrail()
                return
            end

            local x, y = Oversight.getXY(pl)
            if not x or not y then
                removeTrail()
                return
            end

            local z = pl:getZ()
            if not z then
                removeTrail()
                return
            end

            if Oversight.TrailLight then
                cell:removeLamppost(Oversight.TrailLight)
                Oversight.TrailLight = nil
            end

            local rad = 5
            Oversight.TrailLight = IsoLightSource.new(x, y, z, 255, 255, 255, 255, rad)
            cell:addLamppost(Oversight.TrailLight)

            Oversight.trailX = x
            Oversight.trailY = y
            Oversight.trailZ = z

            Oversight.glowingMarker(pl, csq)
        end
    else
        Oversight.trailX = round(csq:getX())
        Oversight.trailY = round(csq:getY())
        Oversight.trailZ = round(csq:getZ())
    end
end

Events.OnPlayerUpdate.Remove(Oversight.TrailingLight)
Events.OnPlayerUpdate.Add(Oversight.TrailingLight)

function Oversight.initTrailingLight()
    local pl = getPlayer()
    local x, y, z = round(pl:getX()), round(pl:getY()), pl:getZ()
    Oversight.trailX = x
    Oversight.trailY = y
    Oversight.trailZ = z
end

Events.OnCreatePlayer.Remove(Oversight.initTrailingLight)
Events.OnCreatePlayer.Add(Oversight.initTrailingLight)

function Oversight.randFloat()
    return ZombRand(0,101) / 100
end

function Oversight.glowingMarker(pl, csq)
    if not SandboxVars.Oversight.showTrailingMarkers then return end
    pl = pl or getPlayer()
    if Oversight.TrailingMarker then
        Oversight.TrailingMarker:remove()
        Oversight.TrailingMarker = nil
    end
    csq = csq or pl:getCurrentSquare()
    local r = Oversight.randFloat()
    Oversight.TrailingMarker = getWorldMarkers():addGridSquareMarker(
        "circle_center", "circle_only_highlight", csq, r, r, r, true, r
    )
end
