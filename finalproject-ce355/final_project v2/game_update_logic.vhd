library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity game_update_logic is
    port(
        clk, rst_n, global_write_enable : in std_logic;
        --pulse_out : in std_logic;

        -- Tank attribute inputs
        tank_1_pos_in, tank_2_pos_in : in position;

        -- Tank attribute outputs
        tank_1_pos_out, tank_2_pos_out : out position;
        tank_1_disp, tank_2_disp : out std_logic;
		  
		  tank_1_speed1, tank_1_speed2, tank_1_speed3  : in std_logic;
		  tank_2_speed1, tank_2_speed2, tank_2_speed3  : in std_logic;
		
		  tank_1_speed_in   : in std_logic_vector(2 downto 0);
		  tank_1_speed_out  : out std_logic_vector(2 downto 0);
		  tank_2_speed_in   : in std_logic_vector(2 downto 0);
		  tank_2_speed_out  : out std_logic_vector(2 downto 0);
		  
		  tank_1_fire, tank_2_fire : in std_logic;
		  
		  tank_1_bul_pos_in    : in position;
		  tank_1_bul_pos_out   : out position;
		  tank_1_bul_fired_in  : in std_logic;
		  tank_1_bul_fired_out : out std_logic;
		  tank_1_bul_disp      : out std_logic;
		  
		  tank_2_bul_pos_in    : in position;
		  tank_2_bul_pos_out   : out position;
		  tank_2_bul_fired_in  : in std_logic;
		  tank_2_bul_fired_out : out std_logic;
		  tank_2_bul_disp      : out std_logic;
		  
		  tank_1_score         : out integer;
		  tank_2_score         : out integer
    );
end entity game_update_logic;

architecture behavioral of game_update_logic is
    signal current_tank_1_pos, current_tank_2_pos : position := (others => 0);
    signal tank_1_direction, tank_2_direction : std_logic := '0'; -- '0' = left, '1' = right
    signal tank_1_speed, tank_2_speed : std_logic_vector(2 downto 0);
	 signal temp_bullet_1_fired, temp_bullet_2_fired : std_logic;
	 signal bullet_speed : natural := 8;
	 signal bullet_1_disp_signal, bullet_2_disp_signal : std_logic;
	 signal tank_1_bul_pos, tank_2_bul_pos : position;
	 signal score_1, score_2 : integer := 0;
	 signal counter_1, counter_2 : integer := 0;
