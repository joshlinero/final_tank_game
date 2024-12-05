library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity tank_control is
	port(
		clk, rst_n, we  : in std_logic;
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
	signal tank_next_pos : position; 
	signal temp_display : std_logic := '1'; -- Default display ON
	signal speed : integer := 5;

begin

	-- Asynchronous Reset and Synchronous State Update
	process(clk, rst_n)
		begin
			if rst_n = '1' then
				current_state <= start;
				tank_next_pos_out <= TANK_1_INIT_POS; -- Ensure all outputs are assigned
				tank_display <= '1'; -- Ensure all outputs are assigned
			elsif (rising_edge(clk)) then
				current_state <= next_state;
				tank_next_pos_out <= tank_next_pos; 
				tank_display <= temp_display; 
			end if;
	end process;
	
	-- Next State and Output Logic
	process(current_state, we, tank_curr_pos_in, tank_speed_in)
		variable new_pos : position;
		variable new_state : state_type;
	begin
		-- Default assignments to avoid latches
		new_pos := tank_curr_pos_in;
		temp_display <= '1'; -- Default display ON
		
		case current_state is
		
			when start =>
				new_state := move_right;
		
			when move_right =>
				if we = '1' then
					new_pos(0) := new_pos(0) + to_integer(unsigned(tank_speed_in));
					new_pos(1) := new_pos(1);
				end if;
				
				if new_pos(0) + TANK_WIDTH >= 640 then
					new_state := move_left;
				else
					new_state := move_right;
				end if;
			
		
			when move_left =>
				if we = '1' then
					new_pos(0) := new_pos(0) - to_integer(unsigned(tank_speed_in));
					new_pos(1) := new_pos(1);
				end if;
				
				if new_pos(0) <= 0 then
					new_state := move_right;
				else
					new_state := move_left;
				end if;
			
			when die =>
				temp_display <= '0'; -- Turn off display
				new_state := done;
			
			when win =>
				temp_display <= '1'; -- Keep display ON
				new_state := done;
			
			when done =>
				-- Maintain the current state values explicitly
				new_state := done;
			
			when others =>
				-- Explicitly assign defaults in case of unexpected state
				new_state := start;
				new_pos := (others => 0); -- Reset array to zero
				temp_display <= '1';
				
			end case;
			
			tank_next_pos <= new_pos;
			next_state <= new_state;
	end process;

end architecture fsm;
