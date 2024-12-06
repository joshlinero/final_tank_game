library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity bullet_control_tb is
end entity;

architecture test of bullet_control_tb is

    -- Component declarations for UUT and dependencies

    -- Signals for inputs to the UUT
    signal clk              : std_logic := '0';
    signal rst_n            : std_logic := '0';
    signal we               : std_logic := '0';
    signal tank_pos_in      : position := (0, 0);
    signal fire             : std_logic := '0';
    signal bullet_fired_in  : std_logic := '0';
    signal direction        : std_logic := '0';
    signal collision_hit    : std_logic := '0';

    -- Signals for outputs from the UUT
    signal bullet_pos_out   : position;
    signal bullet_fired_out : std_logic := '0';
    signal bullet_disp      : std_logic := '0';

    -- Signals for bullet_location and tank_location
    signal bullet_curr_pos  : position := (0, 0);
    signal bullet_next_pos  : position := (0, 0);
    signal bullet_curr_fire : std_logic := '0';
    signal bullet_next_fire : std_logic := '0';

    signal tank_curr_pos    : position := (100, 300);
    signal tank_next_pos    : position := (0, 0);
    signal tank_speed_in    : std_logic_vector(2 downto 0) := "001";
    signal tank_speed_out   : std_logic_vector(2 downto 0) := "001";

    -- Additional signals
    signal winner           : std_logic := '0';
    signal global_we        : std_logic := '0';
    signal tank_2_disp_flag : std_logic := '0';
    signal tank_2_curr_speed: std_logic_vector(2 downto 0) := "001";
    signal tank_1_wins      : std_logic := '0';

    -- Clock generation parameters
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the bullet_control component
    bullet_control_inst: entity work.bullet_control
        port map(
            clk              => clk,
            rst_n            => rst_n,
            we               => we,
            tank_pos_in      => tank_curr_pos,
            fire             => fire,
            bullet_pos_in    => bullet_curr_pos,
            bullet_pos_out   => bullet_next_pos,
            bullet_fired_in  => bullet_curr_fire,
            bullet_fired_out => bullet_next_fire,
            bullet_disp      => bullet_disp,
            direction        => direction,
            collision_hit    => collision_hit,
            winner           => winner
        );

    -- Instantiate the bullet_location component
    bullet_location_inst: entity work.bullet_location
        generic map(
            bullet_loc => (0, 0)
        )
        port map(
            clk         => clk,
            rst_n       => rst_n,
            we          => we,
            bull_pos_in => bullet_next_pos,
            bull_pos_out=> bullet_curr_pos,
            fired_in    => bullet_next_fire,
            fired_out   => bullet_curr_fire
        );

    -- Instantiate the tank_location component
    tank_location_inst: entity work.tank_location
        generic map(
            tank_loc => (100, 300)
        )
        port map(
            clk          => clk,
            rst_n        => rst_n,
            tank_pos_in  => tank_next_pos,
            tank_pos_out => tank_curr_pos,
            speed_in     => tank_speed_out,
            speed_out    => tank_speed_in
        );

    -- Instantiate the tank_control component for tank 2
    tank_2_control_inst : entity work.tank_control
        port map(
            clk              => clk,
            rst_n            => rst_n,
            we               => global_we,
            tank_curr_pos_in => tank_curr_pos,
            tank_next_pos_out=> tank_next_pos,
            tank_display     => tank_2_disp_flag,
            tank_speed_in    => tank_speed_in,
            winner           => tank_1_wins
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
        wait for clk_period;
		  rst_n <= '0';
        wait for clk_period;

        -- Test case 1: Fire bullet upwards
        we <= '1';
        fire <= '1';
        direction <= '0'; -- Upwards
        wait for clk_period * 2;
        fire <= '0';
        wait for clk_period * 10;

        -- Test case 2: Simulate collision
        collision_hit <= '1';
        wait for clk_period * 10;
        collision_hit <= '0';

        -- Test case 3: Fire bullet downwards
        fire <= '1';
        direction <= '1'; -- Downwards
        wait for clk_period;
        fire <= '0';
        wait for clk_period * 15;

        -- End simulation
        wait;
    end process;

end architecture test;


