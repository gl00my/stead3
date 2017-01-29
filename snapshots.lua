local std = stead
local type = std.type

local SNAPSHOT = false

local snap = std.obj {
	nam = '@snaphots';
	data = {};
	make = function(s, name)
		name = name or 'default'
		local fp = { -- fake file object
			data = '';
			write = function(s, str)
				s.data = s.data .. str
			end;
		}
		std:save(fp)
		s.data[name] = fp.data
	end;
	exist = function(s, name)
		name = name or 'default'
		return s.data[name]
	end;
	remove = function(s, name)
		name = name or 'default'
		s.data[name] = nil
	end;
	restore = function(s, name) -- like std:load()
		name = name or 'default'
		if not s:exist(name) then
			return false
		end
		std:reset()
		std.ref 'game':ini(true)

		local f, err = std.eval(s.data[name])
		if not f then
			std.err(err, 2)
		end
		f();
		std.ref 'game':ini()
		std:abort()
		if std.cctx() then
			std.pr(std.game:lastdisp())
		end
		return std.game:lastdisp(), false
	end;
}

snapshots = snap

std.mod_cmd(function()
	if SNAPSHOT then
		snap:make(snap.SNAPSHOT)
		SNAPSHOT = nil
	end
end)
