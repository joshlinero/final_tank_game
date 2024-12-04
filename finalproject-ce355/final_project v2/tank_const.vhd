library IEEE;
use IEEE.std_logic_1164.all; 
use work.tank_const.all;
--Additional standard or custom libraries go here

package tank_const is

    constant TANK_HEIGHT : natural := 20;
    constant TANK_WIDTH : natural := 30;
	 constant TANK_GUNW   : natural := 6;
	 constant TANK_GUNH   : natural := 15;
	 constant TANK_1_POS_X : natural := 320 - (TANK_WIDTH / 2);
	 constant TANK_1_POS_Y : natural := 470 - TANK_HEIGHT;
	 constant TANK_2_POS_X : natural := (320 + (TANK_WIDTH / 2));
	 constant TANK_2_POS_Y : natural := 30 - TANK_HEIGHT;
	 constant TANK_1_BULL_POS_X : natural := TANK_1_POS_X + (TANK_WIDTH / 2) - (TANK_GUNW/2);
	 constant TANK_1_BULL_POS_Y : natural := TANK_1_POS_Y - TANK_GUNH;
	 constant TANK_2_BULL_POS_X : natural := TANK_2_POS_X + (TANK_WIDTH / 2) - (TANK_GUNW/2);
	 constant TANK_2_BULL_POS_Y : natural := TANK_2_POS_Y + TANK_GUNH;
	 constant TANK_1_COLOR : std_logic_vector(2 downto 0) := "000";
	 constant TANK_2_COLOR : std_logic_vector(2 downto 0) := "010";
	 constant BULLET_H    : natural := 40;
	 constant BULLET_W    : natural := 30;
	 constant BULLET_START_Y : natural := 395;
	 constant SPEED_SLOW   : std_logic_vector(2 downto 0) := "001";
    constant SPEED_MEDIUM : std_logic_vector(2 downto 0) := "010";
    constant SPEED_FAST   : std_logic_vector(2 downto 0) := "100";
	 
	 constant SCREEN_TOP    : natural := 0; 
	 
	 constant color_red 	 	 : std_logic_vector(2 downto 0) := "000";
	 constant color_green	 : std_logic_vector(2 downto 0) := "001";
	 constant color_blue 	 : std_logic_vector(2 downto 0) := "010";
	 constant color_yellow 	 : std_logic_vector(2 downto 0) := "011";
	 constant color_magenta 	 : std_logic_vector(2 downto 0) := "100";
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