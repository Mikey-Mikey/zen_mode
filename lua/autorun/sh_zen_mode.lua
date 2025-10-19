local function CPPIGetTopOwner( ent )
    local topParent = ent
    while true do
        local parent = topParent:GetParent()
        if not IsValid( parent ) then break end
        topParent = parent
    end
    return topParent:CPPIGetOwner()
end

local function IsOwnerZen( ent )
    return IsValid( CPPIGetTopOwner( ent ) ) and CPPIGetTopOwner( ent ):GetNWBool( "ZenMode" )
end

hook.Add( "ShouldCollide", "ZenMode_ResolveCollisions", function( ent1, ent2 )
    -- Entity vs Entity collision
    if IsValid( CPPIGetTopOwner( ent1 ) ) and IsValid( CPPIGetTopOwner( ent2 ) ) and CPPIGetTopOwner( ent2 ) ~= CPPIGetTopOwner( ent1 ) and ( CPPIGetTopOwner( ent1 ):GetNWBool( "ZenMode" ) or CPPIGetTopOwner( ent2 ):GetNWBool( "ZenMode" ) ) then
        return false
    end

    -- Player vs Player collision
    if ent1:IsPlayer() and ent2:IsPlayer() and ( ent1:GetNWBool( "ZenMode" ) or ent2:GetNWBool( "ZenMode" ) ) then
        return false
    end

    -- Player vs Entity collision
    if ent1:IsPlayer() ~= ent2:IsPlayer() and ( ent1:GetNWBool( "ZenMode" ) or ent2:GetNWBool( "ZenMode" ) or IsOwnerZen( ent1 ) or IsOwnerZen( ent2 ) ) and CPPIGetTopOwner( ent1 ) ~= ent2 and ent1 ~= CPPIGetTopOwner( ent2 ) then
        return false
    end
end )

hook.Add( "GravGunPunt", "ZenMode_GravGunPunt", function( ply, ent )
    if IsValid( CPPIGetTopOwner( ent ) ) and CPPIGetTopOwner( ent ):GetNWBool( "ZenMode" ) and ply ~= CPPIGetTopOwner( ent ) then
        return false
    end

    if ply:GetNWBool( "ZenMode" ) and ply ~= CPPIGetTopOwner( ent ) then
        return false
    end
end )

hook.Add( "CanTool", "ZenMode_CanTool", function( ply, tr )
    if not IsValid( tr.Entity ) then return end
    local ent = tr.Entity

    if IsOwnerZen( ent ) and ply ~= CPPIGetTopOwner( ent ) then
        return false
    end

    if ply:GetNWBool( "ZenMode" ) and ply ~= CPPIGetTopOwner( ent ) then
        return false
    end
end )

local ply_meta = FindMetaTable( "Player" )

function ply_meta:GetZenMode()
    return self:GetNWBool( "ZenMode" )
end