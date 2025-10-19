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

local function RenderZen( self )
    render.SetBlend( 1 )

    if self == LocalPlayer() then
        self:DrawModel()
        return
    end

    if ( IsOwnerZen( self ) or LocalPlayer():GetNWBool( "ZenMode" ) ) and CPPIGetTopOwner( self ) ~= LocalPlayer() and not self:IsWeapon() then
        render.SetBlend( 0.25 )
    end

    if ( LocalPlayer():GetNWBool( "ZenMode" ) or self:GetNWBool( "ZenMode" ) ) and CPPIGetTopOwner( self ) ~= LocalPlayer() and not self:IsWeapon() then
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
            if IsValid( v ) then
                v.oldRenderOverride = v.RenderOverride
                v.RenderOverride = RenderZen
            end
        end
    else
        for _, v in ents.Iterator() do
            if IsValid( v ) then
                v.RenderOverride = v.oldRenderOverride
            end
        end
    end
end )

hook.Add( "OnEntityCreated", "ZenMode_SyncClient", function( ent )
    if IsValid( ent ) and ( IsOwnerZen( ent ) or LocalPlayer():GetNWBool( "ZenMode" ) ) then
        ent.oldRenderOverride = ent.RenderOverride
        ent.RenderOverride = RenderZen
    end
end )