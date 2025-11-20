pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
	-- todo init paddle, ball, bricks, etc	
	paddle = {
		x = 64,
		y = 120,
		w = 24,
		h = 3,
		speed = 2
	}

	balls = {}
	spawn_ball()
	
	bricks = {}
	make_bricks()
	
	powerups = {}
	
	lives = 3
	state = "play"
end

function spawn_ball()
	add(balls, {
		x = paddle.x + paddle.w/2,
		y = paddle.y - 4,
		dx = 1,
		dy = 1,
		r = 2,
		active = true
		})
end

function make_bricks()
	for row=0,4 do
		for col=0,10 do
			local bx = 4 + col * 11
			local by = 10 + row * 6
			local power = (rnd(1) < 0.15) 
			add(bricks, {
				x = bx,
				y = by,
				w = 10,
				h = 4,
				hp = 1,
				power = power
			})
		end
	end
end
	
function _update()
	if state != "play" then return end

	update_paddle()
	update_balls()
	update_powerups()
	
	-- lose condition
	if count_active_balls() == 0 then
		lives -= 1
		sfx(06)
		if lives <= 0 then
			state = "gameover"
			sfx(04)
		else
			balls = {}
			spawn_ball()
		end
	end

	if #bricks == 0 then
		state = "win"
		sfx(05)
	end
end

function update_paddle()
	if btn(0) then paddle.x -= paddle.speed end
	if btn(1) then paddle.x += paddle.speed end
	paddle.x = mid(0, paddle.x, 128 - paddle.w)
end

function update_balls()
	for b in all(balls) do
		if b.active then
			b.x += b.dx
			b.y += b.dy
			
			wall_collide(b)
			brick_collide(b)
			paddle_collide(b)
			
			if b.y > 130 then
				b.active = false
			end
		end
	end
end

function count_active_balls()
	local c = 0
	for b in all(balls) do
		if b.active then c += 1 end
	end
	return c
end

function wall_collide(b)
	if b.x - b.r < 0 then
		b.x = b.r
		b.dx = abs(b.dx)
	elseif b.x + b.r > 128 then
		b.x = 128 - b.r
		b.dx = -abs(b.dx)
	end
	
	if b.y - b.r < 0 then
		b.y = b.r
		b.dy = abs(b.dy)
	end
end

function paddle_collide(b)
	if b.y + b.r >= paddle.y
	and b.y - b.r <= paddle.y + paddle.h
	and b.x >= paddle.x
	and b.x <= paddle.x + paddle.w then
	
		b.y = paddle.y - b.r
		b.dy = -abs(b.dy)
		
		sfx(1)
		
		local hit = (b.x - paddle.x) / paddle.w
		local a = hit * 2 - 1
		b.dx = a * 1.5
	end
end

function brick_collide(ball)
	for br in all(bricks) do
		if ball.x >= br.x
		and ball.x <= br.x + br.w
		and ball.y >= br.y
		and ball.y <= br.y + br.h then
		
			br.hp -= 1
			ball.dy = ball.dy
			
			sfx(02)
			
			if br.hp <= 0 then
				if br.power then
					spawn_powerup(br)
				end
				del(bricks, br)
			end
			
			return
		end
	end
end

function spawn_powerup(br)
	add(powerups, {
		x = br.x + br.w/2,
		y = br.y,
		kind = "multi"
	})
end

function update_powerups()
	for p in all(powerups) do
		p.y += 1
		
		if p.y >= paddle.y
		and p.x >= paddle.x
		and p.x <= paddle.x + paddle.w then
			apply_power(p.kind)
			del(powerups, p)
		elseif p.y > 128 then
			del(powerups, p)
		end
	end
end

function apply_power(kind)
	if kind == "multi" then
		multi_ball()
		sfx(0)
	end
end

function multi_ball()
	local src = nil
	for b in all(balls) do
		if b.active then src = b break end
	end
	if not src then return end
	
	for i=1,2 do
		add(balls, {
			x = src.x,
			y = src.y,
			dx = src.dx + (rnd(0.5)-0.25),
			dy = src.dy,
			r = 2,
			active = true
		})
	end
end

function _draw()
	cls()
	
	for br in all(bricks) do
		if br.power then
			rectfill(br.x, br.y, br.x+br.w, br.y+br.h, 9)
		else
			rectfill(br.x, br.y, br.x+br.w, br.y+br.h, 4)
		end
	end
	
	rectfill(paddle.x, paddle.y, paddle.x+paddle.w, paddle.y+paddle.h, 7)
	
	for b in all(balls) do
		if b.active then
			circfill(b.x, b.y, b.r, 7)
		end
	end
	
	for p in all(powerups) do
		circfill(p.x, p.y, 2, 9)
	end
	
	print("lives: "..lives, 2, 2, 7)
	
	if state == "win" then
		print("you win!", 48, 60, 11)
	elseif state == "gameover" then
		print("game over", 42, 60, 8)
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000f0002d00028050280502805028050220002000020000200002c0502b0502c0502d050290002e00031000340503405034050340500100001000010000100022050220502205022050230502305024050
00020000000000000000000000001f050230501d10017100280002700024000210001d0001b000190001900018000000000000000000000000000000000000000000000000000000000000000000000000000000
0002000000000000000f4001340015400204001c400141501615023400224001315017400144000f4000e4000d4000d4000e4000e400104000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c000000000000001b1001b1001b1501815015150121500d1500815001100091000f1000f1000310000100001000d1000d1000c1000c1000b1000b1000a1000000000000000000000000000000000000000000
00100000000000000000000000001025012250132501625018250192501c2501f25022250272502a2503025033250000000000033250362503625036250362503625036250000000000000000000000000000000
000600000000000000000000000000000000001d15017150131500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
