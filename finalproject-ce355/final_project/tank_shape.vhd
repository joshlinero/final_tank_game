library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;
use WORK.color_constants.all;

entity tank_shape is
    port(
        pixel_row      : in natural;
        pixel_column   : in natural;
        x_start        : in natural;
        y_start        : in natural;
        tank_color     : in std_logic_vector(2 downto 0);
        colorAddress   : out std_logic_vector(2 downto 0)
    );
end entity tank_shape;

architecture behavioral of tank_shape is
begin
    process(pixel_row, pixel_column, x_start, y_start, tank_color)
    begin
        if (pixel_row > y_start and pixel_row < y_start + TANK_HIEGHT and 
            pixel_column > x_start and pixel_column < x_start + TANK_WIDTH) then
            colorAddress <= tank_color;
        else
            colorAddress <= color_white; -- Default background color
        end if;
    end process;
end architecture behavioral;
