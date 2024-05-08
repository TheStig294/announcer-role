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
ROLE.shortdesc = "Notified whenever someone buys an item. Sees the name of the item, but not who it was"

CreateConVar("ttt_announcer_show_role", 0, {FCVAR_NOTIFY}, "Whether or not to show the role of an item-purchasing player")

ROLE.convars = {
    {
        cvar = "ttt_announcer_show_role",
        type = ROLE_CONVAR_TYPE_BOOL
    }
}

RegisterRole(ROLE)

if SERVER then
    util.AddNetworkString("AnnouncerItemBought")
    util.AddNetworkString("AnnouncerItemNameFound")
    local ignoreEquipmentOrders = false

    hook.Add("TTTBeginRound", "AnnouncerBeginRound", function()
        -- Prints a message to all shop roles at the start of a round, telling them there is an announcer
        if player.IsRoleLiving(ROLE_ANNOUNCER) then
            for _, ply in ipairs(player.GetAll()) do
                if SHOP_ROLES[ply:GetRole()] and ply:GetRole() ~= ROLE_ANNOUNCER then
                    ply:PrintMessage(HUD_PRINTTALK, "There is an Announcer")
                    ply:PrintMessage(HUD_PRINTCENTER, "There is an Announcer")
                end
            end
        end

        -- Stops announcers from seeing "Someone bought a body armour" or other loadout items at the start of the round
        ignoreEquipmentOrders = true

        timer.Simple(1, function()
            ignoreEquipmentOrders = false
        end)
    end)

    -- Displays the message any announcer sees when someone buys an item
    hook.Add("TTTOrderedEquipment", "AnnouncerItemBought", function(ply, equipment, is_item, is_from_randomat)
        -- Ignore loadout items (the first second of each round) and don't bother with this function if there is no announcer to announce to
        if ignoreEquipmentOrders or not player.IsRoleLiving(ROLE_ANNOUNCER) then return end
        -- Don't tell the announcer about items received from randomats
        if is_from_randomat and Randomat and type(Randomat.IsInnocentTeam) == "function" then return end
        local role = "someone"

        if GetConVar("ttt_announcer_show_role"):GetBool() then
            role = ROLE_STRINGS_EXT[ply:GetRole()]
        end

        net.Start("AnnouncerItemBought")
        net.WriteString(equipment)
        net.WriteBool(tobool(is_item))
        net.WriteString(role)
        net.Send(ply)
    end)

    net.Receive("AnnouncerItemNameFound", function(len, boughtPly)
        local printName = net.ReadString()
        local role = net.ReadString()

        for _, ply in ipairs(player.GetAll()) do
            -- Do not announce a player's own items
            if ply:IsAnnouncer() and ply:Alive() and not ply:IsSpec() and ply ~= boughtPly then
                -- Don't include the player's role if an impersonator or deputy is in the round
                if player.IsRoleLiving(ROLE_DEPUTY) or player.IsRoleLiving(ROLE_IMPERSONATOR) then
                    role = "someone"
                end

                local message = role .. " bought a " .. printName .. "!"
                -- Capitalising the first letter of the message
                message = string.SetChar(message, 1, string.upper(message[1]))
                ply:PrintMessage(HUD_PRINTTALK, message)
                ply:PrintMessage(HUD_PRINTCENTER, message)

                timer.Simple(2, function()
                    ply:PrintMessage(HUD_PRINTCENTER, message)
                end)
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

    local function HandleReplicatedValue(onreplicated, onglobal)
        if isfunction(CRVersion) and CRVersion("1.9.3") then return onreplicated() end

        return onglobal()
    end

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
            -- CR Replicated convar
            local special_detective_mode = HandleReplicatedValue(function() return GetConVar("ttt_detectives_hide_special_mode"):GetInt() end, function() return GetGlobalInt("ttt_detective_hide_special_mode", SPECIAL_DETECTIVE_HIDE_NONE) end)

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