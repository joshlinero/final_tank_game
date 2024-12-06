library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity bullet_control_tb is
end entity;

architecture behavior of bullet_control_tb is

    -- Component declaration for the Unit Under Test (UUT)
    component bullet_control
        port(
            clk              : in std_logic;
            rst_n            : in std_logic;
            we               : in std_logic;
            tank_pos_in      : in position;
            fire             : in std_logic;
            bullet_pos_in    : in position;
            bullet_pos_out   : out position;
            bullet_fired_in  : in std_logic;
            bullet_fired_out : out std_logic;
            bullet_disp      : out std_logic;
            direction        : in std_logic
        );
    end component;
    
    component bullet_location
        generic(
            bullet_loc : position
        );
        port(
            clk              : in std_logic;
            rst_n            : in std_logic;
            we               : in std_logic;
            bull_pos_in      : in position;
            bull_pos_out     : out position;
            fired_in         : in std_logic;
            fired_out        : out std_logic
        );
    end component;

    -- Signals for inputs to the UUT
    signal clk              : std_logic := '0';
    signal rst_n            : std_logic := '1';
    signal we               : std_logic := '0';
    signal tank_pos_in      : position := (0, 0);
    signal fire             : std_logic := '0';
    signal bullet_fired_in  : std_logic := '0';
    signal direction        : std_logic := '0';

    -- Signals for outputs from the UUT
    signal bullet_pos_out   : position;
    signal bullet_fired_out : std_logic;
    signal bullet_disp      : std_logic;

    -- Signals for bullet_location component
    signal tank_1_bul_next_pos  : position := (0, 0);
    signal tank_1_bul_curr_pos  : position; -- Now only driven by bullet_location
    signal tank_1_bul_next_fire : std_logic := '0';
    signal tank_1_bul_curr_fire : std_logic;
    constant init_pos : position := (0, 0);

    -- Clock generation process
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the bullet_control component
    bullet_control_inst: bullet_control
        port map (
            clk              => clk,
            rst_n            => rst_n,
            we               => we,
            tank_pos_in      => tank_pos_in,
            fire             => fire,
            bullet_pos_in    => tank_1_bul_curr_pos, -- Bullet position from bullet_location
            bullet_pos_out   => tank_1_bul_next_pos, -- Bullet position to bullet_location
            bullet_fired_in  => tank_1_bul_curr_fire, -- Bullet fired status from bullet_location
            bullet_fired_out => tank_1_bul_next_fire, -- Bullet fired status to bullet_location
            bullet_disp      => bullet_disp,
            direction        => direction
        );

    -- Instantiate the bullet_location component
    bullet_location_inst: bullet_location
        generic map(
            bullet_loc => init_pos
        )
        port map(
            clk        => clk,
            rst_n      => rst_n,
            we         => we,
            bull_pos_in  => tank_1_bul_next_pos, -- Updated position from bullet_control
            bull_pos_out => tank_1_bul_curr_pos, -- Current position for bullet_control
            fired_in    => tank_1_bul_next_fire, -- Fired status from bullet_control
            fired_out   => tank_1_bul_curr_fire  -- Current fired status for bullet_control
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
        rst_n <= '1';
        wait for clk_period * 2;
        rst_n <= '0';
        wait for clk_period * 2;
        rst_n <= '1';
		  wait for clk_period * 2;

        -- Test case 1: Fire bullet upwards
        fire <= '1';
        tank_pos_in <= (100, 300);
        direction <= '0'; -- Upwards
        wait for clk_period * 2;
        fire <= '0';
        wait for clk_period * 10;

        -- Test case 2: Bullet reaches boundary
        we <= '1';
        wait for clk_period;
        we <= '0';
        wait for clk_period * 10;

        -- Test case 3: Fire bullet downwards
        fire <= '1';
        tank_pos_in <= (200, 150);
        direction <= '1'; -- Downwards
        wait for clk_period;
        fire <= '0';
        wait for clk_period * 10;

        -- Test case 4: Reset
        rst_n <= '0';
        wait for clk_period * 2;
        rst_n <= '1';
        wait for clk_period * 10;

        -- End simulation
        wait;
    end process;

end architecture behavior;
