library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.game_library.all;
use work.tank_const.all;


entity tankgame2 is

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
		seg_out_2	:	out std_logic_vector(6 downto 0);
		
		-- LCD (to implement)
		LCD_RS : out std_logic;
		LCD_E  : out std_logic;
		LCD_ON  : out std_logic;
		RESET_LED : out std_logic;
		SEC_LED : out std_logic;
		LCD_RW : buffer std_logic;
		DATA_BUS : inout std_logic_vector(7 DOWNTO 0)
		
	);
		
end entity tankgame2;

architecture structure of tankgame2 is

	-- Control signals
	signal reset	:	std_logic := '0';
	
	-- Player 1
	signal tank_1_curr_pos		:	position;
	signal tank_1_next_pos		:	position;
	
	signal tank_1_bul_curr_pos	:	position;
	signal tank_1_bul_next_pos	:	position;
	
	signal tank_1_curr_speed	:	std_logic_vector(2 downto 0);
	signal tank_1_next_speed	:	std_logic_vector(2 downto 0);
	
	signal tank_1_speed1_key	:	std_logic;
	signal tank_1_speed2_key	:	std_logic;
	signal tank_1_speed3_key	:	std_logic;
	
	signal tank_1_fire_key		:	std_logic;
	
	signal tank_1_disp         :  std_logic;
	signal tank_1_disp_flag		:	std_logic;
	signal tank_1_bul_disp_flag:	std_logic;
	
	signal tank_1_bul_curr_fire:	std_logic := '0';
	signal tank_1_bul_next_fire:	std_logic := '0';
	
	-- Player 2
	signal tank_2_curr_pos		:	position;
	signal tank_2_next_pos		:	position;
	
	signal tank_2_bul_curr_pos	:	position;
	signal tank_2_bul_next_pos	:	position;
	
	signal tank_2_curr_speed	:	std_logic_vector(2 downto 0);
	signal tank_2_next_speed	:	std_logic_vector(2 downto 0);
	
	signal tank_2_speed1_key	:	std_logic;
	signal tank_2_speed2_key	:	std_logic;
	signal tank_2_speed3_key	:	std_logic;
	
	signal tank_2_fire_key		:	std_logic;
	
	signal tank_2_disp_flag		:	std_logic;
	signal tank_2_bul_disp_flag:	std_logic;
	
	signal tank_2_bul_curr_fire:	std_logic := '0';
	signal tank_2_bul_next_fire:	std_logic := '0';
	
	signal tank_1_bul_dir : std_logic := '0';
	signal tank_2_bul_dir : std_logic := '1';
	
	signal collision_1_hit : std_logic;
	signal collision_2_hit : std_logic;
	
	signal score_1_signal : integer;
	signal score_2_signal : integer;
	signal score_1_slv : std_logic_vector(3 downto 0);
	signal score_2_slv : std_logic_vector(3 downto 0);
	signal segments_out_signal_1 : std_logic_vector(6 downto 0);
	signal segments_out_signal_2 : std_logic_vector(6 downto 0);
	
	-- Keyboard
	signal hist3, hist2, hist1, hist0	:	std_logic_vector(7 downto 0);
	signal key_code							:	std_logic_vector(7 downto 0);
	signal key_ready							:	std_logic;
	signal bul_1_fix							:	position;
	signal bul_2_fix							:	position;
	
	signal LCD_RS_signal : std_logic;
	signal LCD_E_signal : std_logic;
	signal LCD_ON_signal : std_logic;
	signal RESET_LED_signal : std_logic;
	signal SEC_LED_signal : std_logic;
	signal LCD_RW_signal : std_logic;						
	signal DATA_BUS_signal 	: std_logic_vector(7 downto 0);
	signal winner_signal : std_logic;			
	signal no_winner_signal : std_logic;
	
	component pixelgenerator is
		port(
			-- Basic pixel gen stuff
			clk		:	in std_logic;
			ROM_clk	:	in	std_logic;
			rst_n		:	in	std_logic;
			video_on	:	in	std_logic;
			eof		:	in	std_logic;
			pixel_row:	in	std_logic_vector(9 downto 0);
			pixel_column:	in	std_logic_vector(9 downto 0);
			red_out	:	out	std_logic_vector(7 downto 0);
			green_out:	out	std_logic_vector(7 downto 0);
			blue_out	:	out	std_logic_vector(7 downto 0);
			
			-- Tank 1 stuff
			tank_1_pos				:	in	position;
			tank_1_disp     		:	in std_logic;
			tank_1_bul_pos			:	in	position;
			tank_1_bul_disp_flag	:	in std_logic;  
			
			-- Tank 2 stuff
			tank_2_pos				:	in	position;
			tank_2_disp    		:	in std_logic;
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
	
	component ps2 is
    port(
        keyboard_clk  : in std_logic;
        keyboard_data : in std_logic;
        clock_50MHz   : in std_logic;
        reset         : in std_logic;
        scan_code     : out std_logic_vector(7 downto 0);
        scan_readyo    : out std_logic;
        hist3         : out std_logic_vector(7 downto 0);
        hist2         : out std_logic_vector(7 downto 0);
        hist1         : out std_logic_vector(7 downto 0);
        hist0         : out std_logic_vector(7 downto 0)
    );
	end component;
	
	
--	component game_update_logic is
--        port(
--            clk, rst_n, global_write_enable : in std_logic;
--
--            -- Tank attribute inputs
--            tank_1_pos_in, tank_2_pos_in : in position;
--
--            -- Tank attribute outputs
--            tank_1_pos_out, tank_2_pos_out : out position;
--            tank_1_disp, tank_2_disp : out std_logic;
--				
--				tank_1_speed1, tank_1_speed2, tank_1_speed3  : in std_logic;
--				tank_2_speed1, tank_2_speed2, tank_2_speed3  : in std_logic;
--		
--				tank_1_speed_in   : in std_logic_vector(2 downto 0);
--				tank_1_speed_out  : out std_logic_vector(2 downto 0);
--				tank_2_speed_in   : in std_logic_vector(2 downto 0);
--				tank_2_speed_out  : out std_logic_vector(2 downto 0);
--				
--				tank_1_fire, tank_2_fire : in std_logic;
--		  
--				tank_1_bul_pos_in    : in position;
--				tank_1_bul_pos_out   : out position;
--				tank_1_bul_fired_in  : in std_logic;
--				tank_1_bul_fired_out : out std_logic;
--				tank_1_bul_disp      : out std_logic;
--		  
--				tank_2_bul_pos_in    : in position;
--				tank_2_bul_pos_out   : out position;
--				tank_2_bul_fired_in  : in std_logic;
--				tank_2_bul_fired_out : out std_logic;
--				tank_2_bul_disp      : out std_logic;
--				
--				tank_1_score         : out integer;
--		      tank_2_score         : out integer
--        );
--	end component game_update_logic;
	
	-- tank control
	component tank_control is
		port(
		clk, rst_n, we  : in std_logic;

		tank_curr_pos_in     : in position;
		tank_next_pos_out    : out position;
		tank_display         : out std_logic;
		tank_speed_in        : in std_logic_vector(2 downto 0)
	);	
	end component tank_control;
	
	-- bullet control
	component bullet_control is
		port(
		clk, rst_n, we  : in std_logic;
		
		
		tank_pos_in : in position;
		fire            : in std_logic;
		bullet_pos_in      : in position;
		bullet_pos_out     : out position;
		bullet_fired_in    : in std_logic;
		bullet_fired_out   : out std_logic;
		bullet_disp        : out std_logic;
		direction            : in std_logic;
		collision_hit   : in std_logic
	);
	end component bullet_control;
	-- speed control

	-- collision control
	component collision is
	   port(
		clk, rst_n, we  : in std_logic;
		
		tank_pos_in : in position;
		bullet_pos_in      : in position;
		bullet_fired_in    : in std_logic;
		collsion_hit       : out std_logic;
		direction          : in std_logic
		);
	end component collision;
	-- game win control
	
	
	
	component tank_location is
		generic(
        tank_loc : position
		);
		port(
        clk            : in std_logic;
        rst_n            : in std_logic;
        tank_pos_in    : in position;
        tank_pos_out   : out position;
        speed_in       : in std_logic_vector(2 downto 0);
        speed_out      : out std_logic_vector(2 downto 0)
		);
	end component tank_location;
	
	component bullet_location is
		generic(
        bullet_loc : position
		);
		port(
        clk                : in std_logic;
        rst_n                : in std_logic;
        we                 : in std_logic;
        bull_pos_in             : in position;
        bull_pos_out            : out position;
        fired_in    : in std_logic;
        fired_out   : out std_logic
		);
	end component bullet_location;
	
	component leddcd is
		port(
			data_in : in std_logic_vector(3 downto 0);
			segments_out : out std_logic_vector(6 downto 0)
		);
	end component leddcd;
	
	component de2lcd is
		port(
			reset, clk_50Mhz				: IN	STD_LOGIC;
		 LCD_RS, LCD_E, LCD_ON, RESET_LED, SEC_LED		: OUT	STD_LOGIC;
		 LCD_RW						: BUFFER STD_LOGIC;
		 DATA_BUS				: INOUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
		 winner              : in std_logic;
		 no_winner              : in std_logic
		);
	end component de2lcd;
	
	
	-- VGA signals
	signal pixel_row_int	:	std_logic_vector(9 downto 0);
	signal pixel_col_int	:	std_logic_vector(9 downto 0);
	signal video_on_int	:	std_logic;
	signal VGA_clk_int	:	std_logic;
	signal eof				:	std_logic;
	
	component pll_counter is
        port(
            clk       : in std_logic;
            rst_n     : in std_logic;
            pulse_out : out std_logic
        );
	end component pll_counter;
	
	signal global_we : std_logic;
	signal pulse_out : std_logic;
	
	component speed_control is
		port(
			clk, rst_n		 			: in std_logic;
			speed1, speed2, speed3	: in std_logic;
			tank_speed_in    			: in std_logic_vector(2 downto 0);
			tank_speed_out   			: out std_logic_vector(2 downto 0)
		);
	end component speed_control;
	
begin

	score_1_slv <= std_logic_vector(to_unsigned(score_1_signal, 4));
	score_2_slv <= std_logic_vector(to_unsigned(score_2_signal, 4));
	
	seg_out_1 <= segments_out_signal_1;
	seg_out_2 <= segments_out_signal_2;
	
	no_winner_signal <= '1' when 
	     ((score_1_signal < 3) and (score_2_signal < 3)) 
		   else
				'0';
								
	winner_signal <= '1' when 
			(score_1_signal >= 3) 
			else
				'0';
				
	LCD_RS <= LCD_RS_signal; 
	LCD_E <= LCD_E_signal;
	LCD_ON <= LCD_ON_signal;
	RESET_LED <= RESET_LED_signal;
	SEC_LED <= SEC_LED_signal;
	LCD_RW <= LCD_RW_signal;
	DATA_BUS <= DATA_BUS_signal;

	reset <= not reset_n;
	
	input_proc: process(clk, reset, key_ready, hist1, key_code) is
	begin
	if (reset = '1') then
		tank_1_fire_key <= '0';
		tank_1_speed1_key <= '1';
		tank_1_speed2_key <= '0';
		tank_1_speed3_key <= '0';
		tank_2_fire_key <= '0';
		tank_2_speed1_key <= '1';
		tank_2_speed2_key <= '0';
		tank_2_speed3_key <= '0';
	elsif (rising_edge(clk)) then
		if key_ready = '1' and hist1 /= "11110000" then
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
					tank_1_fire_key 	<= '0';
					tank_1_speed1_key <= '0';
					tank_1_speed2_key <= '0';
					tank_1_speed3_key <= '0';
					tank_2_fire_key 	<= '0';
					tank_2_speed1_key <= '0';
					tank_2_speed2_key <= '0';
					tank_2_speed3_key <= '0';
				end case;
			end if;
		end if;
		
	end process;
	
	pll : pll_counter
        port map(
			clk => clk,
			rst_n => reset_n,
			pulse_out => global_we
		);
	
	vid : pixelGenerator
		port map(
			-- Basic pixel gen stuff
			clk => clk,
			ROM_clk => VGA_clk_int,
			rst_n => reset_n,
			video_on => video_on_int,
			eof => eof,
			pixel_row => pixel_row_int,
			pixel_column => pixel_col_int,
			red_out => VGA_R,
			green_out => VGA_G,
			blue_out => VGA_B,
			
			-- Tank 1 stuff
			tank_1_pos => tank_1_curr_pos,
			tank_1_disp => tank_1_disp_flag,
			tank_1_bul_pos => tank_1_bul_curr_pos,
			tank_1_bul_disp_flag	=> tank_1_bul_disp_flag,
			
			-- Tank 2 stuff
			tank_2_pos => tank_2_curr_pos,
			tank_2_disp => tank_2_disp_flag,
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
			scan_readyo => key_ready,
			hist3 => hist3,
			hist2 => hist2,
			hist1 => hist1,
			hist0 => hist0
		); 
	

   
--	logic : game_update_logic
--		port map(
--			clk => clk,
--			rst_n => reset,
--			global_write_enable => global_we,
--			
--			-- Tank 1 logic
--			tank_1_speed1 => tank_1_speed1_key,
--			tank_1_speed2 => tank_1_speed2_key,
--			tank_1_speed3 => tank_1_speed3_key,
--			tank_1_fire => tank_1_fire_key, 
--			
--			tank_1_pos_in => tank_1_curr_pos,
--			tank_1_pos_out => tank_1_next_pos,
--			tank_1_speed_in => tank_1_curr_speed,
--			tank_1_speed_out => tank_1_next_speed, 
--			tank_1_disp => tank_1_disp_flag,
--			tank_1_bul_pos_in => tank_1_bul_curr_pos,
--			tank_1_bul_pos_out => tank_1_bul_next_pos,
--			tank_1_bul_fired_in => tank_1_bul_curr_fire,
--			tank_1_bul_fired_out => tank_1_bul_next_fire,
--			tank_1_bul_disp => tank_1_bul_disp_flag,
--			tank_1_score => score_1_signal,     
--			
--			-- Tank 2 logic
--			tank_2_speed1 => tank_2_speed1_key,
--			tank_2_speed2 => tank_2_speed2_key,
--			tank_2_speed3 => tank_2_speed3_key,
--			tank_2_fire => tank_2_fire_key,  
--			
--			tank_2_pos_in => tank_2_curr_pos,
--			tank_2_pos_out => tank_2_next_pos,
--			tank_2_speed_in => tank_2_curr_speed,
--			tank_2_speed_out => tank_2_next_speed, 
--			tank_2_disp => tank_2_disp_flag,
--			tank_2_bul_pos_in => tank_2_bul_curr_pos,
--			tank_2_bul_pos_out => tank_2_bul_next_pos,
--			tank_2_bul_fired_in => tank_2_bul_curr_fire,
--			tank_2_bul_fired_out => tank_2_bul_next_fire,
--			tank_2_bul_disp => tank_2_bul_disp_flag,
--			tank_2_score => score_2_signal   
--		);
		
		
		
		tank_1_control : tank_control
			port map(
				clk => clk,
				rst_n => reset,
				we => global_we,
				tank_curr_pos_in   => tank_1_curr_pos,
				tank_next_pos_out   => tank_1_next_pos,
				tank_display     =>  tank_1_disp_flag,
				tank_speed_in    => tank_1_curr_speed
			);
		
		tank_1 : tank_location
			generic map(
				tank_loc => TANK_1_INIT_POS
			)
			port map(
				clk => clk,
				rst_n => reset,
				tank_pos_in => tank_1_next_pos,
				tank_pos_out => tank_1_curr_pos,
				speed_in => tank_1_next_speed,
				speed_out => tank_1_curr_speed
			);
			
		tank_1_speed : speed_control
			port map(
				clk => clk,
				rst_n => reset,
				speed1 => tank_1_speed1_key,
				speed2 => tank_1_speed2_key,
				speed3 => tank_1_speed3_key,
				tank_speed_in => tank_1_curr_speed,
				tank_speed_out => tank_1_next_speed
			);
			
		bullet_1_control : bullet_control
			port map(
				clk => clk,
				rst_n => reset,
				we => global_we,
				tank_pos_in => tank_1_curr_pos,
				fire => tank_1_fire_key,
				bullet_pos_in => tank_1_bul_curr_pos,
				bullet_pos_out => tank_1_bul_next_pos,
				bullet_fired_in => tank_1_bul_curr_fire,
				bullet_fired_out => tank_1_bul_next_fire,
				bullet_disp => tank_1_bul_disp_flag,
				direction => tank_1_bul_dir,
				collision_hit => collision_1_hit
			);
			
			
		bul_1 : bullet_location
			generic map(
				bullet_loc => TANK_1_BULL_INIT_POS
			)
			port map(
				clk => clk,
				rst_n => reset,
				we => global_we,
				bull_pos_in => tank_1_bul_next_pos,
				bull_pos_out => tank_1_bul_curr_pos,
				fired_in => tank_1_bul_next_fire,
				fired_out => tank_1_bul_curr_fire
			);
			
		collision_1 : collision
			port map(
				clk => clk,
				rst_n => reset,
				we => global_we,
				tank_pos_in => tank_2_curr_pos,
				bullet_pos_in => tank_1_bul_curr_pos,
				bullet_fired_in => tank_1_bul_curr_fire,
				collsion_hit => collision_1_hit,
				direction => tank_1_bul_dir
			);
			
		tank_2_control : tank_control
			port map(
				clk => clk,
				rst_n => reset,
				we => global_we,
				tank_curr_pos_in   => tank_2_curr_pos,
				tank_next_pos_out   => tank_2_next_pos,
				tank_display     =>  tank_2_disp_flag,
				tank_speed_in    => tank_2_curr_speed
			);
				
			
		tank_2 : tank_location
			generic map(
				tank_loc => TANK_2_INIT_POS
			)
			port map(
				clk => clk,
				rst_n => reset,
				tank_pos_in => tank_2_next_pos,
				tank_pos_out => tank_2_curr_pos,
				speed_in => tank_2_next_speed,
				speed_out => tank_2_curr_speed
			);
			
		tank_2_speed : speed_control
			port map(
				clk => clk,
				rst_n => reset,
				speed1 => tank_2_speed1_key,
				speed2 => tank_2_speed2_key,
				speed3 => tank_2_speed3_key,
				tank_speed_in => tank_2_curr_speed,
				tank_speed_out => tank_2_next_speed
			);
			
		bullet_2_control : bullet_control
			port map(
				clk => clk,
				rst_n => reset,
				we => global_we,
				tank_pos_in => tank_2_curr_pos,
				fire => tank_2_fire_key,
				bullet_pos_in => tank_2_bul_curr_pos,
				bullet_pos_out => tank_2_bul_next_pos,
				bullet_fired_in => tank_2_bul_curr_fire,
				bullet_fired_out => tank_2_bul_next_fire,
				bullet_disp => tank_2_bul_disp_flag,
				direction => tank_2_bul_dir,
				collision_hit => collision_2_hit
			);
		
		bul_2 : bullet_location
			generic map(
				bullet_loc => TANK_2_BULL_INIT_POS
			)
			port map(
				clk => clk,
				rst_n => reset,
				we => global_we,
				bull_pos_in => tank_2_bul_next_pos,
				bull_pos_out => tank_2_bul_curr_pos,
				fired_in => tank_2_bul_next_fire,
				fired_out => tank_2_bul_curr_fire
			);
			
		collision_2 : collision
			port map(
				clk => clk,
				rst_n => reset,
				we => global_we,
				tank_pos_in => tank_1_curr_pos,
				bullet_pos_in => tank_2_bul_curr_pos,
				bullet_fired_in => tank_2_bul_curr_fire,
				collsion_hit => collision_2_hit,
				direction => tank_2_bul_dir
			);
			
	   score_decoder_1 : leddcd 
		port map(
			data_in => score_1_slv,
			segments_out => segments_out_signal_1
		);
		
		score_decoder_2 : leddcd 
		port map(
			data_in => score_2_slv,
			segments_out => segments_out_signal_2
		);
		
		lcd_message : de2lcd
		port map(
			reset => reset_n,
			clk_50Mhz => clk,
		   LCD_RS => LCD_RS_signal,
			LCD_E => LCD_E_signal,
			LCD_ON => LCD_ON_signal,
			RESET_LED => RESET_LED_signal,
			SEC_LED => SEC_LED_signal,
			LCD_RW => LCD_RW_signal,						
			DATA_BUS	=> DATA_BUS_signal,			
			winner => winner_signal,			
			no_winner => no_winner_signal	
		);
	
end architecture structure;

