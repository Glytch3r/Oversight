----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▓█    █    █   ▀  █▄▄▓█  ▀  ▄█  █ ▄▄▀ -----
----- █  ▀█  █      █      █    █   ▄  █   █  ▄   █  █   █ -----
-----  ▀▀▀▀  ▀▀▀▀   ▀      ▀     ▀▀▀   ▀   ▀   ▀▀▀   ▀   ▀ -----
----------------------------------------------------------------
--                                                            --
--   Project Zomboid Modding Commissions                      --
--   https://steamcommunity.com/id/glytch3r/myworkshopfiles   --
--                                                            --
--   ▫ Discord  ꞉   glytch3r                                  --
--   ▫ Support  ꞉   https://ko-fi.com/glytch3r                --
--   ▫ Youtube  ꞉   https://www.youtube.com/@glytch3r         --
--   ▫ Github   ꞉   https://github.com/Glytch3r               --
--                                                            --
----------------------------------------------------------------
----- ▄   ▄   ▄▄▄   ▄   ▄   ▄▄▄     ▄      ▄   ▄▄▄▄  ▄▄▄▄  -----
----- █   █  █   ▀  █   █  ▀   █    █      █      █  █▄  █ -----
----- ▄▀▀ █  █▀  ▄  █▀▀▀█  ▄   █    █    █▀▀▀█    █  ▄   █ -----
-----  ▀▀▀    ▀▀▀   ▀   ▀   ▀▀▀   ▀▀▀▀▀  ▀   ▀    ▀   ▀▀▀  -----
----------------------------------------------------------------
Oversight = Oversight or {}

function Oversight.randFloat()
    return ZombRand(0, 101) / 100
end

function Oversight.setTrailingLightMode(activate, pl)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    if string.lower(pl:getAccessLevel()) == "admin" then
        if activate ~= nil then
            pl:getModData().isTrailLight = activate
        end
    end
end

function Oversight.toggleTrailingLightMode(pl)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    if string.lower(pl:getAccessLevel()) ~= "admin" then return end
    local md = pl:getModData()
    local active = not (md.isTrailLight or false)
    md.isTrailLight = active
    if not active then       
        Oversight.delTrail()
    end
    if not md.isTrailLight then
        Oversight.delLamp()
    end
end

function Oversight.isTrailingLightMode(pl)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    local md = pl:getModData()
    md.isTrailLight = md.isTrailLight or false
    return md.isTrailLight
end
Oversight.ticks = 0
function Oversight.TrailingLight(pl)
    Oversight.ticks = Oversight.ticks + 1
    if Oversight.ticks % 3 ~= 0 then 
        if not Oversight.isTrailingLightMode(pl) then return end
        
        if string.lower(pl:getAccessLevel()) == "admin" then 
                
                Oversight.addLamp()
                local csq = pl:getCurrentSquare()
                if not csq then return end                
                Oversight.addTrail(pl, csq)
        end
       
    end
end

Events.OnPlayerUpdate.Remove(Oversight.TrailingLight)
Events.OnPlayerUpdate.Add(Oversight.TrailingLight)


-----------------------            ---------------------------

function Oversight.delLamp()
    if Oversight.TrailLight then
        getCell():removeLamppost(Oversight.TrailLight)
        Oversight.TrailLight = nil
    end
end

function Oversight.addLamp()
    Oversight.delLamp()
    local pl = getPlayer()
    if not pl then return end
    
    local x, y, z = round(pl:getX()), round(pl:getY()), pl:getZ()
    
    Oversight.TrailLight = IsoLightSource.new(x, y, z, 255, 255, 255, 255)
    getCell():addLamppost(Oversight.TrailLight)
end


-----------------------            ---------------------------

function Oversight.delTrail()   
    if Oversight.TrailingMarker then
        Oversight.TrailingMarker:remove()
        Oversight.TrailingMarker = nil
    end
end

function Oversight.addTrail(pl, csq)
    if not SandboxVars.Oversight.showTrailingMarkers then return end
    pl = pl or getPlayer()
    csq = csq or pl:getCurrentSquare()
    if not csq then return end
    
    Oversight.delTrail()
    local r = Oversight.randFloat()
    Oversight.TrailingMarker = getWorldMarkers():addGridSquareMarker(
        "circle_center", "circle_only_highlight", csq, r, r, r, true, r
    )
end


