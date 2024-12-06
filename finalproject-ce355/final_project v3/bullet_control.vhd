library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity bullet_control is
	port(
		clk, rst_n, we  : in std_logic;
		
		tank_pos_in : in position;
		fire            : in std_logic;
		bullet_pos_in      : in position;
		bullet_pos_out     : out position;
		bullet_fired_in    : in std_logic;
		bullet_fired_out   : out std_logic;
		bullet_disp        : out std_logic;
		direction          : in std_logic;
		collision_hit      : in std_logic;
		winner             : in std_logic
		
		);
end entity bullet_control;

architecture fsm of bullet_control is

	-- Define the states, including 'done'
	type state_type is (start, move_bullet, hit_boundary, get_hit, die, done);
	signal current_state, next_state : state_type;
	--signal bullet_next_pos : position; 
	--signal bullet_fired_temp : std_logic;
	--signal temp_display : std_logic := '1'; -- Default display ON
	signal speed : integer := 5;

begin

	-- Asynchronous Reset and Synchronous State Update
	process(clk, rst_n)
		begin
			if rst_n = '1' then
				current_state <= start;
				--bullet_pos_out <= (others => 0); -- Ensure all outputs are assigned
				--bullet_disp <= '0'; -- Ensure all outputs are assigned
				--bullet_fired_out <= '0';
			elsif (rising_edge(clk)) then
				current_state <= next_state;
				--bullet_pos_out <= bullet_next_pos; 
				--bullet_disp <= temp_display; 
				--bullet_fired_out <= bullet_fired_temp;
			end if;
	end process;
	
	-- Next State and Output Logic
	process(current_state, we, bullet_pos_in, fire, bullet_fired_in, direction, speed, tank_pos_in, winner, collision_hit)
		--variable new_pos : position;
		--variable new_state : state_type;
	begin
		-- Default assignments to avoid latches
		next_state <= current_state;
		bullet_pos_out <= bullet_pos_in;
		bullet_fired_out <= bullet_fired_in;
		--bullet_disp <= '0';
		
		case current_state is
		
			when start =>
				if fire = '1' then
					bullet_disp <= '1';
					next_state <= move_bullet;
					bullet_fired_out <= '1';
					if direction = '0' then
						bullet_pos_out(0) <= tank_pos_in(0) + TANK_WIDTH/2 - BULLET_W/2;
						bullet_pos_out(1) <= tank_pos_in(1) - TANK_GUNH - BULLET_H;
					else
						bullet_pos_out(0) <= tank_pos_in(0) + TANK_WIDTH/2 - BULLET_W/2;
						bullet_pos_out(1) <= tank_pos_in(1) + TANK_GUNH;
					end if;
				else 
					bullet_disp <= '0';
					bullet_fired_out <= '0';
				   next_state <= start;
					bullet_pos_out(0) <= -1000;
					bullet_pos_out(1) <= -1000;
				end if;
				
				if winner = '1' then
					next_state <= die;
				end if;
				
--			when make_bullet =>
--				if direction = '0' then
--					new_pos(0) := tank_pos_in(0) + TANK_WIDTH/2 - BULLET_W/2;
--					new_pos(1) := tank_pos_in(1) - TANK_GUNH - BULLET_H;
--				else 
--					new_pos(0) := tank_pos_in(0) + TANK_WIDTH/2 - BULLET_W/2;
--					new_pos(1) := tank_pos_in(1) + TANK_GUNH + BULLET_H;
--				end if;
--				new_state := move_bullet;
				
			when move_bullet =>
				if we = '1' then
					if direction = '0' then
						bullet_pos_out(1) <= bullet_pos_in(1) - speed;
						bullet_pos_out(0) <= bullet_pos_in(0);
					else
						bullet_pos_out(1) <= bullet_pos_in(1) + speed;
						bullet_pos_out(0) <= bullet_pos_in(0);
					end if;
				end if;
				if (direction = '0' and bullet_pos_in(1) < 0) or 
					(direction = '1' and bullet_pos_in(1) + BULLET_H > 480) then
					next_state <= hit_boundary;
				else
					next_state <= move_bullet;
				end if;
				
				bullet_fired_out <= '1';
				
				if collision_hit = '1' then
					bullet_fired_out <= '0';
				   next_state <= hit_boundary;
				end if;
				
				if winner = '1' then
					next_state <= die;
				end if;
			
			when hit_boundary =>
			   bullet_disp <= '0'; -- Turn off display	
				bullet_fired_out <= '0';
				bullet_pos_out(0) <= -1000;
				bullet_pos_out(1) <= -1000;
				if winner = '1' then
					next_state <= die;
				else
					next_state <= start;
				end if;
			
			when die =>
				bullet_disp <= '0'; -- Keep display ON
				next_state <= done;
				bullet_pos_out(0) <= -1000;
				bullet_pos_out(1) <= -1000;
				bullet_fired_out <= '0';
			
			when done =>
				-- Maintain the current state values explicitly
				next_state <= done;
				bullet_pos_out(0) <= -1000;
				bullet_pos_out(1) <= -1000;
				bullet_fired_out <= '0';
			
			when others =>
				-- Explicitly assign defaults in case of unexpected state
				next_state <= start;
				bullet_disp <= '1';
				bullet_pos_out(0) <= 300;
				bullet_pos_out(1) <= 300;
				bullet_fired_out <= '0';
				
			end case;
	end process;

end architecture fsm;