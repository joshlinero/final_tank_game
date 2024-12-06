library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity game_winner_tb is
end entity;

architecture test of game_winner_tb is

	component game_winner
        port(
            clk            : in std_logic;
            rst_n          : in std_logic;
            we             : in std_logic;
            winner         : out std_logic;
            score          : out integer;
            collision_hit  : in std_logic
        );
    end component;

    -- Signals for the UUT inputs and outputs
    signal clk           : std_logic := '0';
    signal rst_n         : std_logic := '1';
    signal we            : std_logic := '1';
    signal collision_hit : std_logic := '0';

    signal winner        : std_logic;
    signal score         : integer := 0;

    -- Signals for tank_control and tank_location
    signal tank_curr_pos_in  : position := (0, 0);
    signal tank_next_pos_out : position := (0, 0);
    signal tank_display      : std_logic := '0';
    signal tank_speed_in     : std_logic_vector(2 downto 0) := "001";
    signal tank_speed_out    : std_logic_vector(2 downto 0) := "001";
    signal tank_winner       : std_logic := '0';

    -- Clock period constant
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the game_winner component
    game_winner_inst: entity work.game_winner
        port map(
            clk           => clk,
            rst_n         => rst_n,
            we            => we,
            winner        => tank_winner,
            score         => score,
            collision_hit => collision_hit
        );

    -- Instantiate the tank_control component
    tank_control_inst: entity work.tank_control
        port map(
            clk                 => clk,
            rst_n               => rst_n,
            we                  => we,
            tank_curr_pos_in    => tank_curr_pos_in,
            tank_next_pos_out   => tank_next_pos_out,
            tank_display        => tank_display,
            tank_speed_in       => tank_speed_in,
            winner              => tank_winner
        );

    -- Instantiate the tank_location component
    tank_location_inst: entity work.tank_location
        generic map(
            tank_loc => (100, 300)
        )
        port map(
            clk          => clk,
            rst_n        => rst_n,
            tank_pos_in  => tank_next_pos_out,
            tank_pos_out => tank_curr_pos_in,
            speed_in     => tank_speed_out,
            speed_out    => tank_speed_in
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

    -- Test stimulus process
    stim_proc: process
    begin
        -- Apply reset
        rst_n <= '0';
        wait for clk_period;
        rst_n <= '1';
        wait for clk_period * 2;
		  rst_n <= '0';
        wait for clk_period;

        -- Test Case 1: No collision (Score should remain 0)
        collision_hit <= '0';
        wait for clk_period * 4;

        -- Test Case 2: Single collision detected
        collision_hit <= '1';
        wait for clk_period;
        collision_hit <= '0';
        wait for clk_period * 4;

        -- Test Case 3: Multiple collisions to reach win state
        collision_hit <= '1';
        wait for clk_period;
        collision_hit <= '0';
        wait for clk_period * 4;

        collision_hit <= '1';
        wait for clk_period;
        collision_hit <= '0';
        wait for clk_period * 4;

        -- Verify winner signal is asserted
        wait for clk_period * 4;

        -- Test Case 4: Interact with tank_control
        --tank_curr_pos_in <= (50, 60); -- Simulate tank position movement
        wait for clk_period * 10;

        -- End simulation
        wait;
    end process;

end architecture test;

