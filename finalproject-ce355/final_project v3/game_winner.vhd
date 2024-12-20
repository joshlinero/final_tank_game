library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity game_winner is
    port(
        clk, rst_n, we  : in std_logic;
        
        winner          : out std_logic;
        score           : out integer;
        collision_hit   : in std_logic
    );
end entity game_winner;

architecture fsm of game_winner is

    -- Define the states, including 'done'
    type state_type is (start, scored, check_winner, win, done);
    signal current_state, next_state : state_type;
    signal score_reg : integer := 0;  -- Register to hold the score
    signal temp_score : integer := 0; -- Temporary signal for score updates
	 signal winner_temp : std_logic := '0';
	 signal winner_reg : std_logic := '0';

begin

    -- Asynchronous Reset and Synchronous State Update
    process(clk, rst_n)
    begin
        if rst_n = '1' then
            current_state <= start;
            score_reg <= 0;  -- Reset score_reg to zero
				winner_reg <= '0';
        elsif rising_edge(clk) then
            current_state <= next_state;
            score_reg <= temp_score;  -- Update score_reg with temp_score
            score <= temp_score;      -- Update score output
				winner <= winner_temp;
				winner_reg <=winner_temp;
        end if;
    end process;

    -- Next State and Output Logic
    process(current_state, we, collision_hit, score_reg, temp_score)
    begin
        -- Default assignments to avoid latches
        next_state <= current_state;
        winner_temp <= winner_reg;
        temp_score <= score_reg;  -- Initialize temp_score with score_reg

        case current_state is
        
            when start =>
                if collision_hit = '1' then
                    next_state <= scored;
                else
                    next_state <= start;
                end if;
                
            when scored =>
                temp_score <= score_reg + 1;  -- Increment temp_score
                next_state <= check_winner;
                
            when check_winner =>
                if temp_score >= 3 then
                    next_state <= win;
                else
                    next_state <= start;
                end if;
            
            when win =>
                next_state <= done;
                winner_temp <= '1';
            
            when done =>
                -- Maintain the current state values explicitly
                next_state <= done;
                winner_temp <= '1';
            
            when others =>
                -- Explicitly assign defaults in case of unexpected state
                next_state <= start;
                winner_temp <= '0';
                
        end case;
    end process;

end architecture fsm;