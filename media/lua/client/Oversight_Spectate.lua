----------------------------------------------------------------
-----  ▄▄▄   ▄    ▄   ▄  ▄▄▄▄▄   ▄▄▄   ▄   ▄   ▄▄▄    ▄▄▄  -----
----- █   ▀  █    █▄▄▄█    █    █   ▀  █▄▄▄█  ▀  ▄█  █ ▄▄▀ -----
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
--[[ 
function Oversight.spectate(plNum, context, worldobjects, test)
	local pl = getSpecificPlayer(plNum)    
    if not pl then return end
    if not pl:isAlive() then return end
    if not clickedPlayer or clickedPlayer == pl then return end 
    print(clickedPlayer)
    if string.lower(pl:getAccessLevel()) == "admin" then
        local targUser = clickedPlayer:getUsername() 
        if targUser then          
            local optTip = context:addOptionOnTop("Spectate: "..tostring(targUser), worldobjects, function()            
                Oversight.setSpectate(targUser)
                getSoundManager():playUISound("UIActivateMainMenuItem")
                context:hideAndChildren()
            end)
            optTip.iconTexture = getTexture("media/ui/Paradise/SpectateContextIcon.png")
        end
    end 

end
Events.OnFillWorldObjectContextMenu.Remove(Oversight.hideAdminTrade)
Events.OnFillWorldObjectContextMenu.Add(Oversight.hideAdminTrade)

 ]]

Oversight.ISMiniScoreboardUI_doPlayerListContextMenu = Oversight.ISMiniScoreboardUI_doPlayerListContextMenu or ISMiniScoreboardUI.doPlayerListContextMenu
function ISMiniScoreboardUI:doPlayerListContextMenu(targPl, x,y)
    local plNum = self.admin:getPlayerNum()
    local context = ISContextMenu.get(plNum, x + self:getAbsoluteX(), y + self:getAbsoluteY());
    context:addOption(getText("UI_Scoreboard_Teleport"), self, ISMiniScoreboardUI.onCommand, targPl, "TELEPORT");
    context:addOption(getText("UI_Scoreboard_TeleportToYou"), self, ISMiniScoreboardUI.onCommand, targPl, "TELEPORTTOYOU");
    context:addOption(getText("UI_Scoreboard_Invisible"), self, ISMiniScoreboardUI.onCommand, targPl, "INVISIBLE");
    context:addOption(getText("UI_Scoreboard_GodMod"), self, ISMiniScoreboardUI.onCommand, targPl, "GODMOD");
    context:addOption("Check Stats", self, ISMiniScoreboardUI.onCommand, targPl, "STATS");
    local targUser = targPl:getUsername()
    if targUser then
        context:addOption("Spectate: ".. tostring(targUser) , self, ISMiniScoreboardUI.onCommand, targPl, "SPECTATE");
    end
end

Oversight.ISMiniScoreboardUI_onCommand = Oversight.ISMiniScoreboardUI_onCommand or ISMiniScoreboardUI.onCommand
function ISMiniScoreboardUI:onCommand(player, command)
    if command == "SPECTATE" then
        Oversight.setSpectate(player.username)
    else
        Oversight.ISMiniScoreboardUI_onCommand(self, player. command)
    end
end

function Oversight.setSpectate(targUser)
    local pl = getPlayer()
    if not pl or not targUser then return end
    local user = pl:getUsername() 
    if targUser == user then return end      
    pl:getModData().Spectating = targUser
    pl:getModData().SpectateOffset = pl:getModData().SpectateOffset or {x=0,y=0,z=0}
end

function Oversight.isSpectating(pl)
    pl = pl or getPlayer()
    local u = pl:getModData().Spectating
    return u ~= nil
end

function Oversight.getSpectateTarget(pl)
    pl = pl or getPlayer()
    if not pl then return nil end
    if not Oversight.isSpectating(pl) then return nil end
    local u = pl:getModData().Spectating
    if not u then return nil end
    return getPlayerFromUsername(u)
end

