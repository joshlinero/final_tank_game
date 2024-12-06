library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.tank_const.all;
use work.game_library.all;

entity tank_location is
	generic(
		tank_loc      : position := (others => 0)
	);
	port(
		clk, rst_n		 : in std_logic;
		tank_pos_in     : in position;
		tank_pos_out    : out position;
		speed_in        : in std_logic_vector(2 downto 0);
		speed_out       : out std_logic_vector(2 downto 0)
	);	
end entity tank_location;

architecture behavioral of tank_location is
begin
	
	process(clk, rst_n, speed_in)
	begin
		if (rst_n = '1') then
			tank_pos_out <= tank_loc;
			speed_out <= SPEED_SLOW;
			
		elsif (rising_edge(clk)) then 
			tank_pos_out <= tank_pos_in;
			speed_out <= speed_in;
		end if;	
	end process;
	
end architecture behavioral;