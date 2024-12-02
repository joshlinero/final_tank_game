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
        bullet      : out std_logic  -- Bullet active flag
    );
end entity bullet_mover;


architecture behavioral of bullet_mover is
    signal bullet_internal : std_logic := '0'; -- Internal signal for bullet active flag
    constant SCREEN_TOP    : natural := 0; -- Adjust based on screen dimensions
begin
    --bullet <= bullet_internal; -- Assign internal signal to output port

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            bullet_internal <= '0'; -- Reset bullet state to inactive
				y_bullet <= 0; -- Reset position
        elsif rising_edge(clk) then
				y_bullet <= y_bullet;
            if pulse_out = '1' then
                if fire_bullet = '1' and bullet_internal = '0' then
                    -- Fire the bullet: activate and set initial position
                    bullet_internal <= '1';
                    y_bullet <= BULLET_START_Y; 
                elsif bullet_internal = '1' then
                    -- Move the bullet upward
                    if y_bullet > SCREEN_TOP then
                        y_bullet <= y_bullet - 1; -- Move bullet up by one pixel
                    else
                        -- Deactivate bullet if it moves off-screen
                        bullet_internal <= '0';
                    end if;
                end if;
            end if;
        end if;
		  bullet <= bullet_internal; -- Assign internal signal to output port
    end process;
end architecture behavioral;
