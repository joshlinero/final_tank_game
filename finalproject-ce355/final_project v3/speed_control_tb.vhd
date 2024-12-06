library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity speed_control_tb is
end entity;

architecture test of speed_control_tb is


    -- Signals for the test bench
    signal clk              : std_logic := '0';
    signal rst_n            : std_logic := '1';
    signal speed1           : std_logic := '0';
    signal speed2           : std_logic := '0';
    signal speed3           : std_logic := '0';
    signal tank_speed_in    : std_logic_vector(2 downto 0) := "000";
    signal tank_speed_out   : std_logic_vector(2 downto 0);

    signal tank_pos_in      : position := (0, 0);
    signal tank_pos_out     : position;
    signal we               : std_logic := '1';
    signal tank_display     : std_logic := '1';
    signal winner           : std_logic := '0';

    -- Clock period constant
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the speed_control component
    speed_control_inst: entity work.speed_control
        port map(
            clk              => clk,
            rst_n            => rst_n,
            speed1           => speed1,
            speed2           => speed2,
            speed3           => speed3,
            tank_speed_in    => tank_speed_in,
            tank_speed_out   => tank_speed_out
        );

    -- Instantiate the tank_location component
    tank_location_inst: entity work.tank_location
        generic map(
            tank_loc => (100, 300)
        )
        port map(
            clk          => clk,
            rst_n        => rst_n,
            tank_pos_in  => tank_pos_in,
            tank_pos_out => tank_pos_out,
            speed_in     => tank_speed_out,
            speed_out    => tank_speed_in
        );

    -- Instantiate the tank_control component
    tank_control_inst: entity work.tank_control
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            we                  => we,
            tank_curr_pos_in    => tank_pos_out,
            tank_next_pos_out   => tank_pos_in,
            tank_display        => tank_display,
            tank_speed_in       => tank_speed_out,
            winner              => winner
        );

    -- Clock generation
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Test Stimulus
    stim_proc: process
    begin
        -- Apply reset
        rst_n <= '0';
        wait for clk_period;
        rst_n <= '1';
        wait for clk_period * 2;
		  rst_n <= '0';
        wait for clk_period;

        -- Test case 1: Set speed1
        speed1 <= '1';
        wait for clk_period * 5;
        speed1 <= '0';

        -- Test case 2: Set speed2
        speed2 <= '1';
        wait for clk_period * 5;
        speed2 <= '0';

        -- Test case 3: Set speed3
        speed3 <= '1';
        wait for clk_period * 5;
        speed3 <= '0';

        -- Test case 4: Default speed from tank_speed_in
        tank_speed_in <= "011";
        wait for clk_period * 5;

        -- End simulation
        wait;
    end process;

end architecture test;
