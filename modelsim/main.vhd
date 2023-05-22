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
          scoreOnes: out std_logic_vector(6 downto 0);
          scoreTens: out std_logic_vector(6 downto 0)
          );
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
            R, G, B: out std_logic_vector(3 downto 0);

            ScoreOnes, ScoreTens: in std_logic_vector(3 downto 0);
            Lives: unsigned(2 downto 0)
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
            NewY: out signed(9 downto 0);

            HitTopOrBottom: out std_logic;
            
            -- Trigger and output
            Trigger: in std_logic;
            Done: out std_logic;

            Collided: in std_logic
        );
    end component;

    component pipes is
        port(
            PipeClk: in std_logic;
            PipeWidth: out signed(10 downto 0);
            Rand: in std_logic_vector(7 downto 0);
            PipesXValues: out PipesArray;
            TopPipeHeights: out PipesArray;
            BottomPipeHeights: out PipesArray;

            Trigger: in std_logic;
            GameMode: in std_logic;
            ScoreTens: in std_logic_vector(3 downto 0);
            Done: out std_logic := '0'
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
        Trigger: in std_logic;
        Done: out std_logic;
        Collided: out std_logic);
    end component;

    component LFSR is port(
        Clk: in std_logic;
        Reset: in std_logic;
        Rand: out std_logic_vector(7 downto 0)
    );
    end component;

    component score_tracker is port(
        Clk, Reset : in std_logic;
    
        PlayerY: in signed(9 downto 0);
        PlayerX: in signed(10 downto 0);
    
        TopPipeHeight: in PipesArray;
        BottomPipeHeight: in PipesArray;
        PipesXValues: in PipesArray;
        
        -- Trigger and done signals
        Trigger: in std_logic;
        Done: out std_logic;
    
        ScoreOnes: out std_logic_vector(3 downto 0);
        ScoreTens: out std_logic_vector(3 downto 0)
    );
    end component;

    component lives_system is port(
        Clk, Enable, Reset, HasCollided: in std_logic;
        Trigger: in std_logic;
        Done: inout std_logic;
    
        LifeCount: out unsigned(2 downto 0);
        Dead: out std_logic
        );
    end component;

    component BCD_to_SevenSeg is
        port (BCD_digit : in std_logic_vector(3 downto 0);
              SevenSeg_out : out std_logic_vector(6 downto 0));
    end component;

    component game_moore_fsm is port(
        Clk: in std_logic;
        Reset : in std_logic;
        Dead: in std_logic;
        Start: in std_logic;
        Train : in std_logic;
        TryAgain: in std_logic;
        GameRunning: out std_logic;
        TrainingStatus: out std_logic;
        GameOver: out std_logic);
    end component game_moore_fsm;


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
    signal Rand: std_logic_vector(7 downto 0);

    -- score traker variables
    signal scoreOnesSignal: std_logic_vector(3 downto 0);
    signal scoreTensSignal: std_logic_vector(3 downto 0);

    -- Lives
    signal Lives: unsigned(2 downto 0);
    
    
    -- Trigger signals
    signal UpdateSignal, 
           FinishedPlayerUpdate, 
           FinishedPipeUpdate, 
           FinishedCollisionUpdate: std_logic;
    
    -- State Machine + Other Stateful Signals
    signal Collided, Invincible, Dead: std_logic;
    signal ResetStateMachine, Start, Train, TryAgain : std_logic;
    -- 1 = GameRunning, 0 = game not running
    signal GameRunning : std_logic;
    -- Training mode = 1, Normal mode = 0
    signal TrainingStatus : std_logic;
    -- 1 = Player has run out of lives.
    signal GameOver : std_logic;

begin

    VGA_CLOCK: process(Clk)
        variable v_25MHzClk: std_logic := '0';
    begin
        if rising_edge(Clk) then
            v_25MHzClk := not v_25MHzClk;
        end if;

        Clk25MHz <= v_25MHzClk;
    end process;

    UpdateSignal <= '1' when unsigned(VGARow) = 479 else '0';

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
                          B => B,
                          
                          ScoreOnes => scoreOnesSignal,
                          ScoreTens => scoreTensSignal,
                          
                          Lives => Lives);

    C2: vga_sync port map(clock_25Mhz => Clk25MHz,
                          red => R, green => G, blue => B,
                          red_out => VgaRedOut, green_out => VgaGreenOut, blue_out => VgaBlueOut,
                          horiz_sync_out => VgaHSync, vert_sync_out => VSync,
                          pixel_column => VgaCol, pixel_row => VgaRow
    );

    VgaVSync <= VSync;

    C3: player_update port map(Clk => Clk,
                               Reset => '0',
                               LeftMouseButton => LeftMouseButton,
                               NewX => PlayerX,
                               NewY => PlayerY,

                               HitTopOrBottom => open,

                               Trigger => UpdateSignal and GameRunning,
                               Done => FinishedPlayerUpdate,

                               Collided => Collided
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

    C5: pipes port map(
        PipeClk => Clk,
        PipeWidth => PipeWidth,
        PipesXValues => PipesXValues,
        Rand => Rand,
        TopPipeHeights => TopPipeHeights,
        BottomPipeHeights => BottomPipeHeights,
        Trigger => UpdateSignal and GameRunning,
        GameMode => TrainingStatus,
        ScoreTens => scoreTensSignal,
        Done => FinishedPipeUpdate
    );

    C6: collision port map(Clk => Clk,
                           PlayerX => PlayerX,
                           PlayerY => PlayerY,
                           PipesX => PipesXValues,
                           TopPipeHeight => TopPipeHeights,
                           BottomPipeHeight => BottomPipeHeights,
                           Trigger => FinishedPipeUpdate and FinishedPlayerUpdate,
                           Done => FinishedCollisionUpdate,
                           Collided => Collided
    );

    C7: LFSR port map (
        clk => Clk,
        Reset => RandomReset,
        Rand => Rand
    );

    C8: score_tracker port map(
        Clk => Clk, 
        Reset => Dead,
        PlayerX => PlayerX,
        PlayerY => PlayerY,
        TopPipeHeight => TopPipeHeights,
        BottomPipeHeight => BottomPipeHeights,
        PipesXValues => PipesXValues,
        -- Trigger and output 
        Trigger => FinishedCollisionUpdate,
        Done => open,
        -- Todo: change score
        ScoreOnes =>  scoreOnesSignal,
        ScoreTens => scoreTensSignal
    );

    C9: BCD_to_SevenSeg port map (
        BCD_digit => scoreOnesSignal,
        SevenSeg_out => scoreOnes
    );

    C10: BCD_to_SevenSeg port map (
        BCD_digit => scoreTensSignal,
        SevenSeg_out => scoreTens
    );

    C11: lives_system port map(
        Clk => Clk,
        Enable => '1',
        Reset => not pushbutton,
        HasCollided => Collided,
        Trigger => FinishedCollisionUpdate,
        Done => open,
        LifeCount => Lives,
        Dead => Dead
	);

    C12: game_moore_fsm port map(
        Clk => Clk,
        Reset => ResetStateMachine,
        Dead => Dead,
        Start => Start,
        Train => Train,
        TryAgain => TryAgain,
        GameRunning => GameRunning,
        TrainingStatus => TrainingStatus,
        GameOver => GameOver
    );
end architecture;