function Oversight.getSpectatePoint(pl)
    pl = pl or getPlayer()
    if not pl then return nil,nil,nil end
    if not Oversight.isSpectating(pl) then return nil,nil,nil end
    local t = Oversight.getSpectateTarget(pl)
    if not t then return nil,nil,nil end
    local offset = pl:getModData().SpectateOffset
    local x = t:getX() + offset.x
    local y = t:getY() + offset.y
    local z = t:getZ() + offset.z
    return x,y,z
end
function Oversight.isPlayerInCar(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    return pl:getVehicle() ~= nil
end

function Oversight.doSpectateTP(pl)
    pl = pl or getPlayer()
    if not pl then return end
    Oversight.setSpectateSkin(pl)
    if not Oversight.isSpectating(pl) then return end
    local t = Oversight.getSpectateTarget(pl)
    local x,y,z = Oversight.getSpectatePoint(pl)
    if not t or Oversight.isPlayerInCar(pl) or not x then
        pl:getModData().Spectating = nil
        return
    end
    if luautils.stringStarts(getCore():getVersion(), "42") then
        pl:teleportTo(tonumber(x), tonumber(y), tonumber(z))
    else
        pl:setX(x)
        pl:setY(y)
        pl:setZ(z)
        if isClient() then
            pl:setLx(x)
            pl:setLy(y)
            pl:setLz(z)
        end
    end
end

Events.OnPlayerUpdate.Remove(Oversight.doSpectateTP)
Events.OnPlayerUpdate.Add(Oversight.doSpectateTP)

function Oversight.setSpectateSkin(pl)
    pl = pl or getPlayer()
    if not pl then return end
    if Oversight.isSpectating(pl) then 
        if not pl:isGhostMode() then
            pl:setGhostMode(true)
        end
        if not pl:isInvisible() then
            pl:setInvisible(true)
        end
        pl:renderShadow(0,0,0)   
        pl:setAlpha(0)
        if not pl:isHideWeaponModel() then
            pl:setHideWeaponModel(true)   
        end
    else
        if pl:isHideWeaponModel() then
            pl:setHideWeaponModel(false)
        end
    end

end

function Oversight.setSpectateOffset(key)
    local pl = getPlayer()
    if not pl then return end
    if not Oversight.isSpectating(pl) then return end
    local off = pl:getModData().SpectateOffset

    if key == getCore():getKey("Forward") then
        off.y = off.y - 1
    elseif key == getCore():getKey("Backward") then
        off.y = off.y + 1
    elseif key == getCore():getKey("Left") then
        off.x = off.x - 1
    elseif key == getCore():getKey("Right") then
        off.x = off.x + 1
    elseif key == getCore():getKey("CancelAction") or key == getCore():getKey("Map") then
        pl:getModData().Spectating = nil
    elseif key == 200 then --up
        off.z = math.min(7, math.max(0, off.z + 1))
    elseif key == 208 then --down
        off.z = math.min(7, math.max(0, off.z - 1))
    elseif key == 203 then --left
        local currentTarget = Oversight.getSpectateTarget(pl)
        if currentTarget then
            local nextPl = Oversight.getPrevPl(currentTarget, false)
            if nextPl then
                pl:getModData().Spectating = nextPl:getUsername()
            end
        end
    elseif key == 205 then --right
        local currentTarget = Oversight.getSpectateTarget(pl)
        if currentTarget then
            local nextPl = Oversight.getNextPl(currentTarget, true)
            if nextPl then
                pl:getModData().Spectating = nextPl:getUsername()
            end
        end
    end
    
    return key
end

Events.OnKeyPressed.Remove(Oversight.setSpectateOffset)
Events.OnKeyPressed.Add(Oversight.setSpectateOffset)

-----------------------            ---------------------------
function Oversight.getNextPl(currentPl, forward)

    local players = {}
    for i=0,getNumActivePlayers()-1 do
        local p = getSpecificPlayer(i)
        if p and p:isAlive() and p ~= getPlayer() then
            table.insert(players, p)
        end
    end
    table.sort(players, function(a,b) return a:getUsername() < b:getUsername() end)
    for i,p in ipairs(players) do
        if p == currentPl then
            if forward then
                return players[i % #players + 1]
            else
                return players[(i - 2) % #players + 1]
            end
        end
        return nil
    end
end

function Oversight.getPrevPl(currentPl, forward)
    return Oversight.getNextPl(currentPl, false)
end