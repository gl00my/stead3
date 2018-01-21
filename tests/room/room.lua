require "sprite"
require "theme"

local std = stead
local function tableConcat(t1, t2)
    for i=1, #t2 do
	t1[#t1 + 1] = t2[i]
    end
    return t1
end

local map = {
}
-- https://github.com/hunterloftis/playfuljs-demos/blob/gh-pages/raycaster/index.html
-- http://nicmendoza.github.io/playfuljs-demos/raycaster/js/game.js
function map:new(w, h)
    local m = {
	w = w,
	h = h,
	objects = { {w = 1, h = 1, x = 3, y = 2.5, floorOffset = 0 }};
	data = {};
    }
    self.__index = self
    for i = 1, h do
	m.data[i] = {}
	for j = 1, w do
	    m.data[i][j] = {}
	end
    end
    return std.setmt(m, self)
end

function map:cell(block)
    return { block = block }
end

function map:set(x, y, b)
    if x >= self.w or x < 0 or y >= self.h or y < 0 then
	return false
    end
    self.data[y + 1][x + 1] = b
end

local empty = {}
function map:get(x, y)
    x = math.floor(x)
    y = math.floor(y)
    if x >= self.w or x < 0 or y >= self.h or y < 0 then
	return false
    end
    return self.data[y + 1][x + 1]
end

local BLOCK_HEIGHT = 1 -- 1.2

function map:get_height(x, y)
    local b = self:get(x, y)
    if not b then
	return -1
    end
    return b.block and BLOCK_HEIGHT or 0
end

local noWall = { length2 = math.huge };

local function step(rise, run, x, y, inverted)
    if run == 0 then return noWall end
    local dx = run > 0 and math.floor(x + 1) - x or math.ceil(x - 1) - x;
    local dy = dx * (rise / run);
    return {
	x = inverted and y + dy or x + dx,
	y = inverted and x + dx or y + dy,
	length2 = dx * dx + dy * dy
    };
end

function map:cast(point, angle, range)
    local sin = math.sin(angle)
    local cos = math.cos(angle)
    local function inspect(step, shiftX, shiftY, distance, offset)
          local dx = cos < 0 and shiftX or 0;
          local dy = sin < 0 and shiftY or 0;
          step.height = self:get_height(step.x - dx, step.y - dy);
          step.distance = distance + math.sqrt(step.length2);
          if shiftX ~= 0 then
	      step.shading = cos < 0 and 2 or 0;
          else
	      step.shading = sin < 0 and 2 or 1;
	  end
          step.offset = offset - math.floor(offset);
          return step;
    end
    local function ray(origin)
	local stepX = step(sin, cos, origin.x, origin.y);
	local stepY = step(cos, sin, origin.y, origin.x, true);
	local nextStep = stepX.length2 < stepY.length2
	and inspect(stepX, 1, 0, origin.distance, stepX.y)
            or inspect(stepY, 0, 1, origin.distance, stepY.x);
	if nextStep.distance > range then return {origin} end
	return tableConcat({origin}, ray(nextStep))
    end
    return ray({ x = point.x, y = point.y, height = 0, distance = 0})
end

local hero = {

}

function hero:new(x, y, dir)
    local h = {
	x = x;
	y = y;
	dir = dir;
	paces = 0;
    }
    self.__index = self
    return std.setmt(h, self)
end

local CIRCLE = 2 * math.pi

function hero:rotate(angle)
    self.dir = (self.dir + angle + CIRCLE) % CIRCLE;
end

function hero:walk(dist, map)
    local dx = math.cos(self.dir) * dist;
    local dy = math.sin(self.dir) * dist;
    local m = map:get(self.x + dx, self.y)
    if not m or not m.block then
	self.x = self.x + dx;
    end
    m = map:get(self.x, self.y + dy)
    if not m or not m.block then
	self.y = self.y + dy;
    end
    self.paces = self.paces + dist
end

local cam = {
}

function cam:new(w, h, res, focal, scale)
    local c = {
	w = w,
	h = h,
	res = res,
	spacing = w / res,
	focal = focal or 0.8,
	range = 14,
	lightRange = 5,
	scale = scale,
    }
    c.pxl = pixels.new(w, h, scale)
    c.texture = pixels.new "wall.png"

    self.__index = self
    return std.setmt(c, self)
end

function cam:sky(dir)
    self.pxl:clear(0, 0, 0)
end
local CAM_HEIGHT = 0.5 -- 0.7
local CAM_VIEW = 1 -- 0.5
function cam:project(height, angle, distance)
    local z = distance * math.cos(angle)
    local wallHeight = self.h * height / z;
    local bottom = self.h * CAM_HEIGHT * (CAM_VIEW + 1 / z);
    return {
          top = bottom - wallHeight,
          height = wallHeight,
    }
end

function cam:sprite_column(pl, map, column, columnProps, sprites)
    local left = math.floor(column * self.spacing)
    local width = math.ceil(self.spacing)
    local angle = column / self.res - 0.5
    local columnWidth = self.w / self.res

    local sp = {}
    for k, v in ipairs(sprites) do
	if not columnProps.hit or v.distanceFromPlayer < columnProps.hit then
	    table.insert(sp, v)
	end
    end

    for i, sprite in ipairs(sp) do
	local spriteIsInColumn = left > sprite.render.cameraXOffset - (sprite.render.w / 2 ) and left < sprite.render.cameraXOffset + ( sprite.render.w / 2 );
	if spriteIsInColumn then
	    self.pxl:fill(left, sprite.render.top, 1, sprite.render.height, 0, 0, 255);
	end
    end
end

function cam:draw_sprites(pl, map, columnProps)
	local screenWidth = self.w
	local screenHeight = self.h
	local resolution = self.res
	local sprites = {}

	for k, o in ipairs(map.objects) do
	    local distX = o.x - pl.x
	    local distY = o.y - pl.y
	    o.distanceFromPlayer = math.sqrt(distX ^ 2 + distY ^ 2);
	    local width = o.w * self.w / o.distanceFromPlayer
	    local height = o.h * self.h / o.distanceFromPlayer
	    local renderedFloorOffset = o.floorOffset / o.distanceFromPlayer
	    local angleToPlayer = math.atan2(distY, distX)
	    local angleRelativeToPlayerView = pl.dir - angleToPlayer
	    local top = (self.h * CAM_HEIGHT) * (CAM_VIEW + 1 / o.distanceFromPlayer) - height;

	    if angleRelativeToPlayerView >= CIRCLE / 2 then
		angleRelativeToPlayerView = angleRelativeToPlayerView - CIRCLE;
	    end

	    local cameraXOffset = ( self.w / 2 ) - (self.w * angleRelativeToPlayerView)
	    local numColumns = width / self.w * self.res
	    local firstColumn = math.floor( (cameraXOffset - width / 2 ) / self.w * self.res);
	    o.render = {
		w = width,
		h = height,
		height = height;
		angleToPlayer = angleRelativeToPlayerView,
		cameraXOffset = cameraXOffset,
		distanceFromPlayer = o.distanceFromPlayer,
		numColumns = numColumns,
		firstColumn = firstColumn,
		top = top,
	    }
	    table.insert(sprites, o)
	end
	table.sort(sprites, function(a, b)
		       return a.distanceFromPlayer < b.distanceFromPlayer
	end)
	for column = 1, self.res, 1 do
	    self:sprite_column(pl, map, column, columnProps[column], sprites);
	end
end

function cam:column(col, ray, angle, map, pl)
    local left = math.floor(col * self.spacing)
    local width = math.ceil(self.spacing)
    local hit, hitDistance
    local objects = {}
    local pxl = self.pxl
    for i = 1, #ray do
	if ray[i].height > 0 then hit = i break end
    end

    for s = #ray, 1, -1 do
	local step = ray[s]
	if s == hit then
	    local wall = self:project(step.height, angle, step.distance)
	    wall.top = wall.top + math.cos(pl.paces * 6) * 4
	    local alpha = step.distance + step.shading - self.lightRange + 1
	    local tw, th = self.texture:size()
	    local textX = math.floor(tw * step.offset);
	    if alpha > 1 then alpha = 1 end
	    if alpha < -1 then alpha = -1 end
	    alpha = 1 - ((1 + alpha) / 2)
	    local ty = 0
	    local delta = th / wall.height
	    local r, g, b, a, ny
	    ny = 0
	    local height = wall.height / th
--	    if math.abs(alpha) < 0.1 then return end
	    if height < 1 then
		for y = 0, wall.height - 1 do
		    r, g, b, a = self.texture:val(textX, math.floor(ty))
		    ty = ty + delta
		    pxl:clear(left, wall.top + y, width, 1, r * alpha, g * alpha, b * alpha);
		end
	    else
		ty = wall.top
		for y = 0, th - 1 do
		    r, g, b, a = self.texture:val(textX, math.floor(y))
		    pxl:clear(left, math.floor(ty), width, math.ceil(height), r * alpha, g * alpha, b * alpha);
		    ty = ty + height
		end
	    end
	    hitDistance = step.distance
	elseif step.object then
	    table.insert(objects, {
			     object = step.object,
			     ditsance = step.distance,
			     offset = step.offset,
			     angle = angle,
	    })
	end
    end
    return {
	objects = objects,
	hit = hitDistance,
    }
end

function cam:columns(pl, map)
    local props = {}
    for col = 0, self.res do
	local x = col / self.res - 0.5
	local angle = math.atan2(x, self.focal)
	local ray = map:cast(pl, pl.dir + angle, self.range)
	local o = self:column(col, ray, angle, map, pl)
	table.insert(props, o)
    end
    self:draw_sprites(pl, map, props)
end
function cam:render(pl, map)
    self:sky(pl.dir)
    self:columns(pl, map)
end

local r = {
}

function r:new(w, h, scale)
    local o = {
	player = hero:new(0, 0, 0);
	map = map:new(5, 5);
	camera = cam:new(w, h, 64, 1, scale);
    }
    self.__index = self
    return std.setmt(o, self)
end

function r:render()
--    self.player:rotate(0.8)
--    self.player:walk(0, self.map)
    self.camera:render(self.player, self.map)
end
function r:draw()
    self.camera.pxl:copy_spr(sprite.scr(),
	(theme.scr.w() - self.camera.w * self.camera.scale)/ 2,
	(theme.scr.h() - self.camera.h * self.camera.scale)/2)
end
return r
