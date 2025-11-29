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

function Oversight.isOnOrOff(bool)
    return bool and "On" or "Off"
end



function Oversight.context(plNum, context, worldobjects, test)
    local pl = getSpecificPlayer(plNum)
    if not pl or not pl:isAlive() then return end
    
    if string.lower(pl:getAccessLevel()) ~= "admin" then return end
    
	local mainMenu = "Oversight:"
	local Main = context:addOptionOnTop(mainMenu)
	Main.iconTexture = getTexture("media/ui/Oversight/OversightContextIcon.png")
	local opt = ISContextMenu:getNew(context)
	context:addSubMenu(Main, opt)
    local sq = luautils.stringStarts(getCore():getVersion(), "42") and ISWorldObjectContextMenu.fetchVars.clickedSquare or clickedSquare
    if not sq then return end

    local csq = pl:getCurrentSquare() 
    if not csq then return end

    local dist = csq:DistTo(sq:getX(), sq:getY())
    if (dist and dist <= 3) or getCore():getDebug() then
 
        local trailLightStatus = Oversight.isTrailingLightMode(pl) or false
        local optTip = opt:addOption("Trailing Light:  "..tostring(Oversight.isOnOrOff(trailLightStatus)), worldobjects, function()            
            Oversight.toggleTrailingLightMode(pl)            
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/LightContextIcon.png")

        local isHideAdminTag = Oversight.isHideAdminTag(pl)
        local optTip =  opt:addOption("Hide Admin Tag:  "..tostring(Oversight.isOnOrOff(isHideAdminTag)), worldobjects, function()
            Oversight.toggleHideAdminTag(pl, activate)
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/AdmTagContextIcon.png")

        local isNVG = pl:isWearingNightVisionGoggles() 
        local optTip = opt:addOption("NVG:  "..tostring(Oversight.isOnOrOff(isNVG)), worldobjects, function()    
            pl:setWearingNightVisionGoggles(not isNVG)        
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/NVGContextIcon.png")

        local optTip = opt:addOption("Level Up", worldobjects, function()    
            Oversight.lvlUp()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/LvlContextIcon.png")

        local isStopZed = pl:isZombiesDontAttack() 
        local optTip = opt:addOption("Prevent Zed Attacks:  "..tostring(Oversight.isOnOrOff(isStopZed)), worldobjects, function()    
            pl:setZombiesDontAttack(not isStopZed)        
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/StopZedContextIcon.png")

        local optTip = opt:addOption("Suicide", worldobjects, function()    
            pl:Kill(pl)
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/RIPContextIcon.png")

        local optTip = opt:addOption("Explode Here", worldobjects, function()    
            local args = { x = pl:getX(), y = pl:getY(), z = pl:getZ() }
            sendClientCommand(pl, 'object', 'addExplosionOnSquare', args)
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/ExplodeContextIcon.png")
        -----------------------            ---------------------------
        local subMenu = "Clear: "
        local Sub = opt:addOptionOnTop(subMenu)
        Sub.iconTexture = getTexture("media/ui/Oversight/ClearContextIcon.png")
        local sbopt = ISContextMenu:getNew(context)
        context:addSubMenu(Sub, sbopt)
  
        local optTip =  sbopt:addOption("Clean Character", worldobjects, function()
            Oversight.washChar()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/WashContextIcon.png")


        local optTip =  sbopt:addOption("Clear Trees", worldobjects, function()
            Oversight.ClearTrees()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/TreesContextIcon.png")
        

        local optTip =  sbopt:addOption("Clear Plants", worldobjects, function()
            Oversight.DespawnPlants()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/PlantsContextIcon.png")

        local optTip =  sbopt:addOption("Clear Cars", worldobjects, function()
            Oversight.DespawnCars()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/CarsContextIcon.png")

        local optTip =  sbopt:addOption("Clear Fire", worldobjects, function()
            Oversight.StopFire()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/NoFireContextIcon.png")
      


        local optTip =  sbopt:addOption("Clear Map Record", worldobjects, function()
            Oversight.ClearMap()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/MapContextIcon.png")


        local optTip =  sbopt:addOption("Clear Floor Items", worldobjects, function()
            Oversight.ClearFloorItems()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/NoItemsContextIcon.png")

        local optTip =  sbopt:addOption("Clear Weather", worldobjects, function()
            Oversight.clearWeather()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/WeatherContextIcon.png")
      
        local optTip =  sbopt:addOption("Clear Corpse", worldobjects, function()
            Oversight.DespawnBodies()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/CorpseContextIcon.png")

        local optTip =  sbopt:addOption("Clear Worn Items", worldobjects, function()
            Oversight.ClearWornItems()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/WornItemsContextIcon.png")
      
        local optTip =  sbopt:addOption("Clear Perks", worldobjects, function()
            Oversight.ClearPerks()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/MemoryContextIcon.png")

         local optTip =  sbopt:addOption("Clear Traits", worldobjects, function()
            Oversight.ClearTraits()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/TraitsContextIcon.png")
      
        local optTip =  sbopt:addOption("Clear Learned Recipes", worldobjects, function()
            Oversight.ClearLearned()
            getSoundManager():playUISound("UIActivateMainMenuItem")
            context:hideAndChildren()
        end)
        optTip.iconTexture = getTexture("media/ui/Oversight/LearnContextIcon.png")
      
        -----------------------            ---------------------------
        if clickedPlayer and clickedPlayer ~= pl then 
            if string.lower(pl:getAccessLevel()) == "admin" then
                local targUser = clickedPlayer:getUsername() 
                if targUser then         
                    print( targUser ) 
                    local optTip = context:addOptionOnTop("Spectate: "..tostring(targUser), worldobjects, function()            
                        Oversight.setSpectate(targUser)
                        getSoundManager():playUISound("UIActivateMainMenuItem")
                        context:hideAndChildren()
                    end)
                    optTip.iconTexture = getTexture("media/ui/Oversight/SpectateContextIcon.png")
                end
            end 
        end 
    end
end
Events.OnFillWorldObjectContextMenu.Remove(Oversight.context)
Events.OnFillWorldObjectContextMenu.Add(Oversight.context)


function Oversight.hideAdminTrade(plNum, context, worldobjects, test)
    if not clickedPlayer then return end    
    if string.lower(clickedPlayer:getAccessLevel()) == "admin" or clickedPlayer:isInvisible()  or clickedPlayer:isGhostMode() then
        context:removeOptionByName(getText("ContextMenu_Trade"))        
    end 
end
Events.OnFillWorldObjectContextMenu.Remove(Oversight.hideAdminTrade)
Events.OnFillWorldObjectContextMenu.Add(Oversight.hideAdminTrade)
