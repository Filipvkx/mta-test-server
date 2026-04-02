addEventHandler("onClientResourceStart", resourceRoot, function()
    for i = 0, 143 do
        local texName = string.format("radar%02d", i)
        
        local texturePath = string.format("radar/radar%02d_radar%02d.png", i, i)
        
        if fileExists(texturePath) then
            local texture = dxCreateTexture(texturePath, "dxt3", true, "clamp")
            if texture then
                local shader = dxCreateShader("radar/replace.fx")
                if shader then
                    dxSetShaderValue(shader, "gTexture", texture)
                    engineApplyShaderToWorldTexture(shader, texName)
                end
            end
        end
    end
end)