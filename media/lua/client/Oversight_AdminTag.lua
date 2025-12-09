Oversight = Oversight or {} 

function Oversight.hideAdminTag(pl)
    if Oversight.isHideAdminTag() then
        if pl:isShowAdminTag() then
            pl:setShowAdminTag(false);
            sendPlayerExtraInfo(pl)
        end
    else
        if not pl:isShowAdminTag() then
            pl:setShowAdminTag(true);
            sendPlayerExtraInfo(pl)
        end
    end
end
Events.OnPlayerUpdate.Remove(Oversight.hideAdminTag)
Events.OnPlayerUpdate.Add(Oversight.hideAdminTag)

function Oversight.isHideAdminTag(pl)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    local md = pl:getModData()
    md.isHideAdminTag = md.isHideAdminTag or false
    return md.isHideAdminTag
end

function Oversight.setHideAdminTag(activate, pl)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    if string.lower(pl:getAccessLevel()) == "admin" then
        if activate ~= nil then
            pl:getModData().isHideAdminTag = activate
        end
    end
end

function Oversight.toggleHideAdminTag(pl, activate)
    pl = pl or getPlayer()
    if not pl or not pl:isAlive() then return end
    if string.lower(pl:getAccessLevel()) ~= "admin" then return end
    local md = pl:getModData()
    if activate ~= nil then
        md.isHideAdminTag = activate
    else
        md.isHideAdminTag = not (md.isHideAdminTag or false)
    end
end
