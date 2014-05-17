
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
if targetPlatform == cc.PLATFORM_OS_WINDOWS then
    SFX_DIE = "sfx_die.wav"
    SFX_HIT = "sfx_hit.wav"
    SFX_POINT = "sfx_point.wav"
    SFX_SWOOSHING = "sfx_swooshing.wav"
    SFX_WING = "sfx_wing.wav"
else
    SFX_DIE = "sfx_die.ogg"
    SFX_HIT = "sfx_hit.ogg"
    SFX_POINT = "sfx_point.ogg"
    SFX_SWOOSHING = "sfx_swooshing.ogg"
    SFX_WING = "sfx_wing.ogg"
end




