library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity RAM is
    generic (DATA_WIDTH : positive := 8; ADDR_WIDTH : positive := 12);
    port (
            Clk, W : in std_logic; -- W is ?1? for write or ?0? for read
            Address : in std_logic_vector(DATA_WIDTH-1 downto 0);
            Data_In : in std_logic_vector(DATA_WIDTH-1 downto 0);
            Data_Out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );

end entity RAM;

architecture behave of RAM is
    type Mem_Array is array (0 to ((2 ** ADDR_WIDTH) - 1)) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal Mem : Mem_Array;
begin

    process (Clk)
    begin
        if (rising_edge(Clk)) then
            if (W = '1') then
                Mem(to_integer(unsigned(Address))) <= Data_In;
            else
                Data_Out <= Mem(to_integer(unsigned(Address)));
            end if;
        end if;
    end process;
end architecture;