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

	signal colorAddress : std_logic_vector (2 downto 0);
	signal color        : std_logic_vector (23 downto 0);

	signal pixel_row_int, pixel_column_int : natural;

begin

--------------------------------------------------------------------------------------------
	
	red_out <= color(23 downto 16);
	green_out <= color(15 downto 8);
	blue_out <= color(7 downto 0);

	pixel_row_int <= to_integer(unsigned(pixel_row));
	pixel_column_int <= to_integer(unsigned(pixel_column));
	
--------------------------------------------------------------------------------------------	
	
	colors : colorROM
		port map(colorAddress, ROM_clk, color);
	
	pll : pll_counter
        port map(clk => clk, rst_n => rst_n, pulse_out => pulse_out);

--------------------------------------------------------------------------------------------	

	pixelDraw : process(clk, rst_n) is
	
	begin
			
		if (rising_edge(clk)) then
		
			if ((pixel_row_int > tank_1_pos(1)) and (pixel_row_int < tank_1_pos(1) + TANK_HIEGHT) and 
				(pixel_column_int > tank_1_pos(0)) and (pixel_column_int < tank_1_pos(0) + TANK_WIDTH)) and (tank_1_display = '1') then
					   colorAddress <= color_red; 
					 
         elsif (pixel_row_int >= tank_1_pos(1) - TANK_GUNH and pixel_row_int <= tank_1_pos(1) and 
					pixel_column_int >= tank_1_pos(0) + (TANK_WIDTH / 2) - (TANK_GUNW / 2) and 
					pixel_column_int <= tank_1_pos(0) + (TANK_WIDTH / 2) + (TANK_GUNW / 2)) and (tank_1_display = '1')  then
						colorAddress <= color_red;
			
			elsif ((pixel_row_int > tank_2_pos(1)) and (pixel_row_int < tank_2_pos(1) + TANK_HIEGHT) and 
				(pixel_column_int > tank_2_pos(0)) and (pixel_column_int < tank_2_pos(0) + TANK_WIDTH)) and (tank_2_display = '1') then
					   colorAddress <= color_blue; 
					 
         elsif (pixel_row_int >= tank_2_pos(1) + TANK_HIEGHT and pixel_row_int <= tank_2_pos(1) + TANK_HIEGHT + TANK_GUNH and 
					pixel_column_int >= tank_2_pos(0) + (TANK_WIDTH / 2) - (TANK_GUNW / 2) and 
					pixel_column_int <= tank_2_pos(0) + (TANK_WIDTH / 2) + (TANK_GUNW / 2)) and (tank_2_display = '1')  then
						colorAddress <= color_blue;
					 
         else
						colorAddress <= color_white;
			end if;
		end if;
	end process pixelDraw;	

--------------------------------------------------------------------------------------------
	
end architecture behavioral;			