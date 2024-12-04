library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;

entity bullet_mover is
    port(
        clk         : in std_logic;
        rst_n       : in std_logic;
        pulse_out   : in std_logic;
        fire_bullet : in std_logic; -- Signal indicating button press to fire the bullet
        y_bullet    : inout natural; -- Bullet's y-coordinate
        x_start     : in natural; -- Initial x-coordinate of the bullet
        x_bullet    : out natural; -- Current x-coordinate of the bullet
        bullet      : out std_logic  -- Bullet active flag
    );
end entity bullet_mover;


architecture behavioral of bullet_mover is
    signal bullet_active : std_logic := '0'; -- Internal flag for bullet state
    signal y_bullet_reg  : natural := 0;     -- Register for y-coordinate
    signal x_bullet_reg  : natural := 0;     -- Register for x-coordinate
begin
    -- Main process handling bullet logic
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            -- Reset logic
            bullet_active <= '0';
            y_bullet_reg <= 0;
            x_bullet_reg <= 0;
        elsif rising_edge(clk) then
            if pulse_out = '1' then
                -- Fire a new bullet if no bullet is active
                if bullet_active = '0' and fire_bullet = '1' then
                    bullet_active <= '1';         -- Activate bullet
                    y_bullet_reg <= BULLET_START_Y; -- Set starting Y position
                    x_bullet_reg <= x_start + 5; -- Set starting X position
                end if;

                -- Move the bullet upward if active
                if bullet_active = '1' then
                    if y_bullet_reg >= SCREEN_TOP then
                        y_bullet_reg <= y_bullet_reg - 3; -- Move bullet upward
                    else
                        -- Deactivate bullet when it reaches the top
                        bullet_active <= '0';
                        y_bullet_reg <= 0;
                        x_bullet_reg <= 0;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Update outputs
    y_bullet <= y_bullet_reg;
    x_bullet <= x_bullet_reg;
    bullet <= bullet_active;
end architecture behavioral;
