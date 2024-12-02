library IEEE;
use IEEE.std_logic_1164.all;

package color_constants is
    constant color_red    : std_logic_vector(2 downto 0) := "000";
    constant color_green  : std_logic_vector(2 downto 0) := "001";
    constant color_blue   : std_logic_vector(2 downto 0) := "010";
    constant color_yellow : std_logic_vector(2 downto 0) := "011";
    constant color_magenta: std_logic_vector(2 downto 0) := "100";
    constant color_cyan   : std_logic_vector(2 downto 0) := "101";
    constant color_black  : std_logic_vector(2 downto 0) := "110";
    constant color_white  : std_logic_vector(2 downto 0) := "111";
end package color_constants;


package body color_constants is
    -- No body needed for constants
end package body color_constants;