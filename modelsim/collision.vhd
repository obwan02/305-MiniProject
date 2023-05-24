library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;
use work.types.all;
use work.constants;

entity collision is port(
    Clk: in std_logic;
	PlayerX, PickupX: in signed(10 downto 0);
	PlayerY, PickupY: in signed(9 downto 0);
    PipesX: in PipesArray;
    TopPipeHeight: in PipesArray;
    BottomPipeHeight: in PipesArray;
    Trigger: in std_logic;
    Done: out std_logic;
	Collided, PickupCollided: out std_logic
    );
end entity collision;

architecture behaviour of collision is	 
    signal s_CollisionDone: std_logic := '0';
begin

	PICKUP_COLLISION: process(PlayerX, PlayerY, PickupX, PickupY)
	begin
		if (PlayerX + constants.BIRD_WIDTH) >= PickupX and
		   PlayerX <= (PickupX + constants.PICKUP_WIDTH) and
		   (PlayerY + constants.BIRD_HEIGHT) >= PickupY and
		   PlayerY <= (PickupY + constants.PICKUP_HEIGHT) then
			PickupCollided <= '1';
		else
			PickupCollided <= '0';
		end if;
	end process;

    PIPE_COLLISIONS: process(Clk)
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
                    -- hit any of the pipes.
                    if (PlayerX + constants.BIRD_WIDTH) >= v_CurrentPipeX and 
                        PlayerX <= (v_CurrentPipeX + constants.PIPE_WIDTH) and 
                        not (v_CurrentBottomPipeY = 0 and v_CurrentBottomPipeY = 0) then
                        v_Collided := '1';
                    end if;
                end if;

                if v_Index = 3 then 
                    s_CollisionDone <= '1';
                else
                    v_Index := v_Index + 1;
                end if;
            end if;
          end if;

          Collided <= v_Collided;
        end process;
        
        Done <= s_CollisionDone;
end architecture;
