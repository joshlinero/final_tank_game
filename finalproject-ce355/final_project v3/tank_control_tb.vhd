
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity tb_tank_control is
end entity tb_tank_control;

architecture testbench of tb_tank_control is
    -- Signals for the tank_control ports
    signal clk              : std_logic := '0';
    signal rst_n            : std_logic := '0';
    signal we               : std_logic := '0';
    signal tank_curr_pos_in : position := (0, 0);
    signal tank_next_pos_out: position;
    signal tank_display     : std_logic;
    signal tank_speed_in    : std_logic_vector(2 downto 0) := "001"; -- Speed = 1
	 signal winner     : std_logic := '0';
    -- Testbench clock period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the tank_control component
    tank_control_inst: entity work.tank_control
        port map(
            clk              => clk,
            rst_n            => rst_n,
            we               => we,
            tank_curr_pos_in => tank_curr_pos_in,
            tank_next_pos_out => tank_next_pos_out,
            tank_display     => tank_display,
            tank_speed_in    => tank_speed_in,
				winner           => winner
        );

    -- Clock process
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Testbench stimulus process
    stimulus_process: process
    begin
        -- Apply reset
        rst_n <= '0';
        wait for 2 * clk_period;
        rst_n <= '1';
        wait for 2 * clk_period;

        -- Test Case 1: Move Right
        we <= '1';
        tank_speed_in <= "010"; -- Speed = 2
        wait for 10 * clk_period;

        --assert tank_next_pos_out(0) > tank_curr_pos_in(0) report "Tank failed to move right" severity error;

        -- Test Case 2: Boundary Check (Right Edge)
        tank_curr_pos_in(0) <= 639 - TANK_WIDTH; -- Near right boundary
        wait for 5 * clk_period;

        --assert tank_next_pos_out(0) <= 639 report "Tank moved out of right boundary" severity error;

        -- Test Case 3: Boundary Check (Left Edge)
        tank_curr_pos_in(0) <= 1; -- Near left boundary
        wait for 5 * clk_period;

        --assert tank_next_pos_out(0) >= 0 report "Tank moved out of left boundary" severity error;

        -- Test Case 4: Reset and Move Left
        rst_n <= '0';
        wait for 2 * clk_period;
        rst_n <= '1';
        tank_speed_in <= "001"; -- Speed = 1
        tank_curr_pos_in(0) <= 100; -- Start at position 100
        wait for 10 * clk_period;

        --assert tank_next_pos_out(0) < tank_curr_pos_in(0) report "Tank failed to move left" severity error;

        -- Test Case 5: Simulate Die State
        we <= '0'; -- Disable updates to simulate "die" state
        wait for 5 * clk_period;

        --assert tank_display = '0' report "Tank display not off in 'die' state" severity error;

        -- Test Case 6: Simulate Win State
        rst_n <= '0';
        wait for 2 * clk_period;
        rst_n <= '1';
        tank_curr_pos_in(0) <= 0; -- Reset to start position
        wait for 10 * clk_period;

        --assert tank_display = '0' report "Tank display not off in 'win' state" severity error;

        -- End simulation
        wait;
    end process;

end architecture testbench;

