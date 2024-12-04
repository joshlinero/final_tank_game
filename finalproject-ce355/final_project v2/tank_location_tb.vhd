library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity tank_location_tb is
end entity tank_location_tb;

architecture sim of tank_location_tb is
    -- Component declaration
    component tank_location is
        generic(
            tank_loc : position
        );
        port(
            clk, rst_n, we : in std_logic;
            tank_pos_in    : in position;
            tank_pos_out   : out position;
            speed_in       : in integer;
            speed_out      : out integer
        );
    end component;

    -- Signal declarations
    signal clk, rst_n, we : std_logic := '0';
    signal tank_pos_in, tank_pos_out : position;
    signal speed_in, speed_out : integer;

    -- Constants
    constant CLK_PERIOD : time := 10 ns;
    constant TANK_INITIAL_POS : position := (50, 50);

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: tank_location
        generic map (
            tank_loc => TANK_INITIAL_POS
        )
        port map (
            clk => clk,
            rst_n => rst_n,
            we => we,
            tank_pos_in => tank_pos_in,
            tank_pos_out => tank_pos_out,
            speed_in => speed_in,
            speed_out => speed_out
        );

    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize inputs
        rst_n <= '1';
        we <= '0';
        tank_pos_in <= (0, 0);
        speed_in <= 0;
        wait for CLK_PERIOD * 2;

        -- Release reset
        rst_n <= '0';
        wait for CLK_PERIOD * 2;

        -- Test case 1: Write new position and speed
        we <= '1';
        tank_pos_in <= (100, 100);
        speed_in <= SPEED_FAST;
        wait for CLK_PERIOD;
        we <= '0';
        wait for CLK_PERIOD;

        -- Check output
        assert tank_pos_out = (100, 100) report "Test case 1 failed: Incorrect position" severity error;
        assert speed_out = SPEED_FAST report "Test case 1 failed: Incorrect speed" severity error;

        -- Test case 2: Change position without write enable
        tank_pos_in <= (200, 200);
        speed_in <= SPEED_SLOW;
        wait for CLK_PERIOD * 2;

        -- Check output (should be unchanged)
        assert tank_pos_out = (100, 100) report "Test case 2 failed: Position changed without write enable" severity error;
        assert speed_out = SPEED_FAST report "Test case 2 failed: Speed changed without write enable" severity error;

        -- Test case 3: Reset
        rst_n <= '1';
        wait for CLK_PERIOD * 2;
        rst_n <= '0';
        wait for CLK_PERIOD;

        -- Check output (should be initial position and SPEED_SLOW)
        assert tank_pos_out = TANK_INITIAL_POS report "Test case 3 failed: Incorrect reset position" severity error;
        assert speed_out = SPEED_SLOW report "Test case 3 failed: Incorrect reset speed" severity error;

        -- End simulation
        wait;
    end process;

end architecture sim;