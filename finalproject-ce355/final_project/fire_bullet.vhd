library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fire_bullet is
    Port (
		  keyboard_clk : in std_logic;
        keyboard_data : in std_logic;
        clk : in std_logic;
        reset : in std_logic;
        fire_bullet : out std_logic
    );
end fire_bullet;

architecture Behavioral of fire_bullet is
    signal fire_flag : std_logic := '0';
	 signal ps2_scan_code  : std_logic_vector(7 downto 0);
    signal ps2_scan_ready : std_logic;
    signal history0, history1, history2, history3 : std_logic_vector(7 downto 0);

    component ps2 is
        port(
            keyboard_clk, keyboard_data, clock_50MHz,
            reset : in std_logic;
            scan_code : out std_logic_vector(7 downto 0);
            scan_readyo : out std_logic;
            hist3 : out std_logic_vector(7 downto 0);
            hist2 : out std_logic_vector(7 downto 0);
            hist1 : out std_logic_vector(7 downto 0);
            hist0 : out std_logic_vector(7 downto 0)
        );
    end component ps2;
begin

	-- Map PS2 component
    u_ps2: ps2 port map(
        keyboard_clk => keyboard_clk,
        keyboard_data => keyboard_data,
        clock_50MHz => clk,
        reset => reset,
        scan_code => ps2_scan_code,
        scan_readyo => ps2_scan_ready,
        hist3 => history3,
        hist2 => history2,
        hist1 => history1,
        hist0 => history0
    );	
		
    process(clk, reset)
    begin
        if reset = '1' then
            fire_flag <= '0';
        elsif rising_edge(clk) then
            if ps2_scan_ready = '1' then
                case ps2_scan_code is
                    when "00011101" => -- Key 'W'
                        fire_flag <= '1'; -- Set fire flag
                    when others =>
                        fire_flag <= '0'; -- Reset fire flag if no match
                end case;
            end if;
        end if;
    end process;

    -- Output the fire signal
    fire_bullet <= fire_flag;
end Behavioral;
