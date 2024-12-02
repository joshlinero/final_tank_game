library IEEE;

use IEEE.std_logic_1164.all;

entity VGA_top_level is
    port(
        CLOCK_50                                      : in std_logic;  -- 50 MHz clock
        RESET_N                                       : in std_logic;  -- Active-low reset
        
        -- VGA Outputs
        VGA_RED, VGA_GREEN, VGA_BLUE                 : out std_logic_vector(7 downto 0);
        HORIZ_SYNC, VERT_SYNC, VGA_BLANK, VGA_CLK    : out std_logic;
        
        -- Keyboard Inputs
        keyboard_clk, keyboard_data                  : in std_logic
    );
end entity VGA_top_level;

architecture structural of VGA_top_level is

    -- Component Declarations
    component pixelGenerator is
        port(
            clk, ROM_clk, rst_n, video_on, eof        : in std_logic;
            pixel_row, pixel_column                  : in std_logic_vector(9 downto 0);
            red_out, green_out, blue_out             : out std_logic_vector(7 downto 0);
            keyboard_clk, keyboard_data              : in std_logic
        );
    end component pixelGenerator;

    component VGA_SYNC is
        port(
            clock_50Mhz                               : in std_logic;
            horiz_sync_out, vert_sync_out, 
            video_on, pixel_clock, eof               : out std_logic;
            pixel_row, pixel_column                  : out std_logic_vector(9 downto 0)
        );
    end component VGA_SYNC;

    -- Signals for VGA sync
    signal pixel_row_int                             : std_logic_vector(9 downto 0);
    signal pixel_column_int                          : std_logic_vector(9 downto 0);
    signal video_on_int                              : std_logic;
    signal VGA_clk_int                               : std_logic;
    signal eof_int                                   : std_logic;

    -- Signals for Pixel Generator
    --signal red_out_int, green_out_int, blue_out_int  : std_logic_vector(7 downto 0);

begin

    --------------------------------------------------------------------------------------------
    -- Pixel Generator Instance
    videoGen : pixelGenerator
        port map(
            clk            => CLOCK_50,                -- System clock
            ROM_clk        => VGA_clk_int,            -- VGA pixel clock
            rst_n          => RESET_N,                -- Active-low reset
            video_on       => video_on_int,           -- Video enable signal
            eof            => eof_int,                -- End-of-frame signal
            pixel_row      => pixel_row_int,          -- Current row
            pixel_column   => pixel_column_int,       -- Current column
            red_out        => VGA_RED,            -- Red output
            green_out      => VGA_GREEN,          -- Green output
            blue_out       => VGA_BLUE,           -- Blue output
            keyboard_clk   => keyboard_clk,           -- Keyboard clock
            keyboard_data  => keyboard_data           -- Keyboard data
        );

    --------------------------------------------------------------------------------------------
    -- VGA Sync Instance
    videoSync : VGA_SYNC
        port map(
            clock_50Mhz     => CLOCK_50,              -- System clock
            horiz_sync_out  => HORIZ_SYNC,            -- Horizontal sync
            vert_sync_out   => VERT_SYNC,             -- Vertical sync
            video_on        => video_on_int,          -- Video enable
            pixel_clock     => VGA_clk_int,           -- Pixel clock
            eof             => eof_int,               -- End-of-frame signal
            pixel_row       => pixel_row_int,         -- Current row
            pixel_column    => pixel_column_int       -- Current column
        );

    --------------------------------------------------------------------------------------------
    -- VGA Output Assignments
    --VGA_RED   <= red_out_int;
    --VGA_GREEN <= green_out_int;
    --VGA_BLUE  <= blue_out_int;
    VGA_BLANK <= video_on_int;
    VGA_CLK   <= VGA_clk_int;

end architecture structural;
