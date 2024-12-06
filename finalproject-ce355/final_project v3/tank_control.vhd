library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity tank_control is

	port(
		clk, rst_n, we  		: in std_logic;
		tank_curr_pos_in     : in position;
		tank_next_pos_out    : out position;
		tank_display         : out std_logic;
		tank_speed_in        : in std_logic_vector(2 downto 0)
	);
	
end entity tank_control;

architecture fsm of tank_control is

	-- Define the states, including 'done'
	type state_type is (start, move_right, move_left, die, win, done);
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
	process(current_state, we, tank_curr_pos_in, tank_speed_in)
	begin
		-- Default assignments to avoid latches
		next_state <= current_state;
		tank_next_pos_out <= tank_curr_pos_in;
		tank_display <= '1'; -- Default display ON
		
		case current_state is
		
			when start =>
				tank_next_pos_out <= tank_curr_pos_in;
				tank_display <= '1';
				next_state <= move_right;
		
			when move_right =>
				if we = '1' then
					tank_next_pos_out(0) <= tank_curr_pos_in(0) + to_integer(unsigned(tank_speed_in));
					tank_next_pos_out(1) <= tank_curr_pos_in(1);
				end if;
				
				tank_display <= '1';
				
				if tank_curr_pos_in(0) + TANK_WIDTH + to_integer(unsigned(tank_speed_in)) >= 640 then
					next_state <= move_left;
				else
					next_state <= move_right;
				end if;
			
		
			when move_left =>
				if we = '1' then
					tank_next_pos_out(0) <= tank_curr_pos_in(0) - to_integer(unsigned(tank_speed_in));
					tank_next_pos_out(1) <= tank_curr_pos_in(1);
				end if;
				
				tank_display <= '1';
				
				if tank_curr_pos_in(0) - to_integer(unsigned(tank_speed_in)) <= 0 then
					next_state <= move_right;
				else
					next_state <= move_left;
				end if;
			
			when die =>
				tank_next_pos_out <= TANK_1_INIT_POS;
				tank_display <= '0';
				next_state <= done;
			
			when win =>
				tank_next_pos_out <= tank_curr_pos_in;
				tank_display <= '0';
				next_state <= done;
			
			when done =>
				tank_next_pos_out <= tank_curr_pos_in;
				tank_display <= '0';
				next_state <= done;
			
			when others =>
				tank_next_pos_out <= (others => 0);
				tank_display <= '0';
				next_state <= start;
				
			end case;

	end process;

end architecture fsm;
