library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity pixelGenerator is
	port(
			clk, ROM_clk, rst_n, video_on, eof 		: in std_logic;
			pixel_row, pixel_column						: in std_logic_vector(9 downto 0);
			red_out, green_out, blue_out				: out std_logic_vector(7 downto 0);
			
			tank_1_pos 										: in position;
			tank_1_display 								: in std_logic;
			tank_2_pos 										: in position;
			tank_2_display 								: in std_logic
		);
		
end entity pixelGenerator;

architecture behavioral of pixelGenerator is
	
	-- Component declarations
	component colorROM is
		port(
			address		: in std_logic_vector (2 downto 0);
			clock		: in std_logic  := '1';
			q			: out std_logic_vector (23 downto 0)
		);
	end component colorROM;
	
	component pll_counter is
        port(
            clk       : in std_logic;
            rst_n     : in std_logic;
            pulse_out : out std_logic
        );
	end component pll_counter;
	
	component game_update_logic is
        port(
            clk, rst_n, global_write_enable : in std_logic;
            pulse_out : in std_logic;

            -- Tank attribute inputs
            tank_1_pos_in, tank_2_pos_in : in position;

            -- Tank attribute outputs
            tank_1_pos_out, tank_2_pos_out : out position;
            tank_1_display, tank_2_display : out std_logic
        );
	end component game_update_logic;

	-- Signal declarations
	signal tank_1_pos_out_internal, tank_2_pos_out_internal : position := (others => 0);
	signal tank_1_display_internal, tank_2_display_internal : std_logic := '0';

	signal pulse_out_internal : std_logic;

	-- Control signals
	signal global_write_enable : std_logic := '1';

	-- Color-related signals
	signal colorAddress : std_logic_vector (2 downto 0) := (others => '0');
	signal color        : std_logic_vector (23 downto 0) := (others => '0');

	-- Pixel coordinate conversions
	signal pixel_row_int, pixel_column_int : natural;

begin

	-- Output color mapping
	red_out <= color(23 downto 16);
	green_out <= color(15 downto 8);
	blue_out <= color(7 downto 0);

	-- Convert pixel coordinates
	pixel_row_int <= to_integer(unsigned(pixel_row));
	pixel_column_int <= to_integer(unsigned(pixel_column));
	
	-- Color ROM instance
	colors : colorROM
		port map(
			address => colorAddress,
			clock => ROM_clk,
			q => color
		);
	
	-- PLL counter instance
	pll : pll_counter
        port map(
			clk => clk,
			rst_n => rst_n,
			pulse_out => pulse_out_internal
		);
		  
	-- Game update logic instance
	game_update_inst : game_update_logic
        port map(
            clk => clk,
            rst_n => rst_n,
            global_write_enable => global_write_enable,
            pulse_out => pulse_out_internal,
            tank_1_pos_in => tank_1_pos,  -- External input
			tank_2_pos_in => tank_2_pos,  -- External input
            tank_1_pos_out => tank_1_pos_out_internal,
            tank_2_pos_out => tank_2_pos_out_internal,
            tank_1_display => tank_1_display_internal,
            tank_2_display => tank_2_display_internal
        );

	-- Pixel drawing process
	pixelDraw : process(clk, rst_n)
    begin
        if rising_edge(clk) then
            if ((pixel_row_int > tank_1_pos_out_internal(1)) and 
                (pixel_row_int < tank_1_pos_out_internal(1) + TANK_HEIGHT) and
                (pixel_column_int > tank_1_pos_out_internal(0)) and 
                (pixel_column_int < tank_1_pos_out_internal(0) + TANK_WIDTH) and
                (tank_1_display_internal = '1')) then
                colorAddress <= color_red; 
            elsif ((pixel_row_int >= tank_1_pos_out_internal(1) - TANK_GUNH) and 
                   (pixel_row_int <= tank_1_pos_out_internal(1)) and
                   (pixel_column_int >= tank_1_pos_out_internal(0) + (TANK_WIDTH / 2) - (TANK_GUNW / 2)) and 
                   (pixel_column_int <= tank_1_pos_out_internal(0) + (TANK_WIDTH / 2) + (TANK_GUNW / 2)) and 
                   (tank_1_display_internal = '1')) then
                colorAddress <= color_red;

            elsif ((pixel_row_int > tank_2_pos_out_internal(1)) and 
                   (pixel_row_int < tank_2_pos_out_internal(1) + TANK_HEIGHT) and
                   (pixel_column_int > tank_2_pos_out_internal(0)) and 
                   (pixel_column_int < tank_2_pos_out_internal(0) + TANK_WIDTH) and
                   (tank_2_display_internal = '1')) then
                colorAddress <= color_blue; 
            elsif ((pixel_row_int >= tank_2_pos_out_internal(1) + TANK_HEIGHT) and 
                   (pixel_row_int <= tank_2_pos_out_internal(1) + TANK_HEIGHT + TANK_GUNH) and
                   (pixel_column_int >= tank_2_pos_out_internal(0) + (TANK_WIDTH / 2) - (TANK_GUNW / 2)) and 
                   (pixel_column_int <= tank_2_pos_out_internal(0) + (TANK_WIDTH / 2) + (TANK_GUNW / 2)) and 
                   (tank_2_display_internal = '1')) then
                colorAddress <= color_blue;
            else
                colorAddress <= color_white;
            end if;
        end if;
    end process;

end architecture behavioral;
