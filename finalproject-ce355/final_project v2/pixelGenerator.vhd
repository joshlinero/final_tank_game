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
			tank_1_disp 								: in std_logic;
			tank_1_bul_pos							:	in	position;
			tank_1_bul_disp_flag					:	in std_logic;
			
			tank_2_pos 										: in position;
			tank_2_disp 								: in std_logic;
			tank_2_bul_pos							:	in	position;
			tank_2_bul_disp_flag					:	in std_logic
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
	

	-- Pixel drawing process
	pixelDraw : process(clk, rst_n)
    begin
        if rising_edge(clk) then
            if ((pixel_row_int > tank_1_pos(1)) and 
                (pixel_row_int < tank_1_pos(1) + TANK_HEIGHT) and
                (pixel_column_int > tank_1_pos(0)) and 
                (pixel_column_int < tank_1_pos(0) + TANK_WIDTH) and
                (tank_1_disp = '1')) then
                colorAddress <= color_red; 
            elsif ((pixel_row_int >= tank_1_pos(1) - TANK_GUNH) and 
                   (pixel_row_int <= tank_1_pos(1)) and
                   (pixel_column_int >= tank_1_pos(0) + (TANK_WIDTH / 2) - (TANK_GUNW / 2)) and 
                   (pixel_column_int <= tank_1_pos(0) + (TANK_WIDTH / 2) + (TANK_GUNW / 2)) and 
                   (tank_1_disp = '1')) then
                colorAddress <= color_red;

            elsif ((pixel_row_int > tank_2_pos(1)) and 
                   (pixel_row_int < tank_2_pos(1) + TANK_HEIGHT) and
                   (pixel_column_int > tank_2_pos(0)) and 
                   (pixel_column_int < tank_2_pos(0) + TANK_WIDTH) and
                   (tank_2_disp = '1')) then
                colorAddress <= color_blue; 
            elsif ((pixel_row_int >= tank_2_pos(1) + TANK_HEIGHT) and 
                   (pixel_row_int <= tank_2_pos(1) + TANK_HEIGHT + TANK_GUNH) and
                   (pixel_column_int >= tank_2_pos(0) + (TANK_WIDTH / 2) - (TANK_GUNW / 2)) and 
                   (pixel_column_int <= tank_2_pos(0) + (TANK_WIDTH / 2) + (TANK_GUNW / 2)) and 
                   (tank_2_disp = '1')) then
                colorAddress <= color_blue;
            else
                colorAddress <= color_white;
            end if;
				if ((tank_2_bul_pos(0)) < pixel_column_int and pixel_column_int < (tank_2_bul_pos(0) + BULLET_W) and
						(tank_2_bul_pos(1)) < pixel_row_int and pixel_row_int < (tank_2_bul_pos(1) + BULLET_H) and 
						tank_2_bul_disp_flag = '1') then
					   colorAddress <= color_green;
				elsif ((tank_1_bul_pos(0)) < pixel_column_int and pixel_column_int < (tank_1_bul_pos(0) + BULLET_W) and
						(tank_1_bul_pos(1)) < pixel_row_int and pixel_row_int < (tank_1_bul_pos(1) + BULLET_H) and
						tank_1_bul_disp_flag = '1') then
					   colorAddress <= color_yellow;
				end if;
						
				  end if;
		 end process;

end architecture behavioral;	