library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;
use work.constants;

entity LFSR is port(
    Clk: in std_logic;
    reset: in std_logic;
    Random7BitNumbersArray: out PipesArray
);
end entity;

architecture LFSRbehaviour of LFSR is
begin
    process(Clk)
    -- single bit of every individual random num\ber
    variable Q: std_logic_vector(7 downto 0) := "01101001";
    begin

        if rising_edge(Clk) then
            for i in 0 to constants.PIPE_MAX_INDEX  loop
                -- find the random number
                Q(7) := Q(6);
                Q(6) := Q(5);
                Q(5) := Q(4);
                Q(4) := Q(3) xor Q(0);
                Q(3) := Q(2) xor Q(0);
                Q(2) := Q(1) xor Q(0);
                Q(1) := Q(0);
                Q(0) := Q(7);
                -- convert to signed form
                Random7BitNumbersArray(i) <= signed("000" & Q);
            end loop;


        end if;
    end process;

end architecture;