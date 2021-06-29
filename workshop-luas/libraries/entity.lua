-- dependencies
local ffi = require 'ffi'
local csgo_weapons = require 'gamesense/csgo_weapons'

-- caching common functions
local entity_get_local_player, entity_is_enemy, entity_get_bounding_box, entity_get_all, entity_set_prop, entity_is_alive, entity_get_steam64, entity_get_classname, entity_get_player_resource, entity_get_esp_data, entity_is_dormant, entity_get_player_name, entity_get_game_rules, entity_get_origin, entity_hitbox_position, entity_get_player_weapon, entity_get_players, entity_get_prop = entity.get_local_player, entity.is_enemy, entity.get_bounding_box, entity.get_all, entity.set_prop, entity.is_alive, entity.get_steam64, entity.get_classname, entity.get_player_resource, entity.get_esp_data, entity.is_dormant, entity.get_player_name, entity.get_game_rules, entity.get_origin, entity.hitbox_position, entity.get_player_weapon, entity.get_players, entity.get_prop
local client_userid_to_entindex, client_draw_hitboxes, client_scale_damage, client_trace_line, client_trace_bullet = client.userid_to_entindex, client.draw_hitboxes, client.scale_damage, client.trace_line, client.trace_bullet
local materialsystem_get_model_materials = materialsystem.get_model_materials
local plist_set, plist_get = plist.set, plist.get
local ffi_cast = ffi.cast

-- ffi typedefs, structs & functions
local animation_layer_t = ffi.typeof([[
	struct {										char pad0[0x18];
		uint32_t	sequence;
		float		prev_cycle;
		float		weight;
		float		weight_delta_rate;
		float		playback_rate;
		float		cycle;
		void		*entity;						char pad1[0x4];
	} **
]])

local animation_state_t = ffi.typeof([[
	struct {										char pad0[0x18];
		float		anim_update_timer;				char pad1[0xC];
		float		started_moving_time;
		float		last_move_time;					char pad2[0x10];
		float		last_lby_time;					char pad3[0x8];
		float		run_amount;						char pad4[0x10];
		void*		entity;
		void*		active_weapon;
		void*		last_active_weapon;
		float		last_client_side_animation_update_time;
		int			last_client_side_animation_update_framecount;
		float		eye_timer;
		float		eye_angles_y;
		float		eye_angles_x;
		float		goal_feet_yaw;
		float		current_feet_yaw;
		float		torso_yaw;
		float		last_move_yaw;
		float		lean_amount;					char pad5[0x4];
		float		feet_cycle;
		float		feet_yaw_rate;					char pad6[0x4];
		float		duck_amount;
		float		landing_duck_amount;			char pad7[0x4];
		float		current_origin[3];
		float		last_origin[3];
		float		velocity_x;
		float		velocity_y;						char pad8[0x4];
		float		unknown_float1;					char pad9[0x8];
		float		unknown_float2;
		float		unknown_float3;
		float		unknown;
		float		m_velocity;
		float		jump_fall_velocity;
		float		clamped_velocity;
		float		feet_speed_forwards_or_sideways;
		float		feet_speed_unknown_forwards_or_sideways;
		float		last_time_started_moving;
		float		last_time_stopped_moving;
		bool		on_ground;
		bool		hit_in_ground_animation;		char pad10[0x4];
		float		time_since_in_air;
		float		last_origin_z;
		float		head_from_ground_distance_standing;
		float		stop_to_full_running_fraction;	char pad11[0x4];
		float		magic_fraction;					char pad12[0x3C];
		float		world_force;					char pad13[0x1CA];
		float		min_yaw;
		float		max_yaw;
	} **
]])


local native_GetClientNetworkable = vtable_bind('client.dll', 'VClientEntityList003', 0, 'void*(__thiscall*)(void*, int)')
local native_GetClientEntity = vtable_bind('client.dll', 'VClientEntityList003', 3, 'void*(__thiscall*)(void*, int)')
local native_GetStudioModel = vtable_bind('engine.dll', 'VModelInfoClient004', 32, 'void*(__thiscall*)(void*, const void*)')

local native_GetIClientUnknown = vtable_thunk(0, 'void*(__thiscall*)(void*)')
local native_GetClientRenderable = vtable_thunk(5, 'void*(__thiscall*)(void*)')
local native_GetBaseEntity = vtable_thunk(7, 'void*(__thiscall*)(void*)')
local native_GetModel = vtable_thunk(8, 'const void*(__thiscall*)(void*)')

local native_GetSequenceActivity_sig = client.find_signature('client.dll','\x55\x8B\xEC\x53\x8B\x5D\x08\x56\x8B\xF1\x83') or error('invalid GetSequenceActivity signature')
local native_GetSequenceActivity = ffi.cast('int(__fastcall*)(void*, void*, int)', native_GetSequenceActivity_sig)

local class_ptr = ffi.typeof('void***')
local char_ptr = ffi.typeof('char*')
local nullptr = ffi.new('void*')

local entity = {}

local M = {
	__index = entity,
	__tostring = function(self)
		return ('%d'):format(self[0])
	end,
	__concat = function(a, b)
		return ('%s%s'):format(a, b)
	end,
	__eq = function(a, b)
		return a[0] == b[0]
	end,
	__metatable = false
}

-- functions
local function entity_new(entindex)
	return entindex and setmetatable(
		{
			[0] = entindex
		},
		M
	)
end

