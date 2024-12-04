library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity game_update_logic is
    port(
        clk, rst, global_write_enable : in std_logic;
        pulse_out : in std_logic;

        -- Tank attribute inputs
        tank_1_pos_in, tank_2_pos_in : in position;

        -- Tank attribute outputs
        tank_1_pos_out, tank_2_pos_out : out position;
        tank_1_disp, tank_2_disp : out std_logic
    );
end entity game_update_logic;

architecture behavioral of game_update_logic is
    signal current_tank_1_pos, current_tank_2_pos : position := (others => 0);
    signal tank_1_direction, tank_2_direction : std_logic := '0'; -- '0' = left, '1' = right
    signal tank_1_speed, tank_2_speed : natural := 5;
begin

    position_update : process(clk, rst)
    begin
        if rst = '0' then
            -- Reset positions and directions
            current_tank_1_pos(0) <= TANK_1_POS_X;
            current_tank_1_pos(1) <= TANK_1_POS_Y;
            current_tank_2_pos(0) <= TANK_2_POS_X;
            current_tank_2_pos(1) <= TANK_2_POS_Y;
            tank_1_direction <= '0';
            tank_2_direction <= '0';
        elsif rising_edge(clk) then
				tank_1_disp <= '1';
				tank_2_disp <= '1';
            if global_write_enable = '1' then
                -- Read state: Update positions based on direction
                if pulse_out = '1' then
                    -- Tank 1 movement
                    if tank_1_direction = '1' then
                        if current_tank_1_pos(0) + TANK_WIDTH < 640 then
                            current_tank_1_pos(0) <= current_tank_1_pos(0) + tank_1_speed;
                        else
                            tank_1_direction <= '0'; -- Reverse direction
                        end if;
                    else
                        if current_tank_1_pos(0) > 0 then
                            current_tank_1_pos(0) <= current_tank_1_pos(0) - tank_1_speed;
                        else
                            tank_1_direction <= '1'; -- Reverse direction
                        end if;
                    end if;

                    -- Tank 2 movement
                    if tank_2_direction = '1' then
                        if current_tank_2_pos(0) + TANK_WIDTH < 640 then
                            current_tank_2_pos(0) <= current_tank_2_pos(0) + tank_2_speed;
                        else
                            tank_2_direction <= '0'; -- Reverse direction
                        end if;
                    else
                        if current_tank_2_pos(0) > 0 then
                            current_tank_2_pos(0) <= current_tank_2_pos(0) - tank_2_speed;
                        else
                            tank_2_direction <= '1'; -- Reverse direction
                        end if;
                    end if;

                    -- Maintain fixed vertical positions
                    current_tank_1_pos(1) <= TANK_1_POS_Y;
                    current_tank_2_pos(1) <= TANK_2_POS_Y;
                end if;
            else
                -- Write state: Ensure tanks remain within bounds
                -- Tank 1 bounds
                if current_tank_1_pos(0) - TANK_WIDTH / 2 < 0 then
                    current_tank_1_pos(0) <= TANK_WIDTH / 2;
                    tank_1_direction <= '1'; -- Reverse direction
                elsif current_tank_1_pos(0) + TANK_WIDTH / 2 > 640 then
                    current_tank_1_pos(0) <= 640 - TANK_WIDTH / 2;
                    tank_1_direction <= '0'; -- Reverse direction
                end if;

                -- Tank 2 bounds
                if current_tank_2_pos(0) - TANK_WIDTH / 2 < 0 then
                    current_tank_2_pos(0) <= TANK_WIDTH / 2;
                    tank_2_direction <= '1'; -- Reverse direction
                elsif current_tank_2_pos(0) + TANK_WIDTH / 2 > 640 then
                    current_tank_2_pos(0) <= 640 - TANK_WIDTH / 2;
                    tank_2_direction <= '0'; -- Reverse direction
                end if;

                -- Maintain vertical positions
                current_tank_1_pos(1) <= TANK_1_POS_Y;
                current_tank_2_pos(1) <= TANK_2_POS_Y;
            end if;
        end if;
    end process;

    -- Output assignments
    tank_1_pos_out <= current_tank_1_pos;
    tank_2_pos_out <= current_tank_2_pos;

end architecture behavioral;


