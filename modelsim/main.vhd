library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity main is
    port (Clk: in std_logic;
          -- temp
          pushbutton : in std_logic;
          -- VGA Shit
          VgaRedOut, VgaGreenOut, VgaBlueOut: out std_logic_vector(3 downto 0);
          VgaHSync, VgaVSync: out std_logic;
          -- Mouse Shit
          MouseClk, MouseData: inout std_logic;
          DebugLight: out std_logic;
          --temp
          tempLight: out std_logic);
end entity main;

architecture behave of main is
    component renderer is
        port (
            Clk   : in std_logic;
            Reset : in std_logic;
    
            PlayerX: in signed(10 downto 0);
            PlayerY: in signed(9 downto 0);
    
            -- pipe Arrays
            PipeWidth: in signed(10 downto 0);
            PipesXValues: in PipesArray;
            TopPipeHeights: in PipesArray;
            BottomPipeHeights: in PipesArray;

            VgaRow, VgaCol: in std_logic_vector(9 downto 0);
            R, G, B: out std_logic_vector(3 downto 0)
        );
    end component;

    component vga_sync is
    port(clock_25Mhz: in std_logic;
         red, green, blue: in std_logic_vector(3 downto 0);
         red_out, green_out, blue_out: out std_logic_vector(3 downto 0);
         horiz_sync_out, vert_sync_out: out std_logic;
         pixel_row, pixel_column: out std_logic_vector(9 DOWNTO 0));
    end component;

    component player_update is
        port (
            Clk   : in std_logic;
            Reset : in std_logic;
    
            LeftMouseButton: in std_logic;
    
            NewX: out signed(10 downto 0);
            NewY: out signed(9 downto 0)
        );
    end component;

    component pipes is
        port(
            PipeClk: in std_logic;
            PipeWidth: out signed(10 downto 0);
            RandomHeights: in PipesArray;
            PipesXValues: out PipesArray;
            TopPipeHeights: out PipesArray;
            BottomPipeHeights: out PipesArray

        );
    end component;

    component mouse IS
    PORT(clock_25Mhz, reset 		: IN std_logic;
         mouse_data					: INOUT std_logic;
         mouse_clk 					: INOUT std_logic;
         left_button, right_button	: OUT std_logic;
		 mouse_cursor_row 			: OUT std_logic_vector(9 DOWNTO 0); 
		 mouse_cursor_column 		: OUT std_logic_vector(9 DOWNTO 0));       	
    end component;

    component collision is port(
        Clk: in std_logic;
        PlayerX: in signed(10 downto 0);
        PlayerY: in signed(9 downto 0);
        PipesX: in PipesArray;
        TopPipeHeight: in PipesArray;
        BottomPipeHeight: in PipesArray;
        Collided: out std_logic);
    end component;

    component LFSR is port(
        Clk: in std_logic;
        Reset: in std_logic;
        Random7BitNumbersArray: out PipesArray
    );
    end component;

    signal VSync: std_logic;
    signal VgaRow, VgaCol: std_logic_vector(9 downto 0);
    signal R, G, B: std_logic_vector(3 downto 0);
    signal Clk25MHz: std_logic;

    signal PlayerX: signed(10 downto 0);
    signal PlayerY: signed(9 downto 0);

    signal LeftMouseButton: std_logic;

    --Pipes Variables
    signal PipesXValues: PipesArray;
    signal TopPipeHeights: PipesArray;
    signal BottomPipeHeights: PipesArray;
    signal PipeWidth: signed(10 downto 0);

    --Random generator variables
    signal RandomReset: std_logic;
    signal RandomNumbers: PipesArray;
begin

    VGA_CLOCK: process(Clk)
        variable v_25MHzClk: std_logic := '0';
    begin
        if rising_edge(Clk) then
            v_25MHzClk := not v_25MHzClk;
        end if;

        Clk25MHz <= v_25MHzClk;
    end process;

    C1: renderer port map(Clk => Clk, 
                          Reset => '0', 
                          PlayerX =>  PlayerX, 
                          PlayerY => PlayerY, 
                          --Pipes
                          PipeWidth => PipeWidth,
                          PipesXValues => PipesXValues,
                          TopPipeHeights => TopPipeHeights,
                          BottomPipeHeights => BottomPipeHeights,

                          VgaRow => VgaRow,
                          VgaCol => VgaCol,
                          R => R,
                          G => G,
                          B => B);

    C2: vga_sync port map(clock_25Mhz => Clk25MHz,
                          red => R, green => G, blue => B,
                          red_out => VgaRedOut, green_out => VgaGreenOut, blue_out => VgaBlueOut,
                          horiz_sync_out => VgaHSync, vert_sync_out => VSync,
                          pixel_column => VgaCol, pixel_row => VgaRow
    );

    VgaVSync <= VSync;

    C3: player_update port map(Clk => VSync,
                               Reset => '0',
                               LeftMouseButton => LeftMouseButton,
                               NewX => PlayerX,
                               NewY => PlayerY
    );


    C4: mouse port map(clock_25Mhz => Clk25MHz,
                       Reset => '0',
                       Mouse_Data => MouseData,
                       Mouse_Clk => MouseClk,
                       Left_Button => LeftMouseButton,
                       right_button => open,
                       mouse_cursor_row => open,
                       mouse_cursor_column => open
    );

    DebugLight <= LeftMouseButton;

    C5: pipes port map(
        PipeClk => VSync,
        PipeWidth => PipeWidth,
        PipesXValues => PipesXValues,
        RandomHeights => RandomNumbers,
        TopPipeHeights => TopPipeHeights,
        BottomPipeHeights => BottomPipeHeights
    );

    C6: collision port map(Clk => Clk,
                           PlayerX => PlayerX,
                           PlayerY => PlayerY,
                           PipesX => PipesXValues,
                           TopPipeHeight => TopPipeHeights,
                           BottomPipeHeight => BottomPipeHeights,
                           Collided => open
    );

    C7: LFSR port map (
        clk => Clk,
        Reset => RandomReset,
        Random7BitNumbersArray => RandomNumbers
    );
    
    tempLight <= not(pushbutton);

end architecture;