library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


use work.types.all;
use work.constants;


entity score_tracker is port(
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
end entity;

architecture track of score_tracker is 
begin

    SCORE_TRACKER: process
        variable v_Ones, v_Tens: unsigned(3 downto 0) := (others => '0');
        -- This keeps track of which pipe we are checking ATM
        -- NOTE: If the number of pipes increases, the size of this needs 
        -- to increase
        variable v_Index: unsigned(2 downto 0);
        variable v_PrevTrigger: std_logic := '0';

        variable v_Processing: std_logic := '0';
    begin
        wait until rising_edge(Clk);


        -- Check to see if we calculate
        if v_PrevTrigger /= Trigger then
            v_Index := (others => '0');
            Done <= '0';

            if Trigger = '1' then 
                v_Processing := '1';
            end if;
        end if;

        -- TODO: Set a flag on the pipe to say it's been hit
        if v_Processing = '1' then
            if PlayerY >= TopPipeHeight(to_integer(v_Index)) and (PlayerY + constants.BIRD_HEIGHT) <= (constants.SCREEN_HEIGHT - BottomPipeHeight(to_integer(v_Index))) then
                if PlayerX + constants.BIRD_WIDTH = (PipesXValues(to_integer(v_Index)) + constants.PIPE_WIDTH) then
                    v_Ones := v_Ones + 1;
                end if;
            end if;
            
            -- Overflow the ones to tens
            if v_Ones = 10 then 
                v_Ones := (others => '0');
                v_Tens := v_Tens + 1;
            end if;

            -- Check to see if we are finished
            if v_Index = to_unsigned(3, 3) then 
                v_Processing := '0';
                Done <= '1';
            else 
                v_Index := v_Index + 1;
            end if;
        end if ;

        if Reset = '1' then 
            v_Ones := (others => '0');
            v_Tens := (others => '0');
        end if;

        ScoreOnes <= std_logic_vector(v_Ones);
        ScoreTens <= std_logic_vector(v_Tens);
        v_PrevTrigger := Trigger;

end process;


    


end architecture track;