local function get_model(this)
	local pNet = ffi_cast(class_ptr, native_GetClientNetworkable(this[0]))
	if pNet == nullptr then
		return
	end

	local pUnk = ffi_cast(class_ptr, native_GetIClientUnknown(pNet))
	if pUnk == nullptr then
		return
	end

	local pRen = ffi_cast(class_ptr, native_GetClientRenderable(pUnk))
	if pRen == nullptr then
		return
	end

	return native_GetModel(pRen)
end

entity.new = entity_new

entity.new_from_userid = function(userid)
	return entity_new(client_userid_to_entindex(userid))
end

entity.get_local_player = function()
	return entity_new(entity_get_local_player())
end

entity.get_player_resource = function()
	return entity_new(entity_get_player_resource())
end

entity.get_game_rules = function()
	return entity_new(entity_get_game_rules())
end

entity.get_all = function(...)
	local ents = entity_get_all(...)
	for i, entindex in ipairs(ents) do
		ents[i] = entity_new(entindex)
	end
	return ents
end

entity.get_players = function(...)
	local ents = entity_get_players(...)
	for i, entindex in ipairs(ents) do
		ents[i] = entity_new(entindex)
	end
	return ents
end

entity.get_entindex = function(self)
	return self[0]
end

entity.get_player_weapon = function(self)
	return entity_new(entity_get_player_weapon(self[0]))
end

entity.is_enemy = function(self)
	return entity_is_enemy(self[0])
end

entity.get_bounding_box = function(self)
	return entity_get_bounding_box(self[0])
end

entity.set_prop = function(self, ...)
	return entity_set_prop(self[0], ...)
end

entity.is_alive = function(self)
	return entity_is_alive(self[0])
end

entity.get_steam64 = function(self)
	return entity_get_steam64(self[0])
end

entity.get_classname = function(self)
	return entity_get_classname(self[0])
end

entity.get_esp_data = function(self)
	return entity_get_esp_data(self[0])
end

entity.is_dormant = function(self)
	return entity_is_dormant(self[0])
end

entity.get_player_name = function(self)
	return entity_get_player_name(self[0])
end

entity.get_origin = function(self)
	return entity_get_origin(self[0])
end

entity.hitbox_position = function(self, ...)
	return entity_hitbox_position(self[0], ...)
end

entity.get_prop = function(self, ...)
	return entity_get_prop(self[0], ...)
end

entity.draw_hitboxes = function(self, ...)
	return client_draw_hitboxes(self[0], ...)
end

entity.scale_damage = function(self, ...)
	return client_scale_damage(self[0], ...)
end

entity.trace_line = function(self, ...)
	local fraction, entindex = client_trace_line(self[0], ...)

	return fraction, entity_new(entindex)
end

entity.trace_bullet = function(self, ...)
	local entindex, damage = client_trace_bullet(self[0], ...)

	return entity_new(entindex), damage
end

entity.get_model_materials = function(self)
	return materialsystem_get_model_materials(self[0])
end

entity.plist_set = function(self, ...)
	return plist_set(self[0], ...)
end

entity.plist_get = function(self, ...)
	return plist_get(self[0], ...)
end

entity.get_client_networkable = function(self)
	return native_GetClientNetworkable(self[0])
end

entity.get_client_entity = function(self)
	return native_GetClientEntity(self[0])
end

entity.get_client_unknown = function(self)
	local pNet = ffi_cast(class_ptr, native_GetClientNetworkable(self[0]))
	if pNet == nullptr then
		return
	end
	
	return native_GetIClientUnknown(pNet)
end

entity.get_client_renderable = function(self)
	local pNet = ffi_cast(class_ptr, native_GetClientNetworkable(self[0]))
	if pNet == nullptr then
		return
	end
	
	local pUnk = ffi_cast(class_ptr, native_GetIClientUnknown(pNet))
	if pUnk == nullptr then
		return
	end
	
	return native_GetClientRenderable(pUnk)
end

entity.get_base_entity = function(self)
	local pNet = ffi_cast(class_ptr, native_GetClientNetworkable(self[0]))
	if pNet == nullptr then
		return
	end

	local pUnk = ffi_cast(class_ptr, native_GetIClientUnknown(pNet))
	if pUnk == nullptr then
		return
	end
	
	return native_GetBaseEntity(pUnk)
end

entity.get_sequence_activity = function(self, sequence)
	local hdr = native_GetStudioModel(get_model(self))

	if not hdr then
		return -1
	end

	return native_GetSequenceActivity(native_GetClientEntity(self[0]), hdr, sequence)
end

entity.get_anim_overlay = function(self, layer) -- (*(animation_layer_t)((char*)ent_ptr + 0x2980))[layer]
	layer = layer or 1

	local pEnt = ffi_cast(class_ptr, native_GetClientEntity(self[0]))
	if pEnt == nullptr then
		return
	end

	return ffi_cast(animation_layer_t, ffi_cast(char_ptr, pEnt) + 0x2980)[0][layer] 
end

entity.get_anim_state = function(self) -- (*(animation_state_t)((char*)ent_ptr + 0x3914))
	local pEnt = ffi_cast(class_ptr, native_GetClientEntity(self[0]))
	if pEnt == nullptr then
		return
	end

	return ffi_cast(animation_state_t, ffi_cast(char_ptr, pEnt) + 0x3914)[0]
end

entity.get_weapon_info = function(self)
	local idx = entity_get_prop(self[0], 'm_iItemDefinitionIndex')
	
	return csgo_weapons[idx]
end

setmetatable(
	entity,
	{
		__call = function(self, entindex)
			return entindex and setmetatable(
				{
					[0] = entindex
				},
				M
			)
		end,
		__metatable = false
	}
)

return entity