library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pll_counter is
    port(
        clk       : in std_logic;               -- 50 MHz clock input
        rst_n     : in std_logic;               -- Active-low reset
        pulse_out : out std_logic               -- Output pulse
    );
end entity pll_counter;

architecture behavioral of pll_counter is
    -- Constants
    constant COUNTER_MAX : unsigned(19 downto 0) := to_unsigned(2**20 - 1, 20); -- 2^20 - 1

    -- Signals
    signal counter : unsigned(19 downto 0) := (others => '0'); -- 20-bit counter
begin

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            counter <= (others => '0'); -- Reset counter
            pulse_out <= '0';          -- Reset pulse
        elsif rising_edge(clk) then
            if counter = COUNTER_MAX then
                counter <= (others => '0'); -- Reset counter
                pulse_out <= '1';           -- Generate pulse
            else
                counter <= counter + 1;     -- Increment counter
                pulse_out <= '0';           -- Clear pulse
            end if;
        end if;
    end process;

end architecture behavioral;
