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

    -- Signals for the tank_location ports
    signal tank_pos_in      : position := (0, 0);
    signal tank_pos_out     : position;
    signal speed_in         : std_logic_vector(2 downto 0) := "001"; -- Speed = 1
    signal speed_out        : std_logic_vector(2 downto 0);

    -- Testbench clock period
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the tank_control module
    tank_control_inst: entity work.tank_control
        port map(
            clk              => clk,
            rst_n            => rst_n,
            we               => we,
            tank_curr_pos_in => tank_pos_out, -- Input from tank_location
            tank_next_pos_out => tank_pos_in, -- Output to tank_location
            tank_display     => tank_display,
            tank_speed_in    => speed_out    -- Output from tank_location
        );

    -- Instantiate the tank_location module
    tank_location_inst: entity work.tank_location
        generic map(
            tank_loc => TANK_1_INIT_POS -- Replace with your initial tank position constant
        )
        port map(
            clk          => clk,
            rst_n        => rst_n,
            tank_pos_in  => tank_pos_in, -- Input from tank_control
            tank_pos_out => tank_pos_out, -- Output to tank_control
            speed_in     => tank_speed_in, -- Input from testbench
            speed_out    => speed_out     -- Output to tank_control
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
        -- Apply Reset
        rst_n <= '1';
        wait for 2 * clk_period;
        rst_n <= '0';
        wait for clk_period;
        rst_n <= '1';

        -- Test Case 1: Move Right
        we <= '1';
        tank_speed_in <= "010"; -- Speed = 2
        wait for 10 * clk_period;

        -- Test Case 2: Boundary Check (Right Edge)
        tank_pos_out(0) <= 639 - TANK_WIDTH; -- Near right boundary
        wait for 5 * clk_period;

        -- Test Case 3: Boundary Check (Left Edge)
        tank_pos_out(0) <= 1; -- Near left boundary
        wait for 5 * clk_period;

        -- Test Case 4: Reset and Move Left
        rst_n <= '0';
        wait for 2 * clk_period;
        rst_n <= '1';
        tank_speed_in <= "001"; -- Speed = 1
        tank_pos_out(0) <= 100; -- Start at position 100
        wait for 10 * clk_period;

        -- Test Case 5: Simulate Die State
        we <= '0'; -- Disable updates to simulate "die" state
        wait for 5 * clk_period;

        -- Test Case 6: Simulate Win State
        rst_n <= '0';
        wait for 2 * clk_period;
        rst_n <= '1';
        tank_pos_out(0) <= 0; -- Reset to start position
        wait for 10 * clk_period;

        -- End simulation
        wait;
    end process;

end architecture testbench;