begin

    position_update : process(clk, rst_n)
	begin
		 if rst_n = '1' then
			  -- Reset positions and directions
			  current_tank_1_pos <= tank_1_pos_in;
			  current_tank_2_pos <= tank_2_pos_in;
			  tank_1_direction <= '0';
			  tank_2_direction <= '0';
		 elsif rising_edge(clk) then
			  if global_write_enable = '1' then
					-- Read state: Update positions based on direction and speed
					--if pulse_out = '1' then
						 -- Tank 1 movement
						 if tank_1_direction = '1' then
							  if current_tank_1_pos(0) + TANK_WIDTH < 640 then
									current_tank_1_pos(0) <= current_tank_1_pos(0) + to_integer(unsigned(tank_1_speed_in));
							  else
									tank_1_direction <= '0'; -- Reverse direction
							  end if;
						 else
							  if current_tank_1_pos(0) > 0 then
									current_tank_1_pos(0) <= current_tank_1_pos(0) - to_integer(unsigned(tank_1_speed_in));
							  else
									tank_1_direction <= '1'; -- Reverse direction
							  end if;
						 end if;
	
						 -- Tank 2 movement
						 if tank_2_direction = '1' then
							  if current_tank_2_pos(0) + TANK_WIDTH < 640 then
									current_tank_2_pos(0) <= current_tank_2_pos(0) + to_integer(unsigned(tank_2_speed_in));
							  else
									tank_2_direction <= '0'; -- Reverse direction
							  end if;
						 else
							  if current_tank_2_pos(0) > 0 then
									current_tank_2_pos(0) <= current_tank_2_pos(0) - to_integer(unsigned(tank_2_speed_in));
							  else
									tank_2_direction <= '1'; -- Reverse direction
							  end if;
						 end if;
	
						 -- Maintain fixed vertical positions
						 current_tank_1_pos(1) <= TANK_1_POS_Y;
						 current_tank_2_pos(1) <= TANK_2_POS_Y;
					--end if;
			  else
					-- Write state: Ensure tanks remain within bounds
					-- Tank 1 bounds
					if current_tank_1_pos(0) - TANK_WIDTH / 2 < 0 then
						 current_tank_1_pos(0) <= TANK_WIDTH / 2;
						 tank_1_direction <= '1'; -- Reverse direction
					elsif current_tank_1_pos(0) + TANK_WIDTH / 2 > 640 then
						 current_tank_1_pos(0) <= 640 - TANK_WIDTH / 2;
						 tank_1_direction <= '0'; -- Reverse direction
					end if;
	
					-- Tank 2 bounds
					if current_tank_2_pos(0) - TANK_WIDTH / 2 < 0 then
						 current_tank_2_pos(0) <= TANK_WIDTH / 2;
						 tank_2_direction <= '1'; -- Reverse direction
					elsif current_tank_2_pos(0) + TANK_WIDTH / 2 > 640 then
						 current_tank_2_pos(0) <= 640 - TANK_WIDTH / 2;
						 tank_2_direction <= '0'; -- Reverse direction
					end if;
	
					-- Maintain vertical positions
					current_tank_1_pos(1) <= TANK_1_POS_Y;
					current_tank_2_pos(1) <= TANK_2_POS_Y;
			  end if;
			  	 -- Output assignments
			tank_1_pos_out <= current_tank_1_pos;
			tank_2_pos_out <= current_tank_2_pos;
		 end if;
	end process;
	 
	speed_update : process(clk, rst_n)
		 variable speed_1_temp, speed_2_temp : std_logic_vector(2 downto 0) := SPEED_SLOW;
	begin
		 if rst_n = '1' then
			  speed_1_temp := SPEED_SLOW;
			  speed_2_temp := SPEED_SLOW;
			  tank_1_speed_out <= SPEED_SLOW;
			  tank_2_speed_out <= SPEED_SLOW;
		 elsif rising_edge(clk) then
			  if global_write_enable = '1' then
					-- Update speed based on input signals
						 -- Tank 1 speed update
						 if tank_1_speed1 = '1' then
							  speed_1_temp := SPEED_SLOW;
						 elsif tank_1_speed2 = '1' then
							  speed_1_temp := SPEED_MEDIUM;
						 elsif tank_1_speed3 = '1' then
							  speed_1_temp := SPEED_FAST;
						 end if;
	
						 -- Tank 2 speed update
						 if tank_2_speed1 = '1' then
							  speed_2_temp := SPEED_SLOW;
						 elsif tank_2_speed2 = '1' then
							  speed_2_temp := SPEED_MEDIUM;
						 elsif tank_2_speed3 = '1' then
							  speed_2_temp := SPEED_FAST;
						 end if;
	
					-- Assign updated speeds to outputs
					tank_1_speed_out <= speed_1_temp;
					tank_2_speed_out <= speed_2_temp;
			  end if;
		 end if;
	end process;
	
	--Process for UPDATING BULLET POSITION
	tank_1_bul_disp <= bullet_1_disp_signal;
	tank_2_bul_disp <= bullet_2_disp_signal;
	
	bullet_update : process(clk, rst_n) is
	begin
	
		tank_1_bul_pos(0) <= tank_1_bul_pos_in(0);
		tank_2_bul_pos(0) <= tank_2_bul_pos_in(0);
		if (rst_n = '1') then
		   score_1 <= 0;
			score_2 <= 0;
			counter_1 <= 0;
			counter_2 <= 0;
			bullet_1_disp_signal <= '0';
			bullet_2_disp_signal <= '0';
			tank_1_bul_fired_out <= '0';
			tank_2_bul_fired_out <= '0';
		elsif (rising_edge(clk)) then
			if global_write_enable = '1' then --read state
					temp_bullet_1_fired <= tank_1_bul_fired_in;
					tank_1_bul_pos(1) <= tank_1_bul_pos_in(1) - bullet_speed; --bullet A travels upwards
					--tank_1_bul_pos(0) <= tank_1_bul_pos_in(0);
					temp_bullet_2_fired <= tank_2_bul_fired_in;
					tank_2_bul_pos(1) <= tank_2_bul_pos_in(1) + bullet_speed; --bullet B travels downwards
					--tank_2_bul_pos(0) <= tank_2_bul_pos_in(0);

			else 					--write state
				if (((tank_1_bul_pos(1) - BULLET_H < tank_2_pos_in(1) + TANK_HEIGHT + TANK_GUNH) -- Bullet's top edge < Tank 2's bottom edge
					and (tank_1_bul_pos(1) + BULLET_H > tank_2_pos_in(1)) -- Bullet's bottom edge > Tank 2's top edge
					and (tank_1_bul_pos(0) - BULLET_W < tank_2_pos_in(0) + TANK_WIDTH) -- Bullet's left edge < Tank 2's right edge
					and (tank_1_bul_pos(0) + BULLET_W > tank_2_pos_in(0))
					and temp_bullet_1_fired = '1'
					and counter_1 = 1000000)) then
					bullet_1_disp_signal <= '0';
					tank_1_bul_fired_out <= '0';
					temp_bullet_1_fired <= '0';
					score_1 <= score_1 + 1;
					tank_1_bul_pos_out <= tank_1_pos_in;
					counter_1 <= 0;
				
				elsif (temp_bullet_1_fired = '1' and ((tank_1_bul_pos(1)) - BULLET_H <= 0)) then
					-- bullet out of bounds, reset conditions
					tank_1_bul_fired_out <= '0';
					bullet_1_disp_signal <= '0';
					temp_bullet_1_fired <= '0';
					tank_1_bul_pos_out <= tank_1_pos_in;
				elsif (temp_bullet_1_fired = '0' and tank_1_fire = '1') then
					--player first fires bullet
					tank_1_bul_pos_out(0) <= tank_1_pos_in(0) + (TANK_WIDTH/2);
					tank_1_bul_pos_out(1) <= tank_1_pos_in(1) - (TANK_HEIGHT) - (TANK_GUNH) - (BULLET_H/2);
					bullet_1_disp_signal <= '1';
					tank_1_bul_fired_out <= '1';

				elsif (temp_bullet_1_fired = '1') then
					--bullet already fired
					tank_1_bul_pos_out <= tank_1_bul_pos;
					bullet_1_disp_signal <= '1';
					tank_1_bul_fired_out <= '1';
				end if;
				if (counter_1 < 1000000) then
					counter_1 <= counter_1 + 1;
				end if;

				if (((tank_2_bul_pos(1) + BULLET_H > tank_1_pos_in(1) - TANK_GUNH) 
					   and (tank_2_bul_pos(1) - BULLET_H < tank_1_pos_in(1) + TANK_HEIGHT) 
					   and (tank_2_bul_pos(0) - BULLET_W < tank_1_pos_in(0) + TANK_WIDTH) 
					   and (tank_2_bul_pos(0) + BULLET_W > tank_1_pos_in(0))
					   and temp_bullet_2_fired = '1'
						and counter_2 = 1000000)) then
					bullet_2_disp_signal <= '0';
					tank_2_bul_fired_out <= '0';
					temp_bullet_2_fired <= '0';
					score_2 <= score_2 + 1;
					counter_2 <= 0;
					tank_2_bul_pos_out <= tank_2_pos_in;
				elsif (temp_bullet_2_fired = '1' and ((tank_2_bul_pos(1)) + BULLET_H >= 480)) then
					-- bullet out of bounds, reset conditions
					tank_2_bul_fired_out <= '0';
					bullet_2_disp_signal <= '0';
					temp_bullet_2_fired <= '0';
					tank_2_bul_pos_out <= tank_2_pos_in;
				elsif (temp_bullet_2_fired = '0' and tank_2_fire = '1') then
					--player first fires bullet
					tank_2_bul_pos_out(0) <= tank_2_pos_in(0) + (TANK_WIDTH/2);
					tank_2_bul_pos_out(1) <= tank_2_pos_in(1) + (TANK_HEIGHT) + (TANK_GUNH) + (BULLET_H);
					bullet_2_disp_signal <= '1';
					tank_2_bul_fired_out <= '1';
				elsif (temp_bullet_2_fired = '1') then
					--bullet already fired
					tank_2_bul_pos_out <= tank_2_bul_pos;
					bullet_2_disp_signal <= '1';
					tank_2_bul_fired_out <= '1';
				end if;
				if counter_2 < 1000000 then
					counter_2 <= counter_2 + 1;
				end if;

			end if;
		end if;
	end process;
	
	game_score_update : process(clk, rst_n) is
	begin
		if (rst_n = '1') then
			tank_1_score <= 0;
			tank_2_score <= 0;
		elsif (rising_edge(clk)) then
			if (score_1 >= 3) then
				tank_2_disp <= '0';
			elsif (score_2 >= 3) then
				tank_1_disp <= '0';
			else
				tank_1_disp <= '1';
				tank_2_disp <= '1';
			end if;
			tank_1_score <= score_1;
			tank_2_score <= score_2;

		end if;
	end process;
	
	

end architecture behavioral;
