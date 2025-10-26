local ply_meta = FindMetaTable( "Player" )

function ply_meta:GetZenMode()
    return self:GetNWBool( "ZenMode" )
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

hook.Add( "ShouldCollide", "ZenMode_ResolveCollisions", function( ent1, ent2 )
    -- Entity vs Entity collision
    if IsValid( CPPIGetTopOwner( ent1 ) ) and IsValid( CPPIGetTopOwner( ent2 ) ) and CPPIGetTopOwner( ent2 ) ~= CPPIGetTopOwner( ent1 ) and ( CPPIGetTopOwner( ent1 ):GetZenMode() or CPPIGetTopOwner( ent2 ):GetZenMode() ) then
        return false
    end

    -- Player vs Player collision
    if ent1:IsPlayer() and ent2:IsPlayer() and ( ent1:GetZenMode() or ent2:GetZenMode() ) then
        return false
    end

    -- Player vs Entity collision
    if ent1:IsPlayer() and not ent2:IsPlayer() and ( ent1:GetZenMode() or IsOwnerZen( ent2 ) ) then
        return false
    end

    -- Entity vs Player collision
    if ent2:IsPlayer() and not ent1:IsPlayer() and ( ent2:GetZenMode() or IsOwnerZen( ent1 ) ) then
        return false
    end
end )

hook.Add( "GravGunPunt", "ZenMode_GravGunPunt", function( ply, ent )
    if IsValid( CPPIGetTopOwner( ent ) ) and CPPIGetTopOwner( ent ):GetZenMode() and ply ~= CPPIGetTopOwner( ent ) then
        return false
    end

    if ply:GetZenMode() and ply ~= CPPIGetTopOwner( ent ) then
        return false
    end
end )

hook.Add( "CanTool", "ZenMode_CanTool", function( ply, tr )
    if not IsValid( tr.Entity ) then return end
    local ent = tr.Entity

    if IsOwnerZen( ent ) and ply ~= CPPIGetTopOwner( ent ) then
        return false
    end

    if ply:GetZenMode() and ply ~= CPPIGetTopOwner( ent ) then
        return false
    end
end )