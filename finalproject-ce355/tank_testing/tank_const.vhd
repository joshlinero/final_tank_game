library IEEE;
use IEEE.std_logic_1164.all; 
--Additional standard or custom libraries go here

package tank_const is

    constant TANK_HIEGHT : natural := 20;
    constant TANK_WIDTH : natural := 30;
	 constant TANK_1_COLOR : std_logic_vector(2 downto 0) := "000";
	 
    --Other constants, types, subroutines, components go here
	 
end package tank_const;

package body tank_const is

    --Subroutine declarations go here
    -- you will not have any need for it now, this package is only for defining
    -- some useful constants
	 
end package body tank_const;