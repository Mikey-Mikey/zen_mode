util.AddNetworkString( "SetZenMode" )

local ply_meta = FindMetaTable( "Player" )

function ply_meta:SetZenMode( b )

    self:SetNWBool( "ZenMode", b )
    net.Start( "SetZenMode" )
    net.WriteBool( b )
    net.Broadcast()
end

local function CPPIGetTopOwner( ent )
    if not IsValid( ent ) then return end

    local topParent = ent

    while IsValid( topParent:GetParent() ) do
        topParent = topParent:GetParent()
    end

    return topParent:CPPIGetOwner()
end

local function IsOwnerZen( ent )
    local owner = ent:CPPIGetOwner() or CPPIGetTopOwner( ent )
    return IsValid( owner ) and owner:GetZenMode()
end

hook.Add( "PlayerInitialSpawn", "InitZenMode", function( ply )
    ply:SetZenMode( false )
    ply:SetCustomCollisionCheck( true )
    ply:CollisionRulesChanged()
end )

--- !zen chat command
hook.Add( "PlayerSay", "ZenModeCommands", function( ply, text )
    if string.lower( text ) == "!zen" then
        ply:SetZenMode( not ply:GetZenMode() )

        if ply:GetZenMode() then
            ply:ChatPrint( "[ZEN] You are now in Zen Mode." )
        else
            ply:ChatPrint( "[ZEN] You have left Zen Mode." )
        end
        return ''
    end
end )

hook.Add( "InitPostEntity", "ZenMode_InitEnts", function()
    for _, v in ents.Iterator() do
        v:SetCustomCollisionCheck( true )
        v:CollisionRulesChanged()
    end
end )

hook.Add( "OnEntityCreated", "ZenMode_OnEntCreate", function( ent )
    ent:SetCustomCollisionCheck( true )
    ent:CollisionRulesChanged()
end )

--- Handle damage
hook.Add( "EntityTakeDamage", "ZenMode_DamageHandler", function( ent, dmginfo )
    local attacker = dmginfo:GetAttacker()

    -- Player vs Entity
    if IsValid( attacker ) and IsOwnerZen( ent ) and attacker ~= CPPIGetTopOwner( ent ) then
        return true
    end

    -- Player vs Player #1
    if IsValid( attacker ) and ent:IsPlayer() and ent:GetZenMode() and attacker ~= ent then
        return true
    end

    -- Player vs Player #2
    if IsValid( attacker ) and attacker:IsPlayer() and attacker:GetZenMode() and attacker ~= ent then
        return true
    end

end )

hook.Add( "GravGunPickupAllowed", "ZenMode_GravGunPickup", function( ply, ent )
    if IsValid( CPPIGetTopOwner( ent ) ) and CPPIGetTopOwner( ent ):GetZenMode() and ply ~= CPPIGetTopOwner( ent ) then
        return false
    end

    if ply:GetZenMode() and ply ~= CPPIGetTopOwner( ent ) then
        return false
    end
end )

hook.Add( "AllowPlayerPickup", "ZenMode_PlayerUse", function( ply, ent )
    if IsOwnerZen( ent ) and ply ~= CPPIGetTopOwner( ent ) then
        return false
    end
end )