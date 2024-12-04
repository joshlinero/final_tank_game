library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.game_library.all;
use work.tank_const.all;

entity bullet_location is
	generic(
		bullet_loc      : position
	);
	port(
		clk, rst_n, we : in std_logic;
		bull_pos_in    : in position;
		bull_pos_out   : out position;
		fired_in       : in std_logic;
		fired_out      : out std_logic
	);
end entity bullet_location;

architecture behavioral of bullet_location is
begin

  process(clk, rst_n)
  begin

    if (rst_n = '1') then
		fired_out <= '0';
		bull_pos_out(0) <= -1000;
		bull_pos_out(1) <= -1000;
		
    elsif (rising_edge(clk)) then
      if (we = '1') then
        bull_pos_out <= bull_pos_in;
		  fired_out <= fired_in;
      end if;
    end if;
  end process;
end architecture behavioral;