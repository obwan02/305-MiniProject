library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity menus is port(
    Clk, GameRunning, TrainSwitch, LeftMouseButton : in std_logic;
    VGARow, VGACol                                           : in unsigned(9 downto 0);
    Score                                                    : in unsigned(9 downto 0);
    MouseRow, MouseCol                    : in unsigned(9 downto 0); 
    BackgroundR, BackgroundG, BackgroundB                    : in std_logic_vector(3 downto 0);
    ScoreOnes, ScoreTens: in std_logic_vector(3 downto 0);
    R, G, B                                                  : out std_logic_vector(3 downto 0);
    Start, Train                                   : out std_logic;
    DebugLight : out std_logic);
end entity menus;

architecture behaviour of menus is
    
    component sprite_rom is
        generic(sprite_file: string;
                addr_width: natural := 3);

        port(SpriteRow, SpriteCol	:	in std_logic_vector (ADDR_WIDTH-1 downto 0);
             Clk				: 	in std_logic;
             Red, Green, Blue : out std_logic_vector(3 downto 0);
             Visible: out std_logic
        );
    end component;

    component text_renderer is 
        generic(STR: string;
                SIZE: natural);
        port(Clk: in std_logic;
             X: in signed(10 downto 0);
             Y: in signed(9 downto 0);
             VgaCol, VgaRow: in std_logic_vector(9 downto 0);
    
             Visible: out std_logic
             );
    end component;

    component bcd_renderer is 
        generic(SIZE: natural);
        port(Clk: in std_logic;
            X: in signed(10 downto 0);
            Y: in signed(9 downto 0);
            VgaCol, VgaRow: in std_logic_vector(9 downto 0);

            ScoreOnes, ScoreTens: std_logic_vector(3 downto 0);

            Visible: out std_logic
            );
    end component bcd_renderer;
    

    signal MouseR, MouseG, MouseB: std_logic_vector(3 downto 0);
    signal CursorRow, CursorCol: std_logic_vector (3 downto 0) := (others => '0');
    signal ShowCursor, CursorVisible: std_logic;

    signal StartR, StartG, StartB: std_logic_vector(3 downto 0);
    signal StartEnable: std_logic;
    signal s_Start: std_logic := '0';

    signal ModeSelR, ModeSelG, ModeSelB: std_logic_vector(3 downto 0);

    signal TrainTextVisible: std_logic;
    signal NormalTextVisible: std_logic;
    signal TopScoreTextVisible: std_logic;
    signal ScoreNumberEnable: std_logic;

begin
    CURSOR_ROM: sprite_rom generic map(Sprite_File => "ROM/CURSOR_ROM.mif",
                                       Addr_Width => 4)
                           port map(Clk => Clk,
                                    SpriteRow => CursorRow,
                                    SpriteCol => CursorCol,
                                    Red => MouseR,
                                    Green => MouseG,
                                    Blue => MouseB,
                                    Visible => CursorVisible);


    DRAW_ORDER: process (ShowCursor, MouseR, MouseG, MouseB, StartEnable, StartR, 
    StartG, StartB, BackgroundR, BackgroundG, BackgroundB, 
    ModeSelR, ModeSelG, ModeSelB, GameRunning)
    begin
        -- Enable Bits, state whether the bit should be shown
        if GameRunning /= '1' then 
            if ShowCursor = '1' then
                R <= MouseR;
                G <= MouseG;
                B <= MouseB;
            elsif TrainTextVisible = '1' or TopScoreTextVisible = '1' or NormalTextVisible = '1'  or ScoreNumberEnable = '1' then
                R <= (others => '1'); G <= (others => '1'); B <= (others => '1');
            elsif StartEnable = '1' then
                R <= StartR;
                G <= StartG;
                B <= StartB;
            else
                R <= BackgroundR;
                G <= BackgroundG;
                B <= BackgroundB;
            end if;
        else
            R <= (others => '0'); G <= (others => '0'); B <= (others => '0');
        end if;
end process;

-- Handle mouse events for button presses (initial menu and game over menu)
MOUSE_RENDER: process (VGARow, VGACol, MouseRow, MouseCol, CursorVisible, GameRunning)
    variable v_Enable: std_logic;
    variable v_Row, v_Col: unsigned(3 downto 0); 
