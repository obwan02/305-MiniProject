library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pickup is port(
			Clk, Enable: in std_logic;
			Lives: in unsigned(2 downto 0);
			Rand: in unsigned(2 downto 0);
			
			PickupX: out signed(10 downto 0);
			PickupY: out signed(9 downto 0);
			
			HasCollided: in std_logic);
end entity;

architecture behave of pickup is
begin


end architecture;
