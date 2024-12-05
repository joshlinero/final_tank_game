library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity tank_control is
    port(
        clk, rst_n, we  : in std_logic;
        tank_curr_pos_in     : in position;
        tank_next_pos_out    : out position;
        tank_display         : out std_logic;
        tank_speed_in        : in std_logic_vector(2 downto 0)
    );    
end entity tank_control;

architecture fsm of tank_control is

    -- Define the states, including 'done'
    type state_type is (start, move_right, move_left, die, win, done);
    signal current_state, next_state : state_type;
    signal tank_next_pos : position; 
    signal temp_display : std_logic := '1'; -- Default display ON

begin

    -- Asynchronous Reset and Synchronous State Update
    process(clk, rst_n)
    begin
        if rst_n = '0' then
            current_state <= start;
            tank_next_pos_out <= (others => 0); -- Ensure all outputs are assigned
            tank_display <= '1'; -- Ensure all outputs are assigned
        elsif rising_edge(clk) then
            current_state <= next_state;
            tank_next_pos_out <= tank_next_pos; 
            tank_display <= temp_display; 
        end if;
    end process;

    -- Next State and Output Logic
    process(current_state, we, tank_curr_pos_in, tank_speed_in, tank_next_pos)
    begin
        -- Default assignments to avoid latches
        next_state <= current_state;
        tank_next_pos <= tank_curr_pos_in;
        temp_display <= '1'; -- Default display ON

        case current_state is
            when start =>
                if we = '1' then
                    next_state <= move_right;
                end if;

            when move_right =>
                if we = '1' then
                    if tank_next_pos(0) + TANK_WIDTH < 640 then
                        tank_next_pos(0) <= tank_next_pos(0) + to_integer(unsigned(tank_speed_in));
                    else
                        next_state <= move_left;
                    end if;
                end if;

            when move_left =>
                if we = '1' then
                    if tank_next_pos(0) > 0 then
                        tank_next_pos(0) <= tank_next_pos(0) - to_integer(unsigned(tank_speed_in));
                    else
                        next_state <= move_right;
                    end if;
                end if;

            when die =>
                temp_display <= '0'; -- Turn off display
                next_state <= done;

            when win =>
                temp_display <= '1'; -- Keep display ON
                next_state <= done;

            when done =>
                -- Maintain the current state values explicitly
                next_state <= done;

            when others =>
                -- Explicitly assign defaults in case of unexpected state
                next_state <= start;
                tank_next_pos <= (others => 0); -- Reset array to zero
                temp_display <= '1';
        end case;
    end process;

end architecture fsm;
