library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity game_update_logic is
    port(
        clk, rst_n, global_write_enable : in std_logic;
        pulse_out : in std_logic;

        -- Tank attribute inputs
        tank_1_pos_in, tank_2_pos_in : in position;

        -- Tank attribute outputs
        tank_1_pos_out, tank_2_pos_out : out position;
        tank_1_display, tank_2_display : out std_logic
    );
end entity game_update_logic;

architecture behavioral of game_update_logic is
    signal temp_tank_1_pos, temp_tank_2_pos : position := (others => 0);
    signal tank_1_speed, tank_2_speed : natural := 5;
    signal tank_1_dir, tank_2_dir : std_logic := '0';
begin

    move_tank : process(clk, rst_n)
    begin
        if rst_n = '0' then
            -- Reset positions and states
            temp_tank_1_pos(0) <= TANK_1_POS_X;
            temp_tank_1_pos(1) <= TANK_1_POS_Y;
            temp_tank_2_pos(0) <= TANK_2_POS_X;
            temp_tank_2_pos(1) <= TANK_2_POS_Y;
            tank_1_dir <= '0';
            tank_2_dir <= '0';
        elsif rising_edge(clk) then
            -- Enable display
            tank_1_display <= '1';
            tank_2_display <= '1';

            if pulse_out = '1' then
                -- Tank 1 movement
                if tank_1_dir = '1' then -- Moving right
                    if temp_tank_1_pos(0) + TANK_WIDTH >= 640 then
                        tank_1_dir <= '0'; -- Change direction to left
                    else
                        temp_tank_1_pos(0) <= temp_tank_1_pos(0) + tank_1_speed;
                    end if;
                else -- Moving left
                    if temp_tank_1_pos(0) <= 0 then
                        tank_1_dir <= '1'; -- Change direction to right
                    else
                        temp_tank_1_pos(0) <= temp_tank_1_pos(0) - tank_1_speed;
                    end if;
                end if;

                -- Tank 2 movement
                if tank_2_dir = '1' then -- Moving right
                    if temp_tank_2_pos(0) + TANK_WIDTH >= 640 then
                        tank_2_dir <= '0'; -- Change direction to left
                    else
                        temp_tank_2_pos(0) <= temp_tank_2_pos(0) + tank_2_speed;
                    end if;
                else -- Moving left
                    if temp_tank_2_pos(0) <= 0 then
                        tank_2_dir <= '1'; -- Change direction to right
                    else
                        temp_tank_2_pos(0) <= temp_tank_2_pos(0) - tank_2_speed;
                    end if;
                end if;

                -- Maintain Y position from input
                temp_tank_1_pos(1) <= tank_1_pos_in(1);
                temp_tank_2_pos(1) <= tank_2_pos_in(1);
            end if;
        end if;
    end process;

    -- Assign output positions
    tank_1_pos_out <= temp_tank_1_pos;
    tank_2_pos_out <= temp_tank_2_pos;

end architecture behavioral;
