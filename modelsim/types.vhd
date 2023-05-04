library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package types is
    type PipesArray is array (3 downto 0) of signed(9 downto 0);
end types;