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


--client/Oversight_Spectate.lua
Oversight = Oversight or {}
local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

Oversight.ISMiniScoreboardUI_doPlayerListContextMenu = Oversight.ISMiniScoreboardUI_doPlayerListContextMenu or ISMiniScoreboardUI.doPlayerListContextMenu

function ISMiniScoreboardUI:doPlayerListContextMenu(targPl, x, y)
    local plNum = self.admin:getPlayerNum()
    local context = ISContextMenu.get(plNum, x + self:getAbsoluteX(), y + self:getAbsoluteY());
    context:addOption(getText("UI_Scoreboard_Teleport"), self, ISMiniScoreboardUI.onCommand, targPl, "TELEPORT");
    context:addOption(getText("UI_Scoreboard_TeleportToYou"), self, ISMiniScoreboardUI.onCommand, targPl, "TELEPORTTOYOU");
    context:addOption(getText("UI_Scoreboard_Invisible"), self, ISMiniScoreboardUI.onCommand, targPl, "INVISIBLE");
    context:addOption(getText("UI_Scoreboard_GodMod"), self, ISMiniScoreboardUI.onCommand, targPl, "GODMOD");
    context:addOption("Check Stats", self, ISMiniScoreboardUI.onCommand, targPl, "STATS");
    local targUser = targPl.username
    if targUser then
        context:addOption("Spectate: ".. tostring(targUser), self, function()
            Oversight.setSpectate(targUser)
        end);
    end
end

Oversight.ISMiniScoreboardUI_initialise = Oversight.ISMiniScoreboardUI_initialise or ISMiniScoreboardUI.initialise

function ISMiniScoreboardUI:initialise()
    ISPanel.initialise(self);
    local btnWid = 80
    local btnHgt = FONT_HGT_SMALL + 2
    local y = 10 + FONT_HGT_SMALL + 10
    self.playerList = ISScrollingListBox:new(10, y, self.width - 20, self.height - (5 + btnHgt + 5) - y);
    self.playerList:initialise();
    self.playerList:instantiate();
    self.playerList.itemheight = FONT_HGT_SMALL + 2 * 2;
    self.playerList.selected = 0;
    self.playerList.joypadParent = self;
    self.playerList.font = UIFont.NewSmall;
    self.playerList.doDrawItem = self.drawPlayers;
    self.playerList.drawBorder = true;
    self.playerList.onRightMouseUp = ISMiniScoreboardUI.onRightMousePlayerList;
    self:addChild(self.playerList);
    self.playerList:setOnMouseDoubleClick(self, Oversight.onDoubleClick)
    self.no = ISButton:new(self.playerList.x + self.playerList.width - btnWid, self.playerList.y + self.playerList.height + 5, btnWid, btnHgt, getText("UI_btn_close"), self, ISMiniScoreboardUI.onClick);
    self.no.internal = "CLOSE";
    self.no.anchorTop = false
    self.no.anchorBottom = true
    self.no:initialise();
    self.no:instantiate();
    self.no.borderColor = {r=0.4, g=0.4, b=0.4, a=0.9};
    self:addChild(self.no);
    scoreboardUpdate()
end

function Oversight.onDoubleClick(item)
    if not item then return end
    
    local targ = (item and item.item) and item.item or item
    if not targ then return end
    
    local targUser
    if type(targ) == "string" then
        targUser = targ
    elseif targ.username then
        targUser = targ.username
    end
    
    if targUser then 
        Oversight.setSpectate(targUser)
    end
end

function Oversight.isSpectating(pl)
    pl = pl or getPlayer()
    if not pl then return false end
    
    local targUser = pl:getModData().Spectating
    return targUser ~= nil
end
Oversight.isSpectating(pl)

function Oversight.getSpectateTarg(pl)
    pl = pl or getPlayer()
    if not pl then return nil end
    if not Oversight.isSpectating(pl) then return nil end
    
    local targUser = pl:getModData().Spectating
    if not targUser then return nil end
    
    return getPlayerFromUsername(targUser)
end

function Oversight.getSpectateTargUser(pl)
    pl = pl or getPlayer()
    if not pl then return nil end
    if not Oversight.isSpectating(pl) then return nil end
    local targUser = pl:getModData().Spectating
    if not targUser then return nil end
    return targUser
end

function Oversight.setSpectate(targUser)
    local pl = getPlayer()
    if not pl or not targUser then 
        pl:getModData().Spectating = nil
        return 
    end
    
    local user = pl:getUsername()
    if not user or targUser == user then 
        pl:getModData().Spectating = nil
        return 
    end
    
    pl:getModData().Spectating = targUser
    
    local targPl = getPlayerFromUsername(targUser)
    if targPl then
        pl:getModData().SpectateOffset = {x = 0, y = 0, z = targPl:getZ()}
    else
        pl:getModData().SpectateOffset = {x = 0, y = 0, z = 0}
    end
end

function Oversight.getSpectateTarg(pl)
    pl = pl or getPlayer()
    if not pl then return nil end
    if not Oversight.isSpectating(pl) then return nil end
    
    local u = pl:getModData().Spectating
    if not u then return nil end
    
    return getPlayerFromUsername(u)
end

function Oversight.getSpectatePoint(pl)
    pl = pl or getPlayer()
    if not pl then return nil, nil, nil end
    if not Oversight.isSpectating(pl) then return nil, nil, nil end
    
    local targ = Oversight.getSpectateTarg(pl)
    if not targ then return nil, nil, nil end
    
    local offset = pl:getModData().SpectateOffset
    if not offset then return nil, nil, nil end
    
    local x = targ:getX() + offset.x
    local y = targ:getY() + offset.y
    local z = targ:getZ() + offset.z
    
    return x, y, z
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
    
    local targ = Oversight.getSpectateTarg(pl)
    if not targ then
        pl:getModData().Spectating = nil
        return
    end
    
    if Oversight.isPlayerInCar(pl) then
        pl:getModData().Spectating = nil
        return
    end
    
    local x, y, z = Oversight.getSpectatePoint(pl)
    if not (x and y and z) then return end
    
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
        if SandboxVars.Oversight.AutoInvisible then
            if not pl:isGhostMode() then
                pl:setGhostMode(true)
            end
            if not pl:isInvisible() then
                pl:setInvisible(true)
            end
        end
        if SandboxVars.Oversight.HideAvatar then
            pl:renderShadow(0, 0, 0)
            pl:setAlpha(0)
            if not pl:isHideWeaponModel() then
                pl:setHideWeaponModel(true)
            end
        end

    else

        if pl:isHideWeaponModel() then
            pl:setHideWeaponModel(false)
        end
        pl:setAlpha(1)

        if SandboxVars.Oversight.AutoInvisible then
            if pl:isInvisible() then
                pl:setInvisible(false)
            end
            if pl:isGhostMode() then
                pl:setGhostMode(false)
            end
        end
    end
end