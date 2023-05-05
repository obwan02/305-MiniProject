library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LFSR is port(
    Clk: in std_logic;
    reset: in std_logic;
    Random7BitNumber: out unsigned(7 downto 0)
);
end entity;

architecture LFSRbehaviour of LFSR is
begin
    process(Clk)
    variable Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7 : std_logic;
    variable std_Random7BitNumber : std_logic_vector(7 downto 0);
    begin
        if reset = '1' then
            Q0 := '1';
            Q1 := '1';
            Q2 := '1';
            Q3 := '1';
            Q4 := '1';
            Q5 := '1';
            Q6 := '1';
            Q7 := '1';
        end if; 
        if rising_edge(Clk) then
            Q7 := Q6;
            Q6 := Q5;
            Q5 := Q4;
            Q4 := Q3 xor Q0;
            Q3 := Q2 xor Q0;
            Q2 := Q1 xor Q0;
            Q1 := Q0;
            Q0 := Q7;
        end if;
        std_Random7BitNumber := Q7 & Q6 & Q5 & Q4 & Q3 & Q2 & Q1 & Q0;
        Random7BitNumber <= unsigned(std_Random7BitNumber);
    end process;

end architecture;