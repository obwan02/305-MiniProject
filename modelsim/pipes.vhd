library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.types.all;
use work.constants;

entity pipes is
    port(
        PipeClk: in std_logic;
        PipeWidth: out signed(10 downto 0);
        Rand: in std_logic_vector(7 downto 0);
        PipesXValues: out PipesArray;
        TopPipeHeights: out PipesArray;
        BottomPipeHeights: out PipesArray;

        Trigger: in std_logic;
        Done: out std_logic := '0'
    );
end entity pipes;


architecture construction of pipes is
begin

    PipeWidth <= to_signed(constants.PIPE_WIDTH, 11);

    UPDATE: process(PipeClk)
        constant RightMostPixel: signed(10 downto 0) := to_signed(640, 11);
        constant Speed: signed(9 downto 0) := to_signed(2, 10);
        constant TempHeight: signed(10 downto 0) := to_signed(100, 11);

        variable v_Index: unsigned(2 downto 0);
        variable v_PrevTrigger, v_Processing: std_logic := '0';


        variable v_PipesXValues: PipesArray := (to_signed(100, 11), 
                                                to_signed(200 + 80, 11), 
                                                to_signed(300 + 160, 11),  
                                                to_signed(400 + 240, 11));
    begin
        if rising_edge(PipeClk) then

            if v_PrevTrigger /= Trigger then
                v_Index := (others => '0');
                Done <= '0';
    
                if Trigger = '1' then 
                    v_Processing := '1';
                end if;
            end if;
    

            if v_Processing = '1' then 
                if (v_PipesXValues(to_integer(v_Index)) + constants.PIPE_WIDTH <= 0) then
                    v_PipesXValues(to_integer(v_Index)) := RightMostPixel;

                    --asign the randomly generated heigt to the top pipes
                    TopPipeHeights(to_integer(v_Index)) <= signed("000" & Rand);

                    -- find the bottom piprd height
                    BottomPipeHeights(to_integer(v_Index)) <= constants.SCREEN_HEIGHT - (signed("000" & Rand) + 200);
                    
                else
                    v_PipesXValues(to_integer(v_Index)) := v_PipesXValues(to_integer(v_Index)) - Speed;
                end if;
            end if;

            if v_Index = to_unsigned(3, 3) then 
                v_Processing := '0';
                Done <= '1';
            else
                v_Index := v_Index + 1;
            end if;

            v_PrevTrigger := Trigger;
        end if;
        PipesXValues <= v_PipesXValues;
    end process;

end architecture;
