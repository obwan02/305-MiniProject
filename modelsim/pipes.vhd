library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity pipes is
    port(
        PipeCreationClk: in std_logic;
        PipeWidth: out signed(9 downto 0);
        PipesXValues: out PipesArray(3 downto 0);
        TopPipeHeights: out PipesArray(3 downto 0);
        BottomPipeHeights: out PipesArray(3 downto 0)
    );
end entity pipes;

architecture construction of pipes is
begin
    process(PipeCreationClk)
    variable v_PipesXValues: PipesArray(3 downto 0);
    variable v_TopPipeHeights: PipesArray(3 downto 0);
    variable v_BottomPipeHeights: PipesArray(3 downto 0);
    constant RightMostPixel: signed(9 downto 0) := to_signed(800, 10);
    constant speed: signed(9 downto 0) := to_signed(1, 10);
    constant TempHeight: signed(9 downto 0) := to_signed(200, 10);
    begin
        if rising_edge(PipeCreationClk) then
            
            for i in 0 to 3 loop
                if (v_PipesXValues(i) <= 0) then
                    v_PipesXValues(i) := RightMostPixel;
                else
                    v_PipesXValues(i) := v_PipesXValues(i) - speed;
                end if;
            end loop; 

            for j in 0 to 3 loop
                v_BottomPipeHeights(j) := TempHeight;
                v_TopPipeHeights(j) := TempHeight;
            end loop;
            BottomPipeHeights <= v_BottomPipeHeights;
            TopPipeHeights <= v_TopPipeHeights;
            PipesXValues <= v_PipesXValues;

        end if;
    end process;

end architecture;
