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
	signal bul_fired : std_logic;
	signal curr_pos : position;
begin

  process(clk, rst_n)
  begin

    if (rst_n = '1') then
		curr_pos <= bullet_loc;
		bul_fired <= '0';
		
    elsif (rising_edge(clk)) then
      if (we = '1') then
        if (fired_in = '1') then
          curr_pos <= bull_pos_in;
        end if;
		  bul_fired <= fired_in;
		else
			bull_pos_out <= curr_pos;
			fired_out <= bul_fired;
      end if;
    end if;
  end process;
end architecture behavioral;