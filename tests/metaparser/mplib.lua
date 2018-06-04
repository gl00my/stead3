--[[attributes from Inform 6
absent. The object is currently not at its usual location(s).
animate. The object is some sort of creature or person.
clothing. The player character can wear this object; it's clothing.
concealed. The object is here but can't be seen.
container. This object can have other objects inside it.
door. The object is a door.
edible. The object is edible; it's food.
enterable. The PC can be located inside or on top of this object.
female. The object is female, or has the female gender.
general. No predefined meaning. The author may mark an object as "general" for any reason.
light. The object provides light; it is lit.
lockable. The object can be locked and unlocked.
locked. The object is locked.
male. The object is male, or has the male gender.
moved. The object has been moved from its original location.
neuter. The object has the neuter gender.
on. The object is turned on; it is activated.
open. The object is open.
openable. The object can be opened and closed.
pluralname. The object has a plural name, such as "clouds".
proper. The object has a proper name, such as "Robert".
scenery. The object is a feature of its location; compare with static.
scored. The points associated with this object have been awarded.
static. The object is fixed in place; compare with scenery.
supporter. This object can have other objects on top of it.
switchable. The object can be turned on and off.
talkable. This object can be talked to, e.g.: telephone, microphone.
transparent. The object's contents can be seen (assuming there's light).
visited. The player character has visited this location.
workflag. This object has been temporarily selected by the Inform library for some reason.
worn. The player character is currently wearing this object.
]]--
-- player
mp.msg.Look = {}
function mp:room_content(w)
	if w:type 'dlg' then
		return
	end
	local oo = {}
	local ooo = {}
	self:objects(w, oo, false)
	for _, v in ipairs(oo) do
		local r, rc = std.call(v, 'dsc')
		if not rc and not v:has'scenery' then
			table.insert(ooo, v)
		end
	end
	oo = ooo
	if #oo == 0 then
		return
	elseif #oo == 1 then
		p (mp.msg.Look.HEREIS or "Here is")
		p(oo[1]:noun(), ".")
	else
		p (mp.msg.Look.HEREARE or "Here there are")
		for _, v in ipairs(oo) do
			if _ ~= 1 then
				if _ == #oo then
					p (" ", mp.msg.AND or "and")
				else
					p ","
				end
			end
			pr (v:noun())
		end
		p "."
	end
end

function std.obj:scene()
	local s = self
	local title, dsc
	title = iface:title(std.titleof(s))
	dsc = std.call(s, 'decor')
	return std.par(std.scene_delim, title or false, dsc)
end

local owalk = std.player.walk

std.obj.from = std.room.from

function std.player:walk(w, doexit, doenter, dofrom)
	w = std.object(w)
	if std.is_obj(w, 'room') then
		local r, v = owalk(self, w, doexit, doenter, dofrom)
		self.__room_where = false
		return r, v
	end
	if std.is_obj(w) then -- into object
		w.__from = std.me():where()
		if dofrom ~= false then
			self.__room_where = w
		end
		self:need_scene(true)
		return nil, true
	end
	std.err("Can not enter into: "..std.tostr(w), 2)
end

function std.player:walkout(w, ...)
	if w == nil then
		w = self:where():from()
	end
	return self:walk(w, true, false, ...)
end;

std.player.where = function(s, where)
	if type(where) == 'table' then
		table.insert(where, std.ref(s.__room_where or s.room))
	end
	return std.ref(s.__room_where or s.room)
end

std.player.look = function(s)
	local scene
	local r = s:where()
	if s:need_scene() then
		scene = r:scene()
	end
	local c = std.call(mp, 'room_content', s:where())
	return (std.par(std.scene_delim, scene or false, r:display() or false, c))
end;

-- 

function std.obj:access()
	local plw = {}
	local ww = {}
	if std.me():where() == self then
		return true
	end
	mp:trace(std.me(), function(v)
		if v:has 'concealed' then
			return nil, false
		end
		table.insert(plw, v)
		if v:has 'container' or v:has 'supporter' then
			return nil, false
		end
	end)
	return mp:trace(self, function(v)
		if v:has 'concealed' then
			return nil, false
		end
		for _, o in ipairs(plw) do
			if v == o then
				return true
			end
		end
		if v:has 'container' and not v:has 'open' then
			return nil, false
		end
	end)
end

