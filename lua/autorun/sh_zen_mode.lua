local function IsOwnerZen( ent )
    return IsValid( ent:CPPIGetOwner() ) and ent:CPPIGetOwner():GetNWBool( "ZenMode" )
end

hook.Add( "ShouldCollide", "ZenMode_ResolveCollisions", function( ent1, ent2 )
    -- Entity vs Entity collision
    if IsValid( ent1:CPPIGetOwner() ) and IsValid( ent2:CPPIGetOwner() ) and ent2:CPPIGetOwner() ~= ent1:CPPIGetOwner() and ( ent1:CPPIGetOwner():GetNWBool( "ZenMode" ) or ent2:CPPIGetOwner():GetNWBool( "ZenMode" ) ) then
        return false
    end

    -- Player vs player collision
    if ent1:IsPlayer() and ent2:IsPlayer() and ( ent1:GetNWBool( "ZenMode" ) or ent2:GetNWBool( "ZenMode" ) ) then
        return false
    end

    -- Player vs Entity collision
    if ent1:IsPlayer() ~= ent2:IsPlayer() and ( ent1:GetNWBool( "ZenMode" ) or ent2:GetNWBool( "ZenMode" ) or IsOwnerZen( ent1 ) or IsOwnerZen( ent2 ) ) and ent1:CPPIGetOwner() ~= ent2 and ent1 ~= ent2:CPPIGetOwner() then
        return false
    end
end )

hook.Add( "GravGunPunt", "ZenMode_GravGunPunt", function( ply, ent )
    if IsValid( ent:CPPIGetOwner() ) and ent:CPPIGetOwner():GetNWBool( "ZenMode" ) and ply ~= ent:CPPIGetOwner() then
        return false
    end

    if ply:GetNWBool( "ZenMode" ) and ply ~= ent:CPPIGetOwner() then
        return false
    end
end )

hook.Add( "CanTool", "ZenMode_CanTool", function( ply, tr )
    if not IsValid( tr.Entity ) then return end
    local ent = tr.Entity

    if IsOwnerZen( ent ) and ply ~= ent:CPPIGetOwner() then
        return false
    end

    if ply:GetNWBool( "ZenMode" ) and ply ~= ent:CPPIGetOwner() then
        return false
    end
end )

local ply_meta = FindMetaTable( "Player" )

function ply_meta:GetZenMode()
    return self:GetNWBool( "ZenMode" )
end