library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


use work.types.all;
use work.constants;


entity score_tracker is port(
    Clk : in std_logic; 
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
end entity;

architecture track of score_tracker is 
    signal s_Done: std_logic := '0';
begin

    Done <= s_Done and Trigger;

    SCORE_TRACKER: process
        variable TotalScore:  unsigned(7 downto 0);
        -- This keeps track of which pipe we are checking ATM
        -- NOTE: If the number of pipes increases, the size of this needs 
        -- to increase
        variable v_Index: unsigned(2 downto 0);
        variable v_PrevTrigger: std_logic := '0';

        variable v_Processing: std_logic := '0';
    begin
        wait until rising_edge(Clk);

        if v_PrevTrigger /= Trigger then
            v_Index := (others => '0');
            s_Done <= '0';

            if Trigger = '1' then 
                v_Processing := '1';
            end if;
        end if;

        if v_Processing = '1' then
            if PlayerY >= TopPipeHeight(to_integer(v_Index)) and (PlayerY + constants.BIRD_HEIGHT) <= (constants.SCREEN_HEIGHT - BottomPipeHeight(to_integer(v_Index))) then

                if PlayerX + constants.BIRD_WIDTH = (PipesXValues(to_integer(v_Index)) + constants.PIPE_WIDTH) then
                    TotalScore := TotalScore + 1;
                end if;

            end if;
            
            if v_Index = to_unsigned(3, 3) then 
                v_Processing := '0';
                s_Done <= '1';
            else 
                v_Index := v_Index + 1;
            end if;
                
        end if ;

        ScoreTens <= std_logic_vector(TotalScore / 10)(3 downto 0);
        ScoreOnes <= std_logic_vector(TotalScore mod 10)(3 downto 0);
        v_PrevTrigger := Trigger;

end process;


    


end architecture track;