library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;
use work.constants;

entity LFSR is port(
    Clk: in std_logic;
    reset: in std_logic;
    Random7BitNumbersArray: out RandomPipesHeightArray
);
end entity;

architecture LFSRbehaviour of LFSR is
begin
    process(Clk)
    -- single bit of every individual random number
    variable Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7 : std_logic;
    -- individual random numbers
    variable std_Random7BitNumber : std_logic_vector(7 downto 0);
    variable v_Random7BitNumbersArray: RandomPipesHeightArray;
    begin

        if rising_edge(Clk) then
            for i in 0 to constants.PIPE_MAX_INDEX  loop
                -- reset the Random number before every new random number is generated
                Q0 := '1';
                Q1 := '1';
                Q2 := '1';
                Q3 := '1';
                Q4 := '1';
                Q5 := '1';
                Q6 := '1';
                Q7 := '1';

                -- find the random number
                Q7 := Q6;
                Q6 := Q5;
                Q5 := Q4;
                Q4 := Q3 xor Q0;
                Q3 := Q2 xor Q0;
                Q2 := Q1 xor Q0;
                Q1 := Q0;
                Q0 := Q7;
                
                -- Concatenate the random number
                std_Random7BitNumber := Q7 & Q6 & Q5 & Q4 & Q3 & Q2 & Q1 & Q0;
                -- convert to unsigned form
                v_Random7BitNumbersArray(i) := unsigned(std_Random7BitNumber);
            end loop;


        end if;
        --Output the array of unsigned random numbers
        Random7BitNumbersArray <= v_Random7BitNumbersArray;
    end process;

end architecture;