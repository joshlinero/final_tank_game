library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tankgame is

	port(
		-- Basics
		clk			:	in std_logic;
		reset_game	:	in std_logic;
		
		-- Keyboard
		keyboard_clk	:	in std_logic;
		keyboard_data	:	in std_logic;
		clk_50MHZ		:	in std_logic;
		
		-- VGA
		VGA_clk		:	out std_logic;
		VGA_R			:	out std_logic_vector(7 downto 0);
		VGA_G			:	out std_logic_vector(7 downto 0);
		VGA_B			:	out std_logic_vector(7 downto 0);
		HORI_sync	:	out std_logic;
		VERT_sync	:	out std_logic;
		VGA_reset	:	out std_logic;
		
		-- Score
		seg_out_1	:	out std_logic_vector(6 downto 0);
		seg_out_2	:	out std_logic_vector(6 downto 0)
		
		-- LCD (to implement)
	);
		
end entity tankgame;

architecture structure of tankgame is

	-- Control signals
	signal reset	:	std_logic := 0;
	
	-- Player 1
	signal 
	
	-- Player 2
	
	-- Keyboard
	
begin
	
end architecture structure;