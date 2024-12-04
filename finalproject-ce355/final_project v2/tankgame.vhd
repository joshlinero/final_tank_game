library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.game_library.all;

entity tankgame is

	port(
		-- Basics
		clk			:	in std_logic;
		reset_n	:	in std_logic;
		
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
		VGA_BLANK	:	out std_logic;
		
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
	signal tank_1_curr_pos		:	position;
	signal tank_1_next_pos		:	position;
	
	signal tank_1_bul_curr_pos	:	position;
	signal tank_1_bul_next_pos	:	position;
	
	signal tank_1_curr_speed	:	integer;
	signal tank_1_next_speed	:	integer;
	
	signal tank_1_speed1_key	:	std_logic;
	signal tank_1_speed2_key	:	std_logic;
	signal tank_1_speed3_key	:	std_logic;
	
	signal tank_1_fire_key		:	std_logic;
	
	signal tank_1_disp_flag		:	std_logic;
	signal tank_1_bul_disp_flag:	std_logic;
	
	signal tank_1_bul_curr_fire:	std_logic;
	signal tank_1_bul_next_fire:	std_logic;
	
	signal tank_1_score			:	integer;
	
	-- Player 2
	signal tank_2_curr_pos		:	position;
	signal tank_2_next_pos		:	position;
	
	signal tank_2_bul_curr_pos	:	position;
	signal tank_2_bul_next_pos	:	position;
	
	signal tank_2_curr_speed	:	integer;
	signal tank_2_next_speed	:	integer;
	
	signal tank_2_speed1_key	:	std_logic;
	signal tank_2_speed2_key	:	std_logic;
	signal tank_2_speed3_key	:	std_logic;
	
	signal tank_2_fire_key		:	std_logic;
	
	signal tank_2_disp_flag		:	std_logic;
	signal tank_2_bul_disp_flag:	std_logic;
	
	signal tank_2_bul_curr_fire:	std_logic;
	signal tank_2_bul_next_fire:	std_logic;

	signal tank_2_score			:	integer;
	
	-- Keyboard
	signal hist3, hist2, hist1, hist0	:	std_logic_vector(7 downto 0);
	signal key_code							:	std_logic_vector(7 downto 0);
	signal key_ready							:	std_logic;
	signal bul_1_fix							:	position;
	signal bul_2_fix							:	position;
	
	component pixelgenerator is
		port(
			-- Basic pixel gen stuff
			clk		:	in std_logic;
			ROM_clk	:	in	std_logic;
			reset_n	:	in	std_logic;
			vid_on	:	in	std_logic;
			eof		:	in	std_logic;
			pixel_row:	in	std_logic_vector(9 downto 0);
			pixel_col:	in	std_logic_vector(9 downto 0);
			red_out	:	out	std_logic_vector(7 downto 0);
			green_out:	out	std_logic_vector(7 downto 0);
			blue_out	:	out	std_logic_vector(7 downto 0);
			
			-- Tank 1 stuff
			tank_1_pos				:	in	position;
			tank_1_disp_flag		:	in std_logic;
			tank_1_bul_pos			:	in	position;
			tank_1_bul_disp_flag	:	in std_logic;
			
			-- Tank 2 stuff
			tank_2_pos				:	in	position;
			tank_2_disp_flag		:	in std_logic;
			tank_2_bul_pos			:	in	position;
			tank_2_bul_disp_flag	:	in std_logic
			
		);
	end component pixelgenerator;
	
	component VGA_SYNC is
		port(
			clock_50Mhz							: in std_logic;
			horiz_sync_out, vert_sync_out,
			video_on, pixel_clock, eof		: out std_logic;												
			pixel_row, pixel_column			: out std_logic_vector(9 downto 0)
		);
	end component VGA_SYNC;
	
	-- VGA signals
	signal pixel_row_int	:	std_logic_vector(9 downto 0);
	signal pixel_col_int	:	std_logic_vector(9 downto 0);
	signal video_on_int	:	std_logic;
	signal VGA_clk_int	:	std_logic;
	signal eof				:	std_logic;
	
	signal tank_1_init_pos : position;
	signal tank_2_init_pos : position;
	signal tank_1_bull_init_pos : position;
	signal tank_2_bull_init_pos : position;
	
begin

	reset <= not reset_n;
	
	tank_1_init_pos(0) <= TANK_1_POS_X;
	tank_1_init_pos(1) <= TANK_1_POS_Y;
	tank_2_init_pos(0) <= TANK_2_POS_X;
	tank_2_init_pos(1) <= TANK_2_POS_Y;
	tank_1_bull_init_pos(0) <= TANK_1_BULL_POS_X;
	tank_1_bull_init_pos(1) <= TANK_1_BULL_POS_Y;
	tank_2_bull_init_pos(0) <= TANK_2_BULL_POS_X;
	tank_2_bull_init_pos(1) <= TANK_2_BULL_POS_Y;
	
	shoot_in_proc: process(clk, reset) is begin
		case hist0 is
			when "00011101" =>
				tank_1_fire_key <= '1';
			when "00011100" =>
				tank_1_speed1_key <= '1';
			when "00011011" =>
				tank_1_speed2_key <= '1';
			when "00100011" =>
				tank_1_speed3_key <= '1';
			when "01000011" =>
				tank_2_fire_key <= '1';
			when "00111011" =>
				tank_2_speed1_key <= '1';
			when "01000010" =>
				tank_2_speed2_key <= '1';
			when "01001011" =>
				tank_2_speed3_key <= '1';
			when others =>
				tank_1_fire_key <= '0';
				tank_1_speed1_key <= '0';
				tank_1_speed2_key <= '0';
				tank_1_speed3_key <= '0';
				tank_2_fire_key <= '0';
				tank_2_speed1_key <= '0';
				tank_2_speed2_key <= '0';
				tank_2_speed3_key <= '0';
			end case;
	end process;
	
	vid : pixelGenerator
		port map(
			-- Basic pixel gen stuff
			clk => clock,
			ROM_clk => VGA_clk_int,
			reset_n => reset_n,
			vid_on => video_on_int,
			eof => eof,
			pixel_row => pixel_row_int,
			pixel_col => pixel_col_int,
			red_out => VGA_R,
			green_out => VGA_G,
			blue_out => VGA_B,
			
			-- Tank 1 stuff
			tank_1_pos => tank_1_curr_pos,
			tank_1_disp_flag => tank_1_disp_flag,
			tank_1_bul_pos => tank_1_bul_curr_pos,
			tank_1_bul_disp_flag	=> tank_1_bul_disp_flag,
			
			-- Tank 2 stuff
			tank_2_pos => tank_2_curr_pos,
			tank_2_disp_flag => tank_2_disp_flag,
			tank_2_bul_pos => tank_2_bul_curr_pos,
			tank_2_bul_disp_flag	=> tank_2_bul_disp_flag
		);
	
	sync : VGA_SYNC
		port map(
			clock_50Mhz => clk_50MHz,
			horiz_sync_out => HORI_sync,
			vert_sync_out => VERT_sync,
			video_on => video_on_int,
			pixel_clock => VGA_clk_int,
			eof => eof,
			pixel_row => pixel_row_int,
			pixel_column => pixel_col_int
		);
		
	VGA_BLANK <= video_on_int;
	VGA_clk <= VGA_clk_int;
	
	keyboard : ps2
		port map(
			keyboard_clk => keyboard_clk,
			keyboard_data => keyboard_data,
			clock_50MHz => clk,
			reset => reset_n,
			scan_code => key_code,
			scan_ready => key_ready,
			hist3 => hist3,
			hist2 => hist2,
			hist1 => hist1,
			hist0 => hist0
		);
		
	logic : game_logic
		port map(
			clk => clk,
			rst => reset,
			global_write_enable => global_we,
			
			-- Tank 1 logic
			tank_1_speed1 => tank_1_speed1_key,
			tank_1_speed2 => tank_1_speed2_key,
			tank_1_speed3 => tank_1_speed3_key,
			tank_1_fire => tank_1_fire_key,
			
			tank_1_pos_in => tank_1_curr_pos,
			tank_1_pos_out => tank_1_next_pos,
			tank_1_speed_in => tank_1_curr_speed,
			tank_1_speed_out => tank_1_next_speed,
			tank_1_disp => tank_1_disp_flag,
			tank_1_bul_pos_in => tank_1_bul_curr_pos,
			tank_1_bul_pos_out => tank_1_bul_next_pos,
			tank_1_bul_fired_in => tank_1_bul_curr_fired,
			tank_1_bul_fired_out => tank_1_bul_next_fired,
			tank_1_bul_disp => tank_1_bul_disp_flag,
			tank_1_score => tank_1_score,
			
			-- Tank 2 logic
			tank_2_speed1 => tank_2_speed1_key,
			tank_2_speed2 => tank_2_speed2_key,
			tank_2_speed3 => tank_2_speed3_key,
			tank_2_fire => tank_2_fire_key,
			
			tank_2_pos_in => tank_2_curr_pos,
			tank_2_pos_out => tank_2_next_pos,
			tank_2_speed_in => tank_2_curr_speed,
			tank_2_speed_out => tank_2_next_speed,
			tank_2_disp => tank_2_disp_flag,
			tank_2_bul_pos_in => tank_2_bul_curr_pos,
			tank_2_bul_pos_out => tank_2_bul_next_pos,
			tank_2_bul_fired_in => tank_2_bul_curr_fired,
			tank_2_bul_fired_out => tank_2_bul_next_fired,
			tank_2_bul_disp => tank_2_bul_disp_flag,
			tank_2_score => tank_2_score
		);
		
		tank_1 : tank
			generic map(
				tank_loc => tank_1_init_pos
			);
			port map(
				clk => clk,
				rst => reset,
				we => global_we,
				tank_pos_in => tank_1_curr_pos,
				tank_pos_out => tank_1_next_pos,
				speed_in => tank_1_curr_speed,
				speed_out => tank_1_next_speed
			);
			
		tank_2 : tank
			generic map(
				tank_loc => tank_2_init_pos
			);
			port map(
				clk => clk,
				rst => reset,
				we => global_we,
				tank_pos_in => tank_2_curr_pos,
				tank_pos_out => tank_2_next_pos,
				speed_in => tank_2_curr_speed,
				speed_out => tank_2_next_speed
			);
			
		bul_1 : bullet
			generic map(
				bull_loc => tank_1_bull_init_pos
			);
			port map(
				clk => clk,
				rst => reset,
				we => global_we,
				pos_in => tank_1_bul_curr_pos,
				pos_out => tank_1_bul_next_pos,
				bullet_fired_in => tank_1_bul_curr_fired,
				bullet_fired_out => tank_1_bul_next_fired
			);
		
		bul_2 : bullet
			generic map(
				bull_loc => tank_2_bull_init_pos
			);
			port map(
				clk => clk,
				rst => reset,
				we => global_we,
				pos_in => tank_2_bul_curr_pos,
				pos_out => tank_2_bul_next_pos,
				bullet_fired_in => tank_2_bul_curr_fired,
				bullet_fired_out => tank_2_bul_next_fired
			);
	
	
end architecture structure;