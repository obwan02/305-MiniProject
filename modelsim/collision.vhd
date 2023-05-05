library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;
use work.types.all;
use work.constants;

entity collision is port(
    Clk: in std_logic;
	PlayerX: in signed(10 downto 0);
	PlayerY: in signed(9 downto 0);
    PipesX: in PipesArray;
    TopPipeHeight: in PipesArray;
    BottomPipeHeight: in PipesArray;
	Collided: out std_logic);
end entity collision;

architecture behaviour of collision is	 
begin
    process(Clk)
    variable v_CurrentPipeX: signed(10 downto 0);
    variable v_CurrentTopPipeY: signed(10 downto 0);
    variable v_CurrentBottomPipeY: signed(10 downto 0);
    variable v_WithinXRange: boolean;

    variable v_Collisions: std_logic_vector(constants.PIPE_MAX_INDEX downto 0);
    begin
        
        if rising_edge(Clk) then

            for i in 0 to constants.PIPE_MAX_INDEX loop
                v_CurrentPipeX := PipesX(i);
                v_CurrentTopPipeY := TopPipeHeight(i);
                v_CurrentBottomPipeY := BottomPipeHeight(i);

                -- This statement checks if the bird's top or bottom edges are
                -- either above or below the respective boundary that would
                -- need a collision to occur.
                if PlayerY <= v_CurrentTopPipeY or (PlayerY + constants.BIRD_HEIGHT) >= (constants.SCREEN_HEIGHT - v_CurrentBottomPipeY) then
                    -- This condition checks if the right edge of the bird has
                    -- hit any of the pipes. - also checks for top and bottom
                    -- edge collision.
                    if (PlayerX + constants.BIRD_WIDTH) >= v_CurrentPipeX and 
                        PlayerX <= (v_CurrentPipeX + constants.PIPE_WIDTH) then
                        v_Collisions(i) := '1';
                    else
                        v_Collisions(i) := '0';
                    end if;
                else
                    v_Collisions(i) := '0';
                end if;
            end loop;
        end if;

        Collided <= or_reduce(v_Collisions);

end process;
end architecture;