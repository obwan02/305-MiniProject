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
    -- Todo: change score
    scoreOnes: out std_logic_vector(3 downto 0);
    scoreTens: out std_logic_vector(3 downto 0)

);
end entity;

architecture track of score_tracker is 

begin
process(Clk)
    variable v_CurrentPipeX: signed(	0 downto 0);
    variable v_CurrentTopPipeY: signed(	0 downto 0);
    variable v_CurrentBottomPipeY: signed(	0 downto 0);
    variable v_Collisions: std_logic_vector(constants.PIPE_MAX_INDEX downto 0);
    variable v_is_increment: signed(6 downto 0);
    variable TotalScore:  signed(6 downto 0);
    variable onesCounter:  signed(6 downto 0);
begin
    for i in 0 to constants.PIPE_MAX_INDEX loop
        v_is_increment := (others => '0');
        -- if the the bird is inbetween the current pipes
        if PlayerY >= v_CurrentTopPipeY and (PlayerY + constants.BIRD_HEIGHT) <= (constants.SCREEN_HEIGHT - v_CurrentBottomPipeY) then
            if (PlayerX + constants.BIRD_WIDTH) >= v_CurrentPipeX and 
                PlayerX <= (v_CurrentPipeX + constants.PIPE_WIDTH) then
                if PlayerX + constants.BIRD_WIDTH = (v_CurrentPipeX + constants.PIPE_WIDTH) then
                    v_is_increment := to_signed(1, 7);
                end if;
            end if;
        end if;
    end loop;
        TotalScore := TotalScore + v_is_increment;
        scoreTens <= "0000";
        onesCounter := onesCounter + 1;
        if TotalScore > 9 then
            scoreTens <= "0000";
            onesCounter := "0000000";
        end if;
        scoreones <= std_logic_vector(onesCounter(3 downto 0));

            

end process;


    


end architecture track;