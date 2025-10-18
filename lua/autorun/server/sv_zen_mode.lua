util.AddNetworkString( "SetZenMode" )

local function IsOwnerZen( ent )
    return IsValid( ent:CPPIGetOwner() ) and ent:CPPIGetOwner():GetNWBool( "ZenMode" )
end

hook.Add( "PlayerInitialSpawn", "InitZenMode", function( ply )
    ply:SetNWBool( "ZenMode", false )
    ply:SetCustomCollisionCheck( true )
    ply:CollisionRulesChanged()
end )

local ply_meta = FindMetaTable( "Player" )

function ply_meta:SetZenMode( b )

    self:SetNWBool( "ZenMode", b )
    net.Start( "SetZenMode" )
    net.WriteBool( b )
    net.Broadcast()
end

--- !zen chat command
hook.Add( "PlayerSay", "ZenModeCommands", function( ply, text )
    if string.lower( text ) == "!zen" then
        ply:SetZenMode( not ply:GetZenMode() )

        if ply:GetZenMode() then
            ply:ChatPrint( "[ZEN] You are now in Zen Mode." )
        else
            ply:ChatPrint( "[ZEN] You have left Zen Mode." )
        end

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

    if IsValid( attacker ) and IsOwnerZen( ent ) and attacker ~= ent:CPPIGetOwner() then
        return true
    end

    if ent:GetNWBool( "ZenMode" ) and attacker ~= ent then
        return true
    end

    if IsValid( attacker ) and attacker:GetNWBool( "ZenMode" ) and ent:IsPlayer() and attacker ~= ent then
        return true
    end

end )

hook.Add( "GravGunPickupAllowed", "ZenMode_GravGunPickup", function( ply, ent )
    if IsValid( ent:CPPIGetOwner() ) and ent:CPPIGetOwner():GetNWBool( "ZenMode" ) and ply ~= ent:CPPIGetOwner() then
        return false
    end

    if ply:GetNWBool( "ZenMode" ) and ply ~= ent:CPPIGetOwner() then
        return false
    end
end )

hook.Add( "AllowPlayerPickup", "ZenMode_PlayerUse", function( ply, ent )
    if IsOwnerZen( ent ) and ply ~= ent:CPPIGetOwner() then
        return false
    end
end )