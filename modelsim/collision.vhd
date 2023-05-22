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
    Trigger: in std_logic;
    Done: out std_logic;
	Collided: out std_logic;
    Collisions: out std_logic_vector(PipesX'range)
    );

end entity collision;

architecture behaviour of collision is	 
    signal s_CollisionDone: std_logic := '0';
begin
    process(Clk)
        variable v_CurrentPipeX, v_CurrentTopPipeY, v_CurrentBottomPipeY: signed(10 downto 0);
        variable v_WithinXRange: boolean;

        variable v_Collided: std_logic;
        variable v_Index: unsigned(2 downto 0) := (others => '0');
    begin
        
        if rising_edge(Clk) then

            if Trigger = '0' then
                s_CollisionDone <= '0';
                v_Index := (others => '0');
                v_Collided := '0';
            end if;
     

            if Trigger = '1' and s_CollisionDone = '0' then 
                
                v_CurrentPipeX := PipesX(to_integer(v_Index));
                v_CurrentTopPipeY := TopPipeHeight(to_integer(v_Index));
                v_CurrentBottomPipeY := BottomPipeHeight(to_integer(v_Index));

                -- This statement checks if the bird's top or bottom edges are
                -- either above or below the respective boundary that would
                -- need a collision to occur.
                if PlayerY <= v_CurrentTopPipeY or (PlayerY + constants.BIRD_HEIGHT) >= (constants.SCREEN_HEIGHT - v_CurrentBottomPipeY) then
                    -- This condition checks if the right edge of the bird has
                    -- hit any of the pipes. - also checks for top and bottom
                    -- edge collision.
                    if (PlayerX + constants.BIRD_WIDTH) >= v_CurrentPipeX and 
                        PlayerX <= (v_CurrentPipeX + constants.PIPE_WIDTH) then
                        v_Collided := '1';
                        Collisions(to_integer(v_Index)) <= '1';
                    end if;
                end if;

                if v_Index = 3 then 
                    s_CollisionDone <= '1';
                else
                    v_Index := v_Index + 1;
                end if;
            end if;
          end if;

        Done <= s_CollisionDone;
        Collided <= v_Collided;

end process;
end architecture;