library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.tank_const.all;

entity tank_speed is
    port(
        keyboard_clk : in std_logic;
        keyboard_data : in std_logic;
        clk : in std_logic;
        rst_n : in std_logic;
        speed : out std_logic_vector(2 downto 0)  ;
		  bullet : in std_logic;
		  fire_bullet : out std_logic
    );
end entity tank_speed;

architecture Behavioral of tank_speed is

    signal ps2_scan_code  : std_logic_vector(7 downto 0);
    signal ps2_scan_ready : std_logic;
    signal history0, history1, history2, history3 : std_logic_vector(7 downto 0);
    signal speed_internal : std_logic_vector(2 downto 0) := "001"; -- Default speed
	 signal fire_flag : std_logic := '0';

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
    b_ps2: ps2 port map(
        keyboard_clk => keyboard_clk,
        keyboard_data => keyboard_data,
        clock_50MHz => clk,
        reset => rst_n,
        scan_code => ps2_scan_code,
        scan_readyo => ps2_scan_ready,
        hist3 => history3,
        hist2 => history2,
        hist1 => history1,
        hist0 => history0
    );

    -- Process for controlling speed
    speed_tank : process(clk, rst_n, ps2_scan_ready)
    begin
        if rst_n = '0' then
            speed_internal <= SPEED_SLOW; -- Reset speed to the slowest setting
				fire_flag <= '0';
        elsif rising_edge(clk) then
            if ps2_scan_ready = '1' then
                case ps2_scan_code is
                    when "00011100" =>  -- Key 'A' (Slow speed)
                        if speed_internal = SPEED_MEDIUM then
                            speed_internal <= SPEED_SLOW;
									 fire_flag <= '0';
                        elsif speed_internal = SPEED_FAST then
                            speed_internal <= SPEED_SLOW;
									 fire_flag <= '0';
                        else
                            speed_internal <= SPEED_SLOW; -- Keep at slowest speed
									 fire_flag <= '0';
                        end if;
						  when "00011011" =>  -- Key 'S' (Medium speed)
                        if speed_internal = SPEED_SLOW then
                            speed_internal <= SPEED_MEDIUM;
									 fire_flag <= '0';
                        elsif speed_internal = SPEED_FAST then
                            speed_internal <= SPEED_MEDIUM;
									 fire_flag <= '0';
                        else
                            speed_internal <= SPEED_MEDIUM;
									fire_flag <= '0'; 
                        end if;
                    when "00100011" =>  -- Key 'D' (Increase speed)
                        if speed_internal = SPEED_SLOW then
                            speed_internal <= SPEED_FAST;
									 fire_flag <= '0';
                        elsif speed_internal = SPEED_MEDIUM then
                            speed_internal <= SPEED_FAST;
									 fire_flag <= '0';
                        else
                            speed_internal <= SPEED_FAST; -- Keep at fastest speed
									 fire_flag <= '0';
                        end if;
						  when "00011101" =>
								fire_flag <= '1';
                    when others =>
                        speed_internal <= speed_internal; -- Default case for robustness
								fire_flag <= '0';
                end case;
            end if;
        end if;
    end process speed_tank;

    -- Assign the internal speed signal to the output port
    speed <= speed_internal;
	 fire_bullet <= fire_flag;

end architecture Behavioral;
