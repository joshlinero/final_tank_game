library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;
use WORK.color_constants.all;

entity tank_bullet_shape is
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
		  fire_bullet    : in std_logic;
        colorAddress   : out std_logic_vector(2 downto 0)
    );
end entity tank_bullet_shape;

architecture behavioral of tank_bullet_shape is
begin
    process(pixel_row, pixel_column, x_start, y_start, x_bullet, y_bullet, tank_color, bullet, fire_bullet)
    begin
		if tank_number ='0' then
        if bullet = '1' then
            -- Check bullet boundaries first for priority
            if (pixel_row >= y_bullet and pixel_row <= y_bullet + BULLET_H and 
                pixel_column >= x_bullet and pixel_column <= x_bullet + BULLET_W) then
                colorAddress <= tank_color; -- Bullet color (uses tank_color for simplicity)
            -- Check tank boundaries if not in bullet region
            elsif (pixel_row > y_start and pixel_row < y_start + TANK_HIEGHT and 
                   pixel_column > x_start and pixel_column < x_start + TANK_WIDTH) then
                colorAddress <= tank_color; -- Tank body color
            elsif (pixel_row >= y_start - TANK_GUNH and pixel_row <= y_start and 
                   pixel_column >= x_start + (TANK_WIDTH / 2) - (TANK_GUNW / 2) and 
                   pixel_column <= x_start + (TANK_WIDTH / 2) + (TANK_GUNW / 2)) then
                colorAddress <= tank_color; -- Tank gun color
				--elsif fire_bullet = '1' then
				--   if (pixel_row < 50 and pixel_column < 50) then
				--		 colorAddress <= color_yellow;
				--   end if;
            else
                colorAddress <= color_white; -- Default background color
            end if;
        else
            -- Bullet is inactive; check only tank boundaries
            if (pixel_row > y_start and pixel_row < y_start + TANK_HIEGHT and 
                pixel_column > x_start and pixel_column < x_start + TANK_WIDTH) then
                colorAddress <= tank_color; -- Tank body color
            elsif (pixel_row >= y_start - TANK_GUNH and pixel_row <= y_start and 
                   pixel_column >= x_start + (TANK_WIDTH / 2) - (TANK_GUNW / 2) and 
                   pixel_column <= x_start + (TANK_WIDTH / 2) + (TANK_GUNW / 2)) then
                colorAddress <= tank_color; -- Tank gun color
				--elsif fire_bullet = '1' then
				--   if (pixel_row < 50 and pixel_column < 50) then
				--		 colorAddress <= color_green;
				--   end if;
            else
                colorAddress <= color_white; -- Default background color
            end if;
        end if;
		else
			if bullet = '1' then
            -- Check bullet boundaries first for priority
            if (pixel_row >= y_bullet and pixel_row <= y_bullet + BULLET_H and 
                pixel_column >= x_bullet and pixel_column <= x_bullet + BULLET_W) then
                colorAddress <= tank_color; -- Bullet color (uses tank_color for simplicity)
            -- Check tank boundaries if not in bullet region
            elsif (pixel_row > y_start and pixel_row < y_start + TANK_HIEGHT and 
                   pixel_column > x_start and pixel_column < x_start + TANK_WIDTH) then
                colorAddress <= tank_color; -- Tank body color
            elsif (pixel_row >= y_start - TANK_GUNH and pixel_row <= y_start and 
                   pixel_column >= x_start + (TANK_WIDTH / 2) - (TANK_GUNW / 2) and 
                   pixel_column <= x_start + (TANK_WIDTH / 2) + (TANK_GUNW / 2)) then
                colorAddress <= tank_color; -- Tank gun color
				--elsif fire_bullet = '1' then
				--   if (pixel_row < 50 and pixel_column < 50) then
				--		 colorAddress <= color_yellow;
				--   end if;
            else
                colorAddress <= color_white; -- Default background color
            end if;
        else
            -- Bullet is inactive; check only tank boundaries
            if (pixel_row > y_start and pixel_row < y_start + TANK_HIEGHT and 
                pixel_column > x_start and pixel_column < x_start + TANK_WIDTH) then
                colorAddress <= tank_color; -- Tank body color
            elsif (pixel_row >= y_start - TANK_GUNH and pixel_row <= y_start and 
                   pixel_column >= x_start + (TANK_WIDTH / 2) - (TANK_GUNW / 2) and 
                   pixel_column <= x_start + (TANK_WIDTH / 2) + (TANK_GUNW / 2)) then
                colorAddress <= tank_color; -- Tank gun color
				--elsif fire_bullet = '1' then
				--   if (pixel_row < 50 and pixel_column < 50) then
				--		 colorAddress <= color_green;
				--   end if;
            else
                colorAddress <= color_white; -- Default background color
            end if;
        end if;
		  end if;
    end process;
end architecture behavioral;

