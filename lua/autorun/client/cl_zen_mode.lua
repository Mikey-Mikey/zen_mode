local cl_zenmode_opacity = CreateClientConVar( "cl_zenmode_renderopacity", 0.15, true, false, "opacity of zen mode entities", 0, 1 )

local function CPPIGetTopOwner( ent )
    if not IsValid( ent ) then return end

    if IsValid( ent:CPPIGetOwner() ) then
        return ent:CPPIGetOwner()
    end

    local topParent = ent

    while IsValid( topParent:GetParent() ) do
        topParent = topParent:GetParent()
    end

    return topParent:CPPIGetOwner()
end

local function IsOwnerZen( ent )
    local owner = CPPIGetTopOwner( ent )
    return IsValid( owner ) and owner:GetZenMode()
end

local function RenderZen( ent )
    if not IsValid( ent ) then return end

    render.SetBlend( 1 )

    if ent == LocalPlayer() then
        ent:DrawModel()
        return
    end

    if ent:IsWeapon() then -- Weapon rendering
        if ( ent:GetOwner():GetZenMode() or LocalPlayer():GetZenMode()  ) and ent:GetOwner() ~= LocalPlayer() then
            render.SetBlend( cl_zenmode_opacity:GetFloat() )
        end
    else
        -- Entity rendering
        if not ent:IsPlayer() and ( IsOwnerZen( ent ) or LocalPlayer():GetZenMode() ) and CPPIGetTopOwner( ent ) ~= LocalPlayer() then
            render.SetBlend( cl_zenmode_opacity:GetFloat() )
        end

        -- Player Rendering
        if ent:IsPlayer() and ( LocalPlayer():GetZenMode() or ent:GetZenMode() ) then
            render.SetBlend( cl_zenmode_opacity:GetFloat() )
        end
    end

    ent:DrawModel()
end

net.Receive( "SetZenMode", function()
    local state = net.ReadBool()

    if state then
        for _, v in ents.Iterator() do
            if IsValid( v ) then
                v.oldRenderOverride = v.oldRenderOverride or v.RenderOverride
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
        timer.Simple( 0, function()
            if IsValid( ent ) and ( IsOwnerZen( ent ) or LocalPlayer():GetZenMode() ) then
                ent.oldRenderOverride = ent.oldRenderOverride or ent.RenderOverride
                ent.RenderOverride = RenderZen
            end
        end )
    end )
end )