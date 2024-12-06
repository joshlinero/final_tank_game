library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity collision_tb is
end collision_tb;

architecture test of collision_tb is
    -- Clock and reset signals
    signal clk, reset : std_logic := '0';
    signal global_we : std_logic := '1';
    
    -- Signals for tank 2
    signal tank_2_curr_pos, tank_2_next_pos : position := (0, 0);
    signal tank_2_curr_speed, tank_2_next_speed : std_logic_vector(2 downto 0) := "001";
    signal tank_2_disp_flag : std_logic := '0';
    signal tank_2_speed1_key, tank_2_speed2_key, tank_2_speed3_key : std_logic := '0';
    signal tank_2_fire_key : std_logic := '0';
    signal tank_2_bul_curr_pos, tank_2_bul_next_pos : position := (0, 0);
    signal tank_2_bul_curr_fire, tank_2_bul_next_fire : std_logic := '0';
    signal tank_2_bul_disp_flag : std_logic := '0';
	 signal tank_2_bul_dir : std_logic := '1';

    -- Signals for tank 1 (to test collision)
    signal tank_1_curr_pos : position := (310, 130);
    signal tank_1_wins : std_logic := '0';

    -- Signals for collision
    signal collision_2_hit : std_logic := '0';

    -- Clock period constant
    constant clk_period : time := 10 ns;

begin
    -- Instantiate tank_control for tank 2
    tank_2_control_inst : entity work.tank_control
        port map (
            clk => clk,
            rst_n => reset,
            we => global_we,
            tank_curr_pos_in => tank_2_curr_pos,
            tank_next_pos_out => tank_2_next_pos,
            tank_display => tank_2_disp_flag,
            tank_speed_in => tank_2_curr_speed,
            winner => tank_1_wins
        );

    -- Instantiate tank_location for tank 2
    tank_2_location_inst : entity work.tank_location
        generic map (
            tank_loc => TANK_2_INIT_POS
        )
        port map (
            clk => clk,
            rst_n => reset,
            tank_pos_in => tank_2_next_pos,
            tank_pos_out => tank_2_curr_pos,
            speed_in => tank_2_next_speed,
            speed_out => tank_2_curr_speed
        );

    -- Instantiate speed_control for tank 2
    tank_2_speed_inst : entity work.speed_control
        port map (
            clk => clk,
            rst_n => reset,
            speed1 => tank_2_speed1_key,
            speed2 => tank_2_speed2_key,
            speed3 => tank_2_speed3_key,
            tank_speed_in => tank_2_curr_speed,
            tank_speed_out => tank_2_next_speed
        );

    -- Instantiate bullet_control for tank 2
    bullet_2_control_inst : entity work.bullet_control
        port map (
            clk => clk,
            rst_n => reset,
            we => global_we,
            tank_pos_in => tank_2_curr_pos,
            fire => tank_2_fire_key,
            bullet_pos_in => tank_2_bul_curr_pos,
            bullet_pos_out => tank_2_bul_next_pos,
            bullet_fired_in => tank_2_bul_curr_fire,
            bullet_fired_out => tank_2_bul_next_fire,
            bullet_disp => tank_2_bul_disp_flag,
            direction => tank_2_bul_dir,
            collision_hit => collision_2_hit,
            winner => tank_1_wins
        );

    -- Instantiate bullet_location for tank 2
    bullet_2_location_inst : entity work.bullet_location
        generic map (
            bullet_loc => TANK_2_BULL_INIT_POS
        )
        port map (
            clk => clk,
            rst_n => reset,
            we => global_we,
            bull_pos_in => tank_2_bul_next_pos,
            bull_pos_out => tank_2_bul_curr_pos,
            fired_in => tank_2_bul_next_fire,
            fired_out => tank_2_bul_curr_fire
        );

    -- Instantiate collision detection for tank 2's bullet hitting tank 1
    collision_2_inst : entity work.collision
        port map (
            clk => clk,
            rst_n => reset,
            we => global_we,
            tank_pos_in => tank_1_curr_pos,
            bullet_pos_in => tank_2_bul_curr_pos,
            bullet_fired_in => tank_2_bul_curr_fire,
            collsion_hit => collision_2_hit,
            direction => tank_2_bul_dir
        );

    -- Clock generation process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus_process : process
    begin
        -- Reset system
		  reset <= '1';
        wait for 10 ns;
        reset <= '0';
        wait for 10 ns;
        reset <= '1';
        wait for 10 ns;
		  reset <= '0';
        wait for 10 ns;

        -- Move tank 2 and fire a bullet
        tank_2_speed1_key <= '1';
        wait for 20 ns;
        tank_2_fire_key <= '1';
        wait for 20 ns;
        tank_2_fire_key <= '0';

        -- Move bullet to collide with tank 1
        --tank_2_bul_curr_pos <= (5, 5);
        wait for 100 ns;

        -- Observe collision hit
        wait for 40 ns;

        -- End simulation
        wait;
    end process;

end architecture test;
