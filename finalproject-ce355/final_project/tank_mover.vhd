library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;

entity tank_mover is
    port(
        clk       : in std_logic;
        rst_n     : in std_logic;
        pulse_out : in std_logic;
        speed     : in std_logic_vector(2 downto 0);
        x_start   : inout natural;
        direction : inout std_logic
    );
end entity tank_mover;

architecture behavioral of tank_mover is
begin
    process(clk, rst_n)
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
                        direction <= '1'; -- Reverse to right
                    else
                        x_start <= x_start - to_integer(unsigned(speed));
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture behavioral;
