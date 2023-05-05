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
        R, G, B: out std_logic_vector(3 downto 0)


    );
end entity renderer;

architecture behave of renderer is
    component sprite_rom is
        generic(sprite_file: string);

        port(SpriteRow, SpriteCol	:	in std_logic_vector (2 downto 0);
             Clk				: 	in std_logic;
             Red, Green, Blue : out std_logic_vector(3 downto 0);
             Visible: out std_logic
        );
    end component;

    -- Constants
    -- TODO: Make this more accessible
    constant BirdWidth: signed(10 downto 0) := to_signed(8, 11);
    constant BirdHeight: signed(9 downto 0) := to_signed(8, 10);

    
    signal EnableBird, BirdVisible: std_logic;
    signal BirdR, BirdG, BirdB: std_logic_vector(3 downto 0);
    signal BirdRow, BirdCol: std_logic_vector (2 downto 0) := (others => '0');

    signal EnablePipe: std_logic;
begin

    BIRD_ROM: sprite_rom generic map("BRD_ROM.mif") 
                         port map(Clk => Clk,
                                  SpriteRow => BirdRow,
                                  SpriteCol => BirdCol,
                                  Red => BirdR,
                                  Green => BirdG,
                                  Blue => BirdB,
                                  Visible => BirdVisible
                         );
                         
    BIRD_READER: process(Clk)
        variable v_Enable: std_logic;
        variable v_Row, v_Col: unsigned(2 downto 0); 
    begin

        if rising_edge(Clk) then
            if signed(VgaRow) >= PlayerY and
               signed('0' & VgaCol) >= PlayerX and 
               signed(VgaRow) <= PlayerY + constants.BIRD_WIDTH and 
               signed('0' & VgaCol) <= PlayerX + constants.BIRD_HEIGHT  then
                v_Enable := '1' and BirdVisible;
                v_Row := resize(shift_right(unsigned(VgaRow) - unsigned('0' & PlayerX), 2), 3);
                v_Col := resize(shift_right(unsigned(VgaCol) - unsigned('0' & PlayerY), 2), 3);
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

    PIPE_RENDERER: process(Clk)
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


    RENDER_ALL: process(EnableBird, EnablePipe, BirdR, BirdG, BirdB)
    begin

        if EnableBird = '1' then
            R <= BirdR; G <= BirdG; B <= BirdB;
        elsif EnablePipe = '1' then
            R <= (others => '0'); G <= (others => '1'); B <= (others => '0');
        else
            R <= (others => '0'); G <= (others => '0'); B <= (others => '0');
        end if;
    end process;

end architecture;