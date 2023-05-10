library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.types.all;
use work.constants;

entity pipes is
    port(
        PipeClk: in std_logic;
        PipeWidth: out signed(10 downto 0);
        RandomHeights: in PipesArray;
        PipesXValues: out PipesArray;
        TopPipeHeights: out PipesArray;
        BottomPipeHeights: out PipesArray
    );
end entity pipes;


architecture construction of pipes is
begin

    PipeWidth <= to_signed(constants.PIPE_WIDTH, 11);

    process(PipeClk)
    variable v_PipesXValues: PipesArray := (to_signed(600, 11), 
                                            to_signed(900, 11), 
                                            to_signed(1200, 11),  
                                            to_signed(1500, 11));
    variable v_TopPipeHeights: PipesArray;
    variable v_BottomPipeHeights: PipesArray;

    constant RightMostPixel: signed(10 downto 0) := to_signed(800, 11);
    constant Speed: signed(9 downto 0) := to_signed(3, 10);
    constant TempHeight: signed(10 downto 0) := to_signed(100, 11);
    begin
        if rising_edge(PipeClk) then
            for i in 0 to constants.PIPE_MAX_INDEX loop
                if (v_PipesXValues(i) + constants.PIPE_WIDTH <= 0) then
                    v_PipesXValues(i) := RightMostPixel;

                    --asign the randomly generated heigt to the top pipes
                    v_TopPipeHeights(i) := RandomHeights(i);

                    -- find the bottom piprd height
                    v_BottomPipeHeights(i) := constants.SCREEN_HEIGHT - (RandomHeights(i) + 200);
                    
                else
                    v_PipesXValues(i) := v_PipesXValues(i) - Speed;
                end if;
            end loop; 
        end if;

        BottomPipeHeights <= v_BottomPipeHeights;
        TopPipeHeights <= v_TopPipeHeights;
        PipesXValues <= v_PipesXValues;
    end process;

end architecture;
