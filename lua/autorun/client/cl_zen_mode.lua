local cl_zenmode_opacity = CreateClientConVar( "cl_zenmode_renderopacity", 0.15, true, false, "opacity of zen mode entities", 0, 1 )

local function CPPIGetTopOwner( ent )
    if not IsValid( ent ) then return end
    local topParent = ent
    while true do
        local parent = topParent:GetParent()
        if not IsValid( parent ) then break end
        topParent = parent
    end
    return topParent:CPPIGetOwner()
end

local function IsOwnerZen( ent )
    local owner = CPPIGetTopOwner( ent )
    return IsValid( owner ) and owner:GetNWBool( "ZenMode" )
end

local function RenderZen( ent )
    if not IsValid( ent ) then return end
    render.SetBlend( 1 )

    if ent == LocalPlayer() then
        if ent.oldRenderOverride ~= nil then
            ent.oldRenderOverride()
        else
            ent:DrawModel()
        end
        return
    end

    if ( IsOwnerZen( ent ) or LocalPlayer():GetNWBool( "ZenMode" ) ) and CPPIGetTopOwner( ent ) ~= LocalPlayer() and not ent:IsWeapon() then
        render.SetBlend( cl_zenmode_opacity:GetFloat() )
    end

    if ( LocalPlayer():GetNWBool( "ZenMode" ) or ent:GetNWBool( "ZenMode" ) ) and CPPIGetTopOwner( ent ) ~= LocalPlayer() and not ent:IsWeapon() then
        render.SetBlend( cl_zenmode_opacity:GetFloat() )
    end

    if ent:IsWeapon() and ( ent:GetOwner():GetNWBool( "ZenMode" ) or LocalPlayer():GetNWBool( "ZenMode" )  ) and ent:GetOwner() ~= LocalPlayer() then
        render.SetBlend( cl_zenmode_opacity:GetFloat() )
    end
    if ent.oldRenderOverride ~= nil then
        ent.oldRenderOverride()
    else
        ent:DrawModel()
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
hook.Add( "InitPostEntity", "ZenMode_WaitForClient", function()
    hook.Add( "OnEntityCreated", "ZenMode_SyncClient", function( ent )
        if IsValid( ent ) and ( IsOwnerZen( ent ) or LocalPlayer():GetNWBool( "ZenMode" ) ) then
            ent.oldRenderOverride = ent.RenderOverride
            ent.RenderOverride = RenderZen
        end
    end )
end )