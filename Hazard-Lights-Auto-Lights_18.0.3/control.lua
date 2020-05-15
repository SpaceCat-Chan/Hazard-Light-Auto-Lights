pcall(require,'__debugadapter__/debugadapter.lua')

function DebugPrint(thing)
	if not __DebugAdapter then return end
	pcall(__DebugAdapter.print, thing)
end

function OnLoad()
	DebugPrint("test")
	local Prototypes = game.entity_prototypes
	local PlayerCollisionMask = Prototypes["character"].collision_mask

	local CommonEntities = remote.call("Hazard-Lights", "GetCommonEntities")
	local NameList = {}
	local Index=1
	for Name,_ in pairs(CommonEntities) do
		NameList[Index] = Name
		Index = Index + 1
	end
	remote.call("Hazard-Lights", "RemoveEntities", NameList)
	local MinWidth, MinHeigth = settings.global["HazardLightsAuto-Width"].value, settings.global["HazardLightsAuto-Heigth"].value
	for k,v in pairs(Prototypes) do repeat
		if v.name == "character" then break end
		local Skip=true
		for Mask,_ in pairs(PlayerCollisionMask) do
			if v.collision_mask and v.collision_mask[Mask] then
				Skip = false
				break
			end
		end
		if v.speed or v.weight or v.attack_parameters then
			DebugPrint("Moves: "..k)
			break
		end
		if Skip then DebugPrint("Doesnt interact with player: "..k) break end
		if v.items_to_place_this == nil then DebugPrint("No Items For: "..k) break end
		local Width, Heigth
		Width, Heigth =  v.collision_box.right_bottom.x - v.collision_box.left_top.x, v.collision_box.right_bottom.y - v.collision_box.left_top.y
		if Width and Heigth and Width >= MinWidth and Heigth >= MinHeigth then
			remote.call("Hazard-Lights", "AddEntities", {v.name}, true)
		else
			DebugPrint("Not Big Enough: "..k)
		end
	until true end
	remote.call("Hazard-Lights", "RedoRendering")
end

function SettingChange(event)
	if event.setting == "HazardLightsAuto-Width" or event.setting == "HazardLightsAuto-Heigth" then
		OnLoad()
	end
end

script.on_init(OnLoad)
script.on_event(defines.events.on_runtime_mod_setting_changed, SettingChange)