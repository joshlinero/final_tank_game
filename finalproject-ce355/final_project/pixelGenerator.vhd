library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;
use WORK.color_constants.all;

entity pixelGenerator is
    port(
        clk, ROM_clk, rst_n, video_on, eof : in std_logic;
        pixel_row, pixel_column            : in std_logic_vector(9 downto 0);
        red_out, green_out, blue_out       : out std_logic_vector(7 downto 0);
        keyboard_clk, keyboard_data        : in std_logic
    );
end entity pixelGenerator;

architecture behavioral of pixelGenerator is

    -- Tank control signals
    signal x_start        : natural := (320 - (TANK_WIDTH / 2));
    signal y_start        : natural := (470 - TANK_HIEGHT);
	 signal x_bullet       : natural := 320;
    signal y_bullet       : natural := (470 - TANK_HIEGHT - TANK_GUNH);
	 
    signal direction      : std_logic := '1';
    signal pulse_out      : std_logic;
    signal tank_color     : std_logic_vector(2 downto 0) := color_red;
    signal colorAddress   : std_logic_vector(2 downto 0);
    signal speed          : std_logic_vector(2 downto 0);

    -- Signals for PS2 component
    signal ps2_scan_code  : std_logic_vector(7 downto 0);
    signal ps2_scan_ready : std_logic;
    signal history0, history1, history2, history3 : std_logic_vector(7 downto 0);

    -- Color ROM output
    signal color          : std_logic_vector(23 downto 0);

    -- Integer conversion of pixel positions
    signal pixel_row_int, pixel_column_int : natural;

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

    component tank_bullet_shape is
        port(
			  pixel_row      : in natural;
			  pixel_column   : in natural;
			  x_start        : in natural;
			  y_start        : in natural;
			  x_bullet       : in natural;
			  y_bullet       : in natural;
			  tank_color     : in std_logic_vector(2 downto 0);
			  bullet         : in std_logic;
			  colorAddress   : out std_logic_vector(2 downto 0)
		 );
    end component tank_bullet_shape;

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

    component tank_speed is
        port(
            keyboard_clk : in std_logic;
            keyboard_data : in std_logic;
            clk : in std_logic;
            rst_n : in std_logic;
            speed : out std_logic_vector(2 downto 0)
        );
    end component tank_speed;
	 
	 component bullet_mover is
        port(
            clk       : in std_logic;
            rst_n     : in std_logic;
            pulse_out : in std_logic;
				fire_bullet : in std_logic;
            y_bullet   : inout natural;
            bullet     : out std_logic
        );
    end component bullet_mover;
	 
-- Add the fire_bullet component declaration
	component fire_bullet is
		 port(
			  keyboard_clk : in std_logic;
           keyboard_data : in std_logic;
			  clk : in std_logic;
			  reset : in std_logic;
			  fire_bullet : out std_logic
		 );
	end component fire_bullet;
	
	-- Add this signal for the fire_bullet output
	signal fire_bullet_signal : std_logic;
	signal bullet : std_logic;
begin

    -- Output pixel colors
    red_out <= color(23 downto 16);
    green_out <= color(15 downto 8);
    blue_out <= color(7 downto 0);

    -- Convert pixel positions to integers
    pixel_row_int <= to_integer(unsigned(pixel_row));
    pixel_column_int <= to_integer(unsigned(pixel_column));
	 
    x_bullet <= x_start + (TANK_WIDTH / 2);

    -- PLL Counter
    pll : pll_counter
        port map(clk => clk, rst_n => rst_n, pulse_out => pulse_out);

    -- Color ROM
    colors : colorROM
        port map(address => colorAddress, clock => ROM_clk, q => color);

    -- Tank Mover
    mover_inst : tank_mover
        port map(
            clk       => clk,
            rst_n     => rst_n,
            pulse_out => pulse_out,
            speed     => speed, -- Controlled by tank_controller
            x_start   => x_start,
            direction => direction
        );

    -- Tank Shape and Bullet Shape
    shape_inst : tank_bullet_shape
        port map(
            pixel_row    => pixel_row_int,
            pixel_column => pixel_column_int,
            x_start      => x_start,
            y_start      => y_start,
				x_bullet     => x_bullet,
				y_bullet     => y_bullet,
            tank_color   => tank_color,
				bullet       => bullet,
            colorAddress => colorAddress
        );

    -- Bullet Mover
    mover_inst2 : bullet_mover
        port map(
            clk       => clk,
            rst_n     => rst_n,
            pulse_out => pulse_out,
            fire_bullet => fire_bullet_signal, -- Triggered by fire_bullet module
            y_bullet   => y_bullet,
            bullet     => bullet
        );


    -- PS2 Keyboard
    u_ps2 : ps2
        port map(
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

    -- Fire Bullet Logic
    fire_bullet_inst : fire_bullet
        port map(
		      keyboard_clk => keyboard_clk,
				keyboard_data => keyboard_data,
            clk => clk,
            reset => rst_n,
            fire_bullet => fire_bullet_signal -- Output signal for firing
        );

    -- Tank Controller
    speed_ctrl : tank_speed
        port map(
            keyboard_clk => keyboard_clk,
            keyboard_data => keyboard_data,
            clk => clk,
            rst_n => rst_n,
            speed => speed -- Output speed signal for tank movement
        );

end architecture behavioral;

