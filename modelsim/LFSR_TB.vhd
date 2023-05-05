library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LFSRTB is 
end entity;

architecture tbBehaviour of LFSRTb is
    component LFSR is 
        port(
        Clk: in std_logic;
        reset: in std_logic;
        Random7BitNumber: out unsigned(7 downto 0)
    );
    end component;


    signal clk : std_logic;
    signal reset: std_logic;
    signal Random7BitNumber: unsigned(7 downto 0);


begin
    DUT: LFSR port map (
        Clk => clk,
        reset => reset,
        Random7BitNumber => Random7BitNumber
    );

    process
    begin
        reset <= '1';
        wait for 7 ns;

        reset <= '0';
        wait for 10 ns;

        for i in 0 to 9 loop
            wait for 10 ns;
        end loop;

    end process;

    CLkProccess: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;



end architecture;