library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity collision is
	port(
		clk, rst_n, we  : in std_logic;
		
		tank_pos_in : in position;
		bullet_pos_in      : in position;
		bullet_fired_in    : in std_logic;
		collsion_hit       : out std_logic;
		direction          : in std_logic
		--dead               : out std_logic;
		);
end entity collision;

architecture fsm of collision is

	-- Define the states, including 'done'
	type state_type is (start, check_hit, win, done);
	signal current_state, next_state : state_type;

begin

	-- Asynchronous Reset and Synchronous State Update
	process(clk, rst_n)
		begin
			if rst_n = '1' then
				current_state <= start;
			elsif (rising_edge(clk)) then
				current_state <= next_state;
			end if;
	end process;
	
	-- Next State and Output Logic
	process(current_state, we, bullet_pos_in, bullet_fired_in, direction, tank_pos_in)
	begin
		-- Default assignments to avoid latches
		next_state <= current_state;
		collsion_hit <= '0';
		
		case current_state is
		
			when start =>
				if bullet_fired_in = '1' then
					next_state <= check_hit;
					collsion_hit <= '0';
				else
				   next_state <= start;
					collsion_hit <= '0';
				end if;
				
				
			when check_hit =>

				if direction = '0' then
					if (((bullet_pos_in(1) < tank_pos_in(1) + TANK_HEIGHT + TANK_GUNH)
						and (bullet_pos_in(1) - BULLET_H < tank_pos_in(1) + TANK_HEIGHT)
					   and (bullet_pos_in(0) < tank_pos_in(0) + TANK_WIDTH)
					   and (bullet_pos_in(0) + BULLET_W > tank_pos_in(0)))) then
						collsion_hit <= '1';
						next_state <= done;
					else
						collsion_hit <= '0';
						next_state <= check_hit;
					end if;
				else 
					if (((bullet_pos_in(1) + BULLET_H > tank_pos_in(1) - TANK_GUNH) 
						and (bullet_pos_in(1) < tank_pos_in(1) + TANK_HEIGHT) 
					   and (bullet_pos_in(0) < tank_pos_in(0) + TANK_WIDTH) 
					   and (bullet_pos_in(0) + BULLET_W > tank_pos_in(0)))) then
					   collsion_hit <= '1';
						next_state <= done;
					else
						collsion_hit <= '0';
					   next_state <= check_hit;
					end if;
				end if;
				
			when win =>
				collsion_hit <= '0';
				next_state <= done;
			
			when done =>
				-- Maintain the current state values explicitly
				collsion_hit <= '0';
				next_state <= start;
			
			when others =>
				-- Explicitly assign defaults in case of unexpected state
				next_state <= start;
				collsion_hit <= '0';
				
			end case;
	end process;

end architecture fsm;