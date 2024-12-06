library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity speed_control is
	port(
		clk, rst_n		 			: in std_logic;
		speed1, speed2, speed3	: in std_logic;
		tank_speed_in    			: in std_logic_vector(2 downto 0);
		tank_speed_out   			: out std_logic_vector(2 downto 0)
	);	
end entity speed_control;

architecture behavioral of speed_control is
begin
	
	process(clk, rst_n, speed1, speed2, speed3, tank_speed_in)
	begin
		if (rst_n = '1') then
			tank_speed_out <= "000";
		elsif (rising_edge(clk)) then 
			if speed1 = '1' then
				tank_speed_out <= SPEED_SLOW;
			elsif speed2 = '1' then
				tank_speed_out <= SPEED_MEDIUM;
			elsif speed3 = '1' then
				tank_speed_out <= SPEED_FAST;
			else
				tank_speed_out <= tank_speed_in;
			end if;
		end if;	
	end process;
	
end architecture behavioral;