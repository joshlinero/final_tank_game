library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;

entity pixelGenerator is
	port(
			clk, ROM_clk, rst_n, video_on, eof 				: in std_logic;
			pixel_row, pixel_column						    : in std_logic_vector(9 downto 0);
			red_out, green_out, blue_out					: out std_logic_vector(7 downto 0);
			keyboard_clk, keyboard_data           : in std_logic
		);
end entity pixelGenerator;

architecture behavioral of pixelGenerator is

    constant color_red    : std_logic_vector(2 downto 0) := TANK_1_COLOR;
    constant color_green  : std_logic_vector(2 downto 0) := "001";
    constant color_blue   : std_logic_vector(2 downto 0) := "010";
    constant color_yellow : std_logic_vector(2 downto 0) := "011";
    constant color_magenta: std_logic_vector(2 downto 0) := "100";
    constant color_cyan   : std_logic_vector(2 downto 0) := "101";
    constant color_black  : std_logic_vector(2 downto 0) := "110";
    constant color_white  : std_logic_vector(2 downto 0) := "111";

    -- Named constants for speed levels
    constant SPEED_SLOW   : std_logic_vector(2 downto 0) := "001";
    constant SPEED_MEDIUM : std_logic_vector(2 downto 0) := "010";
    constant SPEED_FAST   : std_logic_vector(2 downto 0) := "100";

    -- Signals for PS2 component
    signal ps2_scan_code  : std_logic_vector(7 downto 0);
    signal ps2_scan_ready : std_logic;
    signal history0, history1, history2, history3 : std_logic_vector(7 downto 0);

    -- Tank control signals
    signal colorAddress   : std_logic_vector (2 downto 0);
    signal color          : std_logic_vector (23 downto 0);
    signal pixel_row_int, pixel_column_int : natural;
    signal x_start        : natural := (320 - (TANK_WIDTH / 2));
    signal y_start        : natural := (470 - TANK_HIEGHT);
    signal pulse_out      : std_logic;
    signal direction      : std_logic := '1';
    signal speed          : std_logic_vector(2 downto 0) := SPEED_SLOW;
	 	

    -- Component declarations
    component colorROM is
        port(
            address : in std_logic_vector(2 downto 0);
            clock   : in std_logic := '1';
            q       : out std_logic_vector(23 downto 0)
        );
    end component colorROM;

    component pll_counter is
        port(
            clk       : in std_logic;
            rst_n     : in std_logic;
            pulse_out : out std_logic
        );
    end component pll_counter;

    component ps2 is
        port(
            keyboard_clk, keyboard_data, clock_50MHz,
            reset : in std_logic;
            scan_code : out std_logic_vector(7 downto 0);
            scan_readyo : out std_logic;
            hist3 : out std_logic_vector(7 downto 0);
            hist2 : out std_logic_vector(7 downto 0);
            hist1 : out std_logic_vector(7 downto 0);
            hist0 : out std_logic_vector(7 downto 0)
        );
    end component ps2;

begin

    --------------------------------------------------------------------------------------------
	 red_out <= color(23 downto 16);
    green_out <= color(15 downto 8);
    blue_out <= color(7 downto 0);
	 
	 colors : colorROM
		port map(colorAddress, ROM_clk, color);
		
	pixel_row_int <= to_integer(signed(pixel_row));
	pixel_column_int <= to_integer(signed(pixel_column));
	 
    -- PS2 Instantiation
    u_ps2: ps2 port map(
        keyboard_clk => keyboard_clk,
        keyboard_data => keyboard_data,
        clock_50MHz => clk,
        reset => rst_n,
        scan_code => ps2_scan_code,
        scan_readyo => ps2_scan_ready,
        hist3 => history3,
        hist2 => history2,
        hist1 => history1,
        hist0 => history0
    );
	 
	 pll : pll_counter
	  port map(clk, rst_n, pulse_out);

    -- Speed control process
   speed_tank : process(clk, rst_n, ps2_scan_ready)
	begin
		 if rst_n = '0' then
			  speed <= SPEED_SLOW; -- Reset speed to the slowest setting
		 elsif rising_edge(clk) then
			  if ps2_scan_ready = '1' then
					case ps2_scan_code is
						 when "00011100" =>  -- Key 'A' (Decrease speed)
							  if speed = SPEED_MEDIUM then
									speed <= SPEED_SLOW;
							  elsif speed = SPEED_FAST then
									speed <= SPEED_MEDIUM;
							  else
									speed <= SPEED_SLOW; -- Keep at slowest speed
							  end if;
						 when "00100011" =>  -- Key 'D' (Increase speed)
							  if speed = SPEED_SLOW then
									speed <= SPEED_MEDIUM;
							  elsif speed = SPEED_MEDIUM then
									speed <= SPEED_FAST;
							  else
									speed <= SPEED_FAST; -- Keep at fastest speed
							  end if;
						 when others =>
							  speed <= SPEED_SLOW; -- Default case for robustness
					end case;
			  else
					speed <= speed; -- No scan_ready, retain the current speed
			  end if;
		 end if;
	end process speed_tank;


    --------------------------------------------------------------------------------------------
    -- Tank movement process
   move_tank : process(clk, rst_n, pulse_out, x_start, direction)
	begin
		 if rst_n = '0' then
			  x_start <= (320 - (TANK_WIDTH / 2)); -- Reset x_start
			  direction <= '1';
		 elsif rising_edge(clk) then
			  -- Default assignment to prevent latches
			  x_start <= x_start;
			  direction <= direction;
			  if pulse_out = '1' then
					if direction = '1' then
						 if (x_start + TANK_WIDTH >= 640 and x_start + TANK_WIDTH < 680) then -- Hit right boundary
							  direction <= '0'; -- Reverse to left
						 else
							  x_start <= x_start + to_integer(unsigned(speed));
						 end if;
					else
						 if (x_start <= 0 or x_start >= 680) then -- Hit left boundary
							  --x_start <= 0;
							  direction <= '1'; -- Reverse to right
						 else
							  x_start <= x_start - to_integer(unsigned(speed));
						 end if;
					end if;
			  end if;
		 end if;
	end process move_tank;


    --------------------------------------------------------------------------------------------
    -- Pixel drawing process
   pixelDraw : process(clk, rst_n)
	begin
		 if rst_n = '0' then
			  colorAddress <= color_white; -- Default color
		 elsif rising_edge(clk) then
			  -- Default assignment to prevent latches
			  colorAddress <= color_white;
			  if (pixel_row_int > y_start and pixel_row_int < y_start + TANK_HIEGHT and 
					pixel_column_int > x_start and pixel_column_int < x_start + TANK_WIDTH) then
					colorAddress <= color_red;
			  end if;
		 end if;
	end process pixelDraw;


end architecture behavioral;
