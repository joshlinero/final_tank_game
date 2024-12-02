library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;
use WORK.color_constants.all;

entity pixelGenerator is
	port(
			clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
			pixel_row, pixel_column						    : in std_logic_vector(9 downto 0);
			red_out, green_out, blue_out					: out std_logic_vector(7 downto 0)
		);
end entity pixelGenerator;

architecture behavioral of pixelGenerator is


    -- Tank control signals
    signal x_start        : natural := (320 - (TANK_WIDTH / 2));
    signal y_start        : natural := (470 - TANK_HIEGHT);
    signal direction      : std_logic := '1';
    signal pulse_out      : std_logic;
    signal tank_color     : std_logic_vector(2 downto 0) := color_red;
    signal colorAddress   : std_logic_vector(2 downto 0);
	 signal speed          : std_logic_vector(2 downto 0) := "001";
	 
	 component colorROM is
		port
		(
			address		: in std_logic_vector (2 downto 0);
			clock		: in std_logic  := '1';
			q			: out std_logic_vector (23 downto 0)
		);
	 end component colorROM;

    signal color        : std_logic_vector (23 downto 0);

    signal pixel_row_int, pixel_column_int : natural;
	 
	 component pll_counter is
        port(
            clk       : in std_logic;
            rst_n     : in std_logic;
            pulse_out : out std_logic
        );
    end component pll_counter;

    -- Component declarations
    component tank_mover is
        port(
            clk       : in std_logic;
            rst_n     : in std_logic;
            pulse_out : in std_logic;
            speed     : in std_logic_vector(2 downto 0);
            x_start   : inout natural;
            direction : inout std_logic
        );
    end component tank_mover;

    component tank_shape is
        port(
            pixel_row      : in natural;
            pixel_column   : in natural;
            x_start        : in natural;
            y_start        : in natural;
            tank_color     : in std_logic_vector(2 downto 0);
            colorAddress   : out std_logic_vector(2 downto 0)
        );
    end component tank_shape;

begin

	red_out <= color(23 downto 16);
	green_out <= color(15 downto 8);
	blue_out <= color(7 downto 0);

	pixel_row_int <= to_integer(unsigned(pixel_row));
	pixel_column_int <= to_integer(unsigned(pixel_column));
	
	pll : pll_counter
	 port map(clk, rst_n, pulse_out);
	
	colors : colorROM
		port map(colorAddress, ROM_clk, color);
		
    -- Instantiate the tank_mover
    mover_inst : tank_mover
        port map(
            clk       => clk,
            rst_n     => rst_n,
            pulse_out => pulse_out,
            speed     => speed, -- Adjust speed as needed
            x_start   => x_start,
            direction => direction
        );

    -- Instantiate the tank_shape
    shape_inst : tank_shape
        port map(
            pixel_row    => to_integer(unsigned(pixel_row)),
            pixel_column => to_integer(unsigned(pixel_column)),
            x_start      => x_start,
            y_start      => y_start,
            tank_color   => tank_color,
            colorAddress => colorAddress
        );

end architecture behavioral;