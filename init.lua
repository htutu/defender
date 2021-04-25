-- license:BSD-3-Clause
-- copyright-holders:tutu
local exports = {}
exports.name = "defender"
exports.version = "0.0.1"
exports.description = "tutu defender control plugin"
exports.license = "The BSD 3-Clause License"
exports.author = { name = "tutu" }

local defender = exports

function defender.startplugin()
	local screen
	local space
	local input
	local ioport
	local rom = {}
	local seq_left
	local seq_right
	local DIRECTION_ADDRESS = {
		defender = 0xa0bb
		,stargate = 0x9c92
	}
	local DIRECTION_LEFT  = 0xfd
	local DIRECTION_RIGHT = 0x03

	emu.register_start(function ()
		screen = manager.machine.screens[":screen"]
		input = manager.machine.input
		ioport = manager.machine.ioport
		seq_left  = input:seq_from_tokens("JOYCODE_1_XAXIS_LEFT_SWITCH")
		seq_right = input:seq_from_tokens("JOYCODE_1_XAXIS_RIGHT_SWITCH")
	
		rom.name = emu.romname()
	end)

	emu.register_frame_done(function ()
		if screen == nil then
			return
		end

		if DIRECTION_ADDRESS[rom.name] then
			local input_left  = input:seq_pressed(seq_left)
			local input_right = input:seq_pressed(seq_right)

			space = manager.machine.devices[":maincpu"].spaces["program"]
			local direction = space:read_u8(DIRECTION_ADDRESS[rom.name])

			local reverse = (input_left and direction == DIRECTION_RIGHT) or (input_right and direction == DIRECTION_LEFT)
			local thrust  = (input_left and direction == DIRECTION_LEFT)  or (input_right and direction == DIRECTION_RIGHT)

			ioport.ports[":IN0"].fields["Reverse"]:set_value(reverse and 1 or 0)
			ioport.ports[":IN0"].fields["Thrust"]:set_value(thrust and 1 or 0)
		end
	end)

	emu.register_stop(function ()
		rom = {}
	end)
end

return exports
