library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity collision is port(
    Clk: in std_logic;
	PlayerX: in signed(10 downto 0);
	PlayerY: in signed(9 downto 0);
	PipesLoc: in PipesArray(3 downto 0);
    PipesX: in PipesArray(3 downto 0);
    TopPipesY: in PipesArray(3 downto 0);
    BottomPipesY: in PipesArray(3 downto 0);
	Colided: out std_logic);
end entity collision;

architecture behaviour of collision is				 
begin
end architecture;