begin
    if VGARow >= MouseRow and
    VGACol >= MouseCol and
    VGARow < MouseRow + 16 and
    VGACol < MouseCol + 16 then
        v_Enable := ('1' and CursorVisible and not(GameRunning));
        v_Row := resize(VGARow - MouseRow, 4);
        v_Col := resize(VGACol - MouseCol, 4);
    else
        v_Enable := '0';
        v_Row := (others => '0');
        v_Col := (others => '0');
    end if;

    ShowCursor <= v_Enable;
    CursorRow <= std_logic_vector(v_Row);
    CursorCol <= std_logic_vector(v_Col);
end process;


TEXT1: text_renderer generic map("TRAINING", 2) port map(
                                        Clk => Clk,
                                        VgaCol => std_logic_vector(VgaCol),
                                        VgaRow => std_logic_vector(VgaRow),
                                        X => to_signed(316, 11),
                                        Y => to_signed(270, 10),
                                        Visible => TrainTextVisible

);

TEXT2: text_renderer generic map("NORMAL", 2) port map(
    Clk => Clk,
    VgaCol => std_logic_vector(VgaCol),
    VgaRow => std_logic_vector(VgaRow),
    X => to_signed(320, 11),
    Y => to_signed(130, 10),
    Visible => NormalTextVisible

);


TOPSCORE: text_renderer generic map("TOPSCORE", 2) port map(
    Clk => Clk,
    VgaCol => std_logic_vector(VgaCol),
    VgaRow => std_logic_vector(VgaRow),
    X => to_signed(290, 11),
    Y => to_signed(400, 10),
    Visible => TopScoreTextVisible

);

-- Render the score on the menu
SCORE_RENDER: bcd_renderer generic map(2) port map(Clk => Clk,
    X => to_signed(430, 11),
    Y => to_signed(400, 10),
    VgaCol => std_logic_vector(VgaCol),
    VgaRow => std_logic_vector(VgaRow),
    Visible => ScoreNumberEnable,
    ScoreOnes => ScoreOnes,
    ScoreTens => ScoreTens);

RENDER_START : process(Clk)
    variable v_Enable: std_logic;
    variable v_Start: std_logic := '0';
    variable v_StartR, v_StartG, v_StartB: std_logic_vector(3 downto 0);
begin
if rising_edge(Clk) then
    if GameRunning = '0' then
        -- Code for inital start menu
        -- Draw blue rectangle

            StartEnable <= '0';

            -- Draw Second rectangle for button
            if VGACol >= 259 and VGACol <= 500
            and VGARow >= 100 and VGARow <= 175 then
                StartEnable <= '1';
                if MouseCol >= 259 and MouseCol <= 500
                and MouseRow >= 100 and MouseRow <= 175 then 
                    
                    v_StartR := "0110";
                    v_StartG := "0110";
                    v_StartB := "1110";
                    if LeftMouseButton = '1' then
                        v_Start := '1';
                        Train <= '0';
                    end if;
                else
                    v_StartR := "1110";
                    v_StartG := "1001";
                    v_StartB := "0001";
                end if;
            end if;



            -- Draw Second rectangle for button
            if VGACol >= 259 and VGACol <= 500
            and VGARow >= 240 and VGARow <= 315 then
                StartEnable <= '1';
                if MouseCol >= 259 and MouseCol <= 500
                and MouseRow >= 240 and MouseRow <= 315 then 
                    
                    v_StartR := "0110";
                    v_StartG := "0110";
                    v_StartB := "1110";
                    if LeftMouseButton = '1' then
                        v_Start := '1';
                        Train <= '1';
                    end if;
                else
                    v_StartR := "1110";
                    v_StartG := "1001";
                    v_StartB := "0001";
                end if;
            end if;

        end if;
    end if;

    if GameRunning = '1' then 
        v_Start := '0';
    end if;

    Start <= v_Start;
    DebugLight <= v_Start;
    StartR <= v_StartR; StartG <= v_StartG; StartB <= v_StartB;
end process;


end architecture;
