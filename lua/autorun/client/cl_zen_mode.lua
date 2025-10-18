local function IsOwnerZen( ent )
    return IsValid( ent:CPPIGetOwner() ) and ent:CPPIGetOwner():GetNWBool( "ZenMode" )
end

local function RenderZen( self )
    render.SetBlend( 1 )

    if ( IsOwnerZen( self ) or LocalPlayer():GetNWBool( "ZenMode" ) ) and self:CPPIGetOwner() ~= LocalPlayer() and not self:IsWeapon() then
        render.SetBlend( 0.25 )
    end

    if ( LocalPlayer():GetNWBool( "ZenMode" ) or self:GetNWBool( "ZenMode" ) ) and self:CPPIGetOwner() ~= LocalPlayer() and not self:IsWeapon() then
        render.SetBlend( 0.25 )
    end

    if self:IsWeapon() and ( self:GetOwner():GetNWBool( "ZenMode" ) or LocalPlayer():GetNWBool( "ZenMode" )  ) and self:GetOwner() ~= LocalPlayer() then
        render.SetBlend( 0.25 )
    end



    self:DrawModel()
end

net.Receive( "SetZenMode", function()
    local state = net.ReadBool()

    if state then
        for _, v in ents.Iterator() do
            v.oldRenderOverride = v.RenderOverride
            v.RenderOverride = RenderZen
        end
    else
        for _, v in ents.Iterator() do
            v.RenderOverride = v.oldRenderOverride
        end
    end
end )

hook.Add( "OnEntityCreated", "ZenMode_SyncClient", function( ent )
    if IsOwnerZen( ent ) or LocalPlayer():GetNWBool( "ZenMode" ) then
        ent.oldRenderOverride = ent.RenderOverride
        ent.RenderOverride = RenderZen
    end
end )