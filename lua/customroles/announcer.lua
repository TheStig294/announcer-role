local ROLE = {}
ROLE.nameraw = "announcer"
ROLE.name = "Announcer"
ROLE.nameplural = "Announcers"
ROLE.nameext = "an Announcer"
ROLE.nameshort = "ann"
ROLE.desc = [[You are {role}!
You're {adetective} that can see whenever someone buys an item!]]
ROLE.team = ROLE_TEAM_DETECTIVE
ROLE.shop = {}
ROLE.loadout = {}
ROLE.startingcredits = 1
ROLE.convars = {}
RegisterRole(ROLE)

if SERVER then
    util.AddNetworkString("AnnouncerItemBought")
    util.AddNetworkString("AnnouncerItemNameFound")

    -- Displays the message any announcer sees when someone buys an item
    hook.Add("TTTOrderedEquipment", "AnnouncerItemBought", function(ply, equipment, is_item, is_from_randomat)
        -- Don't tell the announcer about items recieved from randomats
        if is_from_randomat and Randomat and type(Randomat.IsInnocentTeam) == "function" then return end
        net.Start("AnnouncerItemBought")
        net.WriteString(equipment)
        net.WriteBool(tobool(is_item))
        net.WriteString(ROLE_STRINGS_EXT[ply:GetRole()] or "a player")
        net.Send(ply)
    end)

    net.Receive("AnnouncerItemNameFound", function(len, boughtPly)
        local printName = net.ReadString()
        local role = net.ReadString()

        for _, ply in ipairs(player.GetAll()) do
            -- Don't tell an announcer about their own bought items
            if boughtPly == ply then continue end

            if ply:IsAnnouncer() and ply:Alive() and not ply:IsSpec() then
                local message = role .. " bought a " .. printName .. "!"
                message = string.upper(message[1]) .. string.Right(message, #message - 1)
                ply:PrintMessage(HUD_PRINTTALK, message)

                timer.Create("AnnouncerMessageRepeat", 1, 5, function()
                    ply:PrintMessage(HUD_PRINTCENTER, message)
                end)
            end
        end
    end)

    -- Prints a message to all shop roles at the start of a round, telling them there is an announcer
    hook.Add("TTTBeginRound", "AnnouncerAlertMessage", function()
        if player.IsRoleLiving(ROLE_ANNOUNCER) then
            for _, ply in ipairs(player.GetAll()) do
                if SHOP_ROLES[ply:GetRole()] then
                    ply:PrintMessage(HUD_PRINTTALK, "There is an Announcer")
                    ply:PrintMessage(HUD_PRINTCENTER, "There is an Announcer")
                end
            end
        end
    end)
end

if CLIENT then
    net.Receive("AnnouncerItemBought", function()
        local equipment = net.ReadString()
        local is_item = net.ReadBool()
        local role = net.ReadString()
        local printName = equipment

        -- Passive item name getting
        if is_item then
            -- Active item name getting
            local id = tonumber(equipment)
            local info = GetEquipmentItemById(id)

            if info then
                printName = LANG.TryTranslation(info.name)
            else
                printName = equipment
            end
        else
            for _, wep in ipairs(weapons.GetList()) do
                if equipment == WEPS.GetClass(wep) then
                    printName = LANG.TryTranslation(wep.PrintName) or equipment
                end
            end
        end

        net.Start("AnnouncerItemNameFound")
        net.WriteString(printName)
        net.WriteString(role)
        net.SendToServer()
    end)

    hook.Add("TTTTutorialRoleText", "AnnouncerTutorialRoleText", function(role, titleLabel, roleIcon)
        if role == ROLE_ANNOUNCER then
            local roleColor = ROLE_COLORS[ROLE_INNOCENT]
            local detectiveColor = GetRoleTeamColor(ROLE_TEAM_INNOCENT)
            -- The actual explaination of the Announcer
            local html = "The " .. ROLE_STRINGS[ROLE_ANNOUNCER] .. " is a " .. ROLE_STRINGS[ROLE_DETECTIVE] .. " that <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>sees whenever someone buys an item</span>."
            html = html .. "<span style='display: block; margin-top: 10px;'>Instead of getting a DNA Scanner like a vanilla " .. ROLE_STRINGS[ROLE_DETECTIVE] .. ", they see a <span style='color: rgb(" .. detectiveColor.r .. ", " .. detectiveColor.g .. ", " .. detectiveColor.b .. ")'>player's role</span>, and the <span style='color: rgb(" .. detectiveColor.r .. ", " .. detectiveColor.g .. ", " .. detectiveColor.b .. ")'>name of what they bought</span>, when someone buys something.</br></br>This appears as a message in the centre of the screen and in the chatbox.</span></br>"
            html = html .. "Players that are able to buy items are <span style='color: rgb(" .. detectiveColor.r .. ", " .. detectiveColor.g .. ", " .. detectiveColor.b .. ")'>notified at the start of the round</span> that there is an announcer."
            -- Hidden detective stuff
            html = html .. "<span style='display: block; margin-top: 10px;'>Other players will know you are " .. ROLE_STRINGS_EXT[ROLE_DETECTIVE] .. " just by <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>looking at you</span>"
            local special_detective_mode = GetGlobalInt("ttt_detective_hide_special_mode", SPECIAL_DETECTIVE_HIDE_NONE)

            if special_detective_mode > SPECIAL_DETECTIVE_HIDE_NONE then
                html = html .. ", but not what specific type of " .. ROLE_STRINGS[ROLE_DETECTIVE]

                if special_detective_mode == SPECIAL_DETECTIVE_HIDE_FOR_ALL then
                    html = html .. ". <span style='color: rgb(" .. roleColor.r .. ", " .. roleColor.g .. ", " .. roleColor.b .. ")'>Not even you know what type of " .. ROLE_STRINGS[ROLE_DETECTIVE] .. " you are</span>"
                end
            end

            html = html .. ".</span>"

            return html
        end
    end)
end