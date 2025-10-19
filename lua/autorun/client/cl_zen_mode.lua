local cl_zenmode_opacity = CreateClientConVar( "cl_zenmode_renderopacity", 0.15, true, false, "opacity of zen mode entities", 0, 1 )

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
        render.SetBlend( cl_zenmode_opacity:GetFloat() )
    end

    if ( LocalPlayer():GetNWBool( "ZenMode" ) or self:GetNWBool( "ZenMode" ) ) and CPPIGetTopOwner( self ) ~= LocalPlayer() and not self:IsWeapon() then
        render.SetBlend( cl_zenmode_opacity:GetFloat() )
    end

    if self:IsWeapon() and ( self:GetOwner():GetNWBool( "ZenMode" ) or LocalPlayer():GetNWBool( "ZenMode" )  ) and self:GetOwner() ~= LocalPlayer() then
        render.SetBlend( cl_zenmode_opacity:GetFloat() )
    end
    if IsValid( self.oldRenderOverride ) then
        self.oldRenderOverride()
    else
        self:DrawModel()
    end
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