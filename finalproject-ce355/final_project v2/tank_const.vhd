library IEEE;
use IEEE.std_logic_1164.all; 
use IEEE.numeric_std.all;
use work.game_library.all;
--Additional standard or custom libraries go here

package tank_const is

    constant TANK_HEIGHT : integer := 20;
    constant TANK_WIDTH : integer := 30;
	 constant TANK_GUNW   : integer := 6;
	 constant TANK_GUNH   : integer := 15;
	 constant TANK_1_POS_X : integer := 320 - (TANK_WIDTH / 2);
	 constant TANK_1_POS_Y : integer := 470 - TANK_HEIGHT;
	 constant TANK_2_POS_X : integer := 320 - (TANK_WIDTH / 2);
	 constant TANK_2_POS_Y : integer := 30 - TANK_HEIGHT;
	 constant TANK_1_BULL_POS_X : integer := TANK_1_POS_X + (TANK_WIDTH / 2) - (TANK_GUNW/2);
	 constant TANK_1_BULL_POS_Y : integer := TANK_1_POS_Y - TANK_GUNH;
	 constant TANK_2_BULL_POS_X : integer := TANK_2_POS_X + (TANK_WIDTH / 2) - (TANK_GUNW/2);
	 constant TANK_2_BULL_POS_Y : integer := TANK_2_POS_Y + TANK_GUNH;
	 constant TANK_1_INIT_POS : position := (TANK_1_POS_X, TANK_1_POS_Y);
	 constant TANK_2_INIT_POS : position := (TANK_2_POS_X, TANK_2_POS_Y);
	 constant TANK_1_BULL_INIT_POS : position := (TANK_1_BULL_POS_X, TANK_1_BULL_POS_Y);
	 constant TANK_2_BULL_INIT_POS : position := (TANK_2_BULL_POS_X, TANK_2_BULL_POS_Y);
	 constant TANK_1_COLOR : std_logic_vector(2 downto 0) := "000";
	 constant TANK_2_COLOR : std_logic_vector(2 downto 0) := "010";
	 constant BULLET_H    : integer := 40;
	 constant BULLET_W    : integer := 30;
	 constant BULLET_START_Y : integer := 395;
	 constant SPEED_SLOW   : std_logic_vector(2 downto 0) := "001";
    constant SPEED_MEDIUM : std_logic_vector(2 downto 0) := "010";
    constant SPEED_FAST   : std_logic_vector(2 downto 0) := "100";
	 
	 constant SCREEN_TOP    : integer := 0; 
	 
	 constant color_red 	 	 : std_logic_vector(2 downto 0) := "000";
	 constant color_green	 : std_logic_vector(2 downto 0) := "001";
	 constant color_blue 	 : std_logic_vector(2 downto 0) := "010";
	 constant color_yellow 	 : std_logic_vector(2 downto 0) := "011";
	 constant color_magenta  : std_logic_vector(2 downto 0) := "100";
	 constant color_cyan 	 : std_logic_vector(2 downto 0) := "101";
	 constant color_black 	 : std_logic_vector(2 downto 0) := "110";
	 constant color_white	 : std_logic_vector(2 downto 0) := "111";
	 
    --Other constants, types, subroutines, components go here
	 
end package tank_const;

package body tank_const is

    --Subroutine declarations go here
    -- you will not have any need for it now, this package is only for defining
    -- some useful constants
	 
end package body tank_const;