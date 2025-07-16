

local assets =
{
	Asset( "ANIM", "anim/lykio.zip" ),
	Asset( "ANIM", "anim/ghost_lykio_build.zip" ),
}

local skins =
{
	normal_skin = "lykio",
	ghost_skin = "ghost_lykio_build",
}

return CreatePrefabSkin("lykio_none",
{
	base_prefab = "lykio",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"lykio", "CHARACTER", "BASE"},
	build_name_override = "lykio",
	rarity = "Character",
})