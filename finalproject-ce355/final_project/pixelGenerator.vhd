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

	 signal tank_number        : std_logic;  

    -- Tank 1 signals
	 signal x_start1           : natural := (320 - (TANK_WIDTH / 2));
	 signal y_start1				: natural := (470 - TANK_HIEGHT);
	 signal x_bullet1          : natural;
    signal y_bullet1          : natural;
	 signal direction1         : std_logic := '1';
	 signal colorAddress_tank1 : std_logic_vector(2 downto 0);
	 signal tank_color1        : std_logic_vector(2 downto 0) := TANK_1_COLOR;
	 signal speed1             : std_logic_vector(2 downto 0);
	 signal fire_bullet_signal1: std_logic;
	 signal bullet1            : std_logic;
	
	 -- Tank 2 signals
	 signal x_start2				: natural := (320 + (TANK_WIDTH / 2));
	 signal y_start2				: natural := (30 - TANK_HIEGHT);
	 signal x_bullet2          : natural;
    signal y_bullet2          : natural;
	 signal direction2         : std_logic := '0';
	 signal colorAddress_tank2 : std_logic_vector(2 downto 0);
	 signal tank_color2        : std_logic_vector(2 downto 0) := TANK_2_COLOR;
	 signal speed2              : std_logic_vector(2 downto 0);
	 signal fire_bullet_signal2: std_logic;
	 signal bullet2            : std_logic;
		 
    signal pulse_out      : std_logic;

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
		     tank_number    : in std_logic;
			  pixel_row      : in natural;
			  pixel_column   : in natural;
			  x_start        : in natural;
			  y_start        : in natural;
			  x_bullet       : in natural;
			  y_bullet       : in natural;
			  tank_color     : in std_logic_vector(2 downto 0);
			  bullet         : in std_logic;
			  fire_bullet : in std_logic;
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
            speed : out std_logic_vector(2 downto 0);
				bullet : in std_logic;
				fire_bullet : out std_logic
        );
    end component tank_speed;
	 
	 component bullet_mover is
        port(
            clk       : in std_logic;
            rst_n     : in std_logic;
            pulse_out : in std_logic;
				fire_bullet : in std_logic;
            y_bullet   : inout natural;
				x_start     : in natural;
		      x_bullet    : out natural;
            bullet     : out std_logic
        );
    end component bullet_mover;
	 

begin

    -- Output pixel colors
    red_out <= color(23 downto 16);
    green_out <= color(15 downto 8);
    blue_out <= color(7 downto 0);

    -- Convert pixel positions to integers
    pixel_row_int <= to_integer(unsigned(pixel_row));
    pixel_column_int <= to_integer(unsigned(pixel_column));

    -- PLL Counter
    pll : pll_counter
        port map(clk => clk, rst_n => rst_n, pulse_out => pulse_out);

    -- Color ROM
    colors : colorROM
        port map(address => colorAddress_tank1, clock => ROM_clk, q => color);

    -- Tank Mover
    -- Tank 1 mover
	  mover_tank1 : tank_mover
		  port map(
			clk       => clk,
			rst_n     => rst_n,
			pulse_out => pulse_out,
			speed     => speed1, -- Could be independent if needed
			x_start   => x_start1,
			direction => direction1
		);

	  -- Tank 2 mover
		mover_tank2 : tank_mover
		  port map(
          clk       => clk,
          rst_n     => rst_n,
          pulse_out => pulse_out,
          speed     => speed2, -- Could be independent if needed
          x_start   => x_start2,
          direction => direction2
        );

    -- Tank Shape and Bullet Shape
    -- Tank 1 shape and bullet
	shape_tank1 : tank_bullet_shape
		port map(
		  tank_number  => '0',	
        pixel_row    => pixel_row_int,
        pixel_column => pixel_column_int,
        x_start      => x_start1,
        y_start      => y_start1,
        x_bullet     => x_bullet1, 
        y_bullet     => y_bullet1, 
        tank_color   => tank_color1,
        bullet       => bullet1, 
        fire_bullet  => fire_bullet_signal1, 
        colorAddress => colorAddress_tank1
    );

	-- Tank 2 shape and bullet
	shape_tank2 : tank_bullet_shape
		port map(
		  tank_number  => '1',	 
        pixel_row    => pixel_row_int,
        pixel_column => pixel_column_int,
        x_start      => x_start2,
        y_start      => y_start2,
        x_bullet     => x_bullet2, 
        y_bullet     => y_bullet2, 
        tank_color   => tank_color2,
        bullet       => bullet2, 
        fire_bullet  => fire_bullet_signal2, 
        colorAddress => colorAddress_tank2
    );


    -- Bullet Mover
    -- Tank 1 Bullet Mover
	bullet_mover_tank1 : bullet_mover
		port map(
        clk         => clk,
        rst_n       => rst_n,
        pulse_out   => pulse_out,
        fire_bullet => fire_bullet_signal1, -- Specific to Tank 1
        y_bullet    => y_bullet1,
        x_start     => x_start1,
        x_bullet    => x_bullet1,
        bullet      => bullet1
    );

	-- Tank 2 Bullet Mover
	bullet_mover_tank2 : bullet_mover
		port map(
        clk         => clk,
        rst_n       => rst_n,
        pulse_out   => pulse_out,
        fire_bullet => fire_bullet_signal2, -- Specific to Tank 2
        y_bullet    => y_bullet2,
        x_start     => x_start2,
        x_bullet    => x_bullet2,
        bullet      => bullet2
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

    -- Tank 1 Speed Control
	speed_ctrl_tank1 : tank_speed
		port map(
        keyboard_clk => keyboard_clk,
        keyboard_data => keyboard_data,
        clk => clk,
        rst_n => rst_n,
        speed => speed1, -- For Tank 1
        bullet => bullet1,
        fire_bullet => fire_bullet_signal1
    );

		-- Tank 2 Speed Control
	speed_ctrl_tank2 : tank_speed
		port map(
        keyboard_clk => keyboard_clk,
        keyboard_data => keyboard_data,
        clk => clk,
        rst_n => rst_n,
        speed => speed2, -- For Tank 2
        bullet => bullet2,
        fire_bullet => fire_bullet_signal2
    );


end architecture behavioral;