function std.obj:visible()
	local plw = { }
	local ww = {}
	if std.me():where() == self then
		return true
	end
	mp:trace(std.me(), function(v)
		if v:has 'concealed' then
			return nil, false
		end
		table.insert(plw, v)
		if v:has 'container' and not v:has 'transparent' and not v:has 'open' then
			return nil, false
		end
	end)
	return mp:trace(self, function(v)
		if v:has 'concealed' then
			return nil, false
		end
		for _, o in ipairs(plw) do
			if v == o then
				return true
			end
		end
		if v:has 'container' and not v:has 'transparent' and not v:has 'open' then
			return nil, false
		end
	end)
end

-- dialogs
std.phr.word = function(s)
	return tostring(s.__ph_idx) or std.dispof(s)
end

std.phr.Exam = function(s, ...)
	std.me():need_scene(true)
	return s:act(...)
end

std.phr.__xref = function(s, str)
	return str
end

std.dlg.scene = std.room.scene

std.dlg.nouns = function(s)
	local r, nr
	local nouns = {}
	nr = 1
	local oo = s.current
	if not oo then -- nothing to show
		return
	end

	for i = 1, #oo.obj do
		local o = oo.obj[i]
		o = o:__alias()
		std.rawset(o, '__ph_idx', nr)
	end

	for i = 1, #oo.obj do
		local o = oo.obj[i]
		o = o:__alias()
		if o:visible() then
			std.rawset(o, '__ph_idx', nr)
			nr = nr + 1
			table.insert(nouns, o)
		end
	end
	return nouns
end;

std.phrase_prefix = function(n)
	if not n then
		return ''
	end
	return (string.format("%d) ", n))
end

-- VERBS
local function if_has(w, a, t, f)
	return w:has(a) and t or f
end

mp.msg.Exam = {}
function mp:content(w)
	local oo = {}
	self:objects(w, oo, false)
	if #oo == 0 then
		p (mp.msg.Exam.NOTHING or "nothing.")
	elseif #oo == 1 then
		p (mp.msg.Exam.IS or "there is")
		p(oo[1]:noun(), ".")
	else
		p (mp.msg.Exam.ARE or "there are")
		for _, v in ipairs(oo) do
			if _ ~= 1 then
				if _ == #oo then
					p (" ", mp.msg.AND or "and")
				else
					p ","
				end
			end
			pr (v:noun())
		end
		p "."
	end
end

function mp:before_Any(ev, w, ww)
	if ev == 'Exam' then
		return false
	end

	if w and not w:access() then
		p (self.msg.ACCESS1 or "{#First} is not accessible.")
		return
	end

	if ww and not ww:access() then
		p (self.msg.ACCESS2 or "{#Second} is not accessible.")
		return
	end

	return false
end

function mp:after_Exam(w)
	if not self.reaction and w then
		if w:has 'container' and (w:has'transparent' or w:has'open') then
			p(mp.msg.Exam.IN or "In the {#first/}")
			self:content(w)
		elseif w:has 'supporter' then
			p(mp.msg.Exam.ON or "On the {#first/}")
			self:content(w)
		else
			if w:has'openable' then
				if w:has 'open' then
					p (mp.msg.Exam.OPENED or "{#First} is opened.");
				else
					p (mp.msg.Exam.CLOSED or "{#First} is closed.");
				end
			end
			p (mp.msg.Exam.DEFAULT or "{#Me} did not see anything unusual.");
		end
	end
end

--"закрыт"
--"мочь"
--"держать"
function mp:before_Enter(w)
	if w == std.me():where() then
		p ("{#Me} уже ", if_has(w, 'supporter', 'на', 'в'), " {#first/пр,2}.")
		return
	end
	if seen(w, me()) then
		p ("{#Me} не {#word/мочь,#me,нст} зайти в то, что {#word/держать,#me,нст} в руках.")
		return
	end
	if not w:has 'enterable' then
		p ("Но в/на {#first/вн} невозможно войти, встать, сесть или лечь.")
		return
	end
	if w:has 'openable' and not w:has 'open' then
		p ("{#First} {#word/закрыт,#first}, и {#me} не {#word/мочь,#me,нст} зайти туда.")
		return
	end
	return false
end

function mp:Enter(w)
	walk(w)
end

--"залезть"
function mp:after_Enter(w)
	if not self.reaction then
		p ("{#Me} {#word/залезть,прш,#me} ", if_has(w, 'supporter', 'на', 'в'), " {#first/вн}.")
	end
end

function mp:Exit()
	walkback()
end
