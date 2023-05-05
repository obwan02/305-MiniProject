library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;
use work.types.all;
use work.constants;

-- Screen size of 640x480

entity renderer is
    port (
        Clk   : in std_logic;
        Reset : in std_logic;

        PlayerX: in signed(10 downto 0);
        PlayerY: in signed(9 downto 0);

        --Pipe arrays
        PipeWidth: in signed(10 downto 0);
        PipesXValues: in PipesArray;
        TopPipeHeights: in UnsignedPipesArray;
        BottomPipeHeights: in PipesArray;

        VgaRow, VgaCol: in std_logic_vector(9 downto 0);
        R, G, B: out std_logic_vector(3 downto 0);

        Score: in unsigned(15 downto 0)
    );
end entity;

architecture behave of renderer is
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

    -- Constants
    -- TODO: Make this more accessible
    constant BirdWidth: signed(10 downto 0) := to_signed(8, 11);
    constant BirdHeight: signed(9 downto 0) := to_signed(8, 10);

    -- Below are all the signals required to display the bird
    --
    -- EnableBird is used in the RENDER_ALL process
    -- to tell us wether or not we should display the bird,
    -- 
    -- BirdVisible is output by the ROM and tells us if a pixel
    -- is transparent or not.
    --
    -- BirdR, BirdG and BirdB are the colour outputs from the ROM
    --
    -- BirdRow and BirdCol are the inputs to the sprite ROM and tells
    -- the ROM which pixel colour we want to select
    signal EnableBird, BirdVisible: std_logic;
    signal BirdR, BirdG, BirdB: std_logic_vector(3 downto 0);
    signal BirdRow, BirdCol: std_logic_vector (4 downto 0) := (others => '0');

    -- These are the signals used for the pipes
    --
    -- EnablePipe tells the RENDER_ALL process if a pipe should be 
    -- visible.
    signal EnablePipe: std_logic;

    -- These are the signals used for the background sprite
    signal BackgroundR, BackgroundG, BackgroundB: std_logic_vector(3 downto 0);
    signal BackgroundRow, BackgroundCol: std_logic_vector (4 downto 0) := (others => '0');


    -- Signal for text
    signal TextVisible: std_logic;
begin

    BIRD_ROM: sprite_rom generic map(Sprite_File => "ROM/BRD3_ROM.mif",
                                     Addr_Width => 5) 
                         port map(Clk => Clk,
                                  SpriteRow => BirdRow,
                                  SpriteCol => BirdCol,
                                  Red => BirdR,
                                  Green => BirdG,
                                  Blue => BirdB,
                                  Visible => BirdVisible
                         );

    BGKGRD_ROM: sprite_rom generic map(
        Sprite_File => "ROM/REAL_BACK.mif",
        Addr_Width => 5)
    port map(Clk => Clk,
            SpriteRow => BackgroundRow,
            SpriteCol => BackgroundCol,
            Red => BackgroundR,
            Green => BackgroundG,
            Blue => BackgroundB,
            Visible => open
    );
                         
    BIRD_RENDER: process(Clk)
        variable v_Enable: std_logic;
        variable v_Row, v_Col: unsigned(4 downto 0); 
    begin

        if rising_edge(Clk) then
            if signed(VgaRow) >= PlayerY and
               signed('0' & VgaCol) >= PlayerX and 
               signed(VgaRow) <= PlayerY + constants.BIRD_WIDTH and 
               signed('0' & VgaCol) <= PlayerX + constants.BIRD_HEIGHT  then
                -- Only enable the bird if the pixel isn't transparent
                v_Enable := '1' and BirdVisible;
                -- Here, we need to quadruple the size of the bird, as the sprite in ROM
                -- is only 8x8 pixels.
                -- To do this, we divide the rows and cols by 4.
                v_Row := resize(unsigned(VgaRow) - unsigned('0' & PlayerY), 5);
                v_Col := resize(unsigned(VgaCol) - unsigned('0' & PlayerX), 5);
            else
                v_Enable := '0';
                v_Row := (others => '0');
                v_Col := (others => '0');
            end if;
        end if;

        EnableBird <= v_Enable;
        BirdRow <= std_logic_vector(v_Row);
        BirdCol <= std_logic_vector(v_Col);
        
    end process;

    PIPE_RENDER: process(Clk)
        -- We need to store the output of each individual pipes 'enable'
        -- signal, otherwise, only the last pipe will be shown on the screen
        variable v_PipePixelEnable: std_logic_vector(constants.PIPE_MAX_INDEX downto 0);
        begin
            if rising_edge(Clk) then
                for i in 0 to constants.PIPE_MAX_INDEX loop
                    if (unsigned(VgaRow) <= TopPipeHeights(i) or 
                        signed(VgaRow) >= (constants.SCREEN_HEIGHT - BottomPipeHeights(i))) and
                        signed('0' & VgaCol) >= PipesXValues(i) and
                        signed('0' & VgaCol) <= PipesXValues(i) + PipeWidth 
                    then
                        v_PipePixelEnable(i) := '1';
                    else
                        v_PipePixelEnable(i) := '0';      
                    end if;
                end loop;
            end if;

            -- Show a pipe if any pipe is enabled
            EnablePipe <= or_reduce(v_PipePixelEnable);

    end process;

	SCORE_TEXT: text_renderer generic map("SCORE", 1) port map(Clk => Clk,
                                                               X => to_signed(16, 11),
                                                               Y => to_signed(16, 10),
                                                               VgaCol => VgaCol,
                                                               VgaRow => VgaRow,
                                                               Visible => TextVisible);

    BackgroundRow <= VgaRow(5 downto 1);
    BackgroundCol <= VgaCol(5 downto 1);


    RENDER_ALL: process(EnableBird, EnablePipe, BirdR, BirdG, BirdB, BackgroundR, BackgroundG, BackgroundB, TextVisible)
    begin
        -- This process decides which items
        -- should be rendered for the current 
        -- pixel, given which items are being drawn
        -- atm.
        if TextVisible = '1' then
            R <= (others => '1'); G <= (others => '1'); B <= (others => '1');
        elsif EnableBird = '1' then
            R <= BirdR; G <= BirdG; B <= BirdB;
        elsif EnablePipe = '1' then
            R <= (others => '0'); G <= (others => '1'); B <= (others => '0');
        else
            R <= BackgroundR; G <= BackgroundG; B <= BackgroundB;
        end if;
    end process;

end architecture;
