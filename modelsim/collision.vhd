library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity collision is port(
    Clk: in std_logic;
	PlayerX: in signed(10 downto 0);
	PlayerY: in signed(9 downto 0);
<<<<<<< HEAD
    PipesX: in PipesArray(3 downto 0);
    TopPipesY: in PipesArray(3 downto 0);
    BottomPipesY: in PipesArray(3 downto 0);
	Collided: out std_logic);
end entity collision;

architecture behaviour of collision is	
    constant PipeWidth: integer := 50;
    constant PipeLength: integer := 100;		 
begin
    process(Clk)
    variable v_CurrentPipeX: signed(9 downto 0);
    variable v_CurrentTopPipeY: signed(9 downto 0);
    variable v_CurrentBottomPipeY: signed(9 downto 0);
    variable v_WithinXRange: boolean;
    begin
        for i in 0 to 3 loop
            v_CurrentPipeX := PipesX(i);
            v_CurrentTopPipeY := TopPipesY(i);
            v_CurrentBottomPipeY := BottomPipesY(i);

            -- This statement determines if the bird's top or bottom edges
            -- are either above or below the respective boundary that would
            -- need a collision to occur.
            v_WithinXRange := ((PlayerY <= (v_CurrentTopPipeY + PipeLength)) or ((PlayerY + PLAYER_HEIGHT) >= v_CurrentBottomPipeY));

            -- This condition checks if the right edge of the bird has
            -- hit any of the pipes. - also checks for top and bottom
            -- edge collision.
            if ((((PlayerX + PLAYER_WIDTH) >= v_CurrentPipeX) and 
                ((PlayerX + PLAYER_WIDTH) <= (v_CurrentPipeX + PipeWidth))) and (v_WithinXRange)) then
                Collided <= '1';

            -- This condition checks if the left edge of the bird has
            -- hit any of the pipes - also checks for top and bottom
            -- edge collision. (This statement may be redundant as the 
            -- left edge of the bird should never touch a pipe, however 
            -- has been included for completeness).
            elsif (((PlayerX >= v_CurrentPipeX) and (PlayerX <= (v_CurrentPipeX + PipeWidth))) and (v_WithinXRange)) then
                Collided <= '1';
            else
                Collided <= '0';
            end if;

        end loop;
end process;
=======
	PipesLoc: in PipesArray(3 downto 0);
    PipesX: in PipesArray(3 downto 0);
    TopPipesY: in PipesArray(3 downto 0);
    BottomPipesY: in PipesArray(3 downto 0);
	Colided: out std_logic);
end entity collision;

architecture behaviour of collision is				 
begin
>>>>>>> ff1cb26 (new(collision.vhd): Created file for the collision detection functionality)
end architecture;