library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;
use work.constants;

entity pipes is
    port(
        PipeClk: in std_logic;
        PipeWidth: out signed(10 downto 0);
        PipesXValues: out PipesArray;
        TopPipeHeights: out PipesArray;
        BottomPipeHeights: out PipesArray
    );
end entity pipes;


architecture construction of pipes is
begin

    PipeWidth <= to_signed(constants.PIPE_WIDTH, 11);

    process(PipeClk)
    variable v_PipesXValues: PipesArray := (to_signed(100, 11), 
                                            to_signed(300, 11), 
                                            to_signed(500, 11),  
                                            to_signed(700, 11));
    variable v_TopPipeHeights: PipesArray;
    variable v_BottomPipeHeights: PipesArray;

    constant RightMostPixel: signed(10 downto 0) := to_signed(800, 11);
    constant Speed: signed(9 downto 0) := to_signed(1, 10);
    constant TempHeight: signed(10 downto 0) := to_signed(200, 11);
    begin
        if falling_edge(PipeClk) then
            
            -- TODO: Make this number a constant
            for i in 0 to 3 loop
                if (v_PipesXValues(i) + constants.PIPE_WIDTH <= 0) then
                    v_PipesXValues(i) := RightMostPixel;
                else
                    v_PipesXValues(i) := v_PipesXValues(i) - Speed;
                end if;
            end loop; 

            for j in 0 to 3 loop
                v_BottomPipeHeights(j) := TempHeight;
                v_TopPipeHeights(j) := TempHeight;
            end loop;
        end if;

        BottomPipeHeights <= v_BottomPipeHeights;
        TopPipeHeights <= v_TopPipeHeights;
        PipesXValues <= v_PipesXValues;
    end process;

end architecture;
