library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity test_renderer is
    port(
        R, G, B: out std_logic_vector(3 downto 0)
    );
end entity test_renderer;

architecture rtl of test_renderer is

    component renderer is
        port (
            Clk   : in std_logic;
            Reset : in std_logic;
    
            PlayerX: in signed(10 downto 0);
            PlayerY: in signed(9 downto 0);
    
            -- TODO: Add pipe arrays in here
            VgaRow, VgaCol: in std_logic_vector(9 downto 0);
            R, G, B: out std_logic_vector(3 downto 0)
        );
    end component;

    signal Clk: std_logic;
    signal VgaRow, VgaCol: std_logic_vector(9 downto 0);
begin

    DUT: renderer port map(Clk => Clk, 
        Reset => '0', 
        PlayerX => (others => '0'), 
        PlayerY => (others => '0'), 
        VgaRow => std_logic_vector(VgaRow),
        VgaCol => std_logic_vector(VgaCol),
        R => R,
        G => G,
        B => B);


    VgaRow <= "0000000000", "0000000001" after 7 ns, "0000001111"  after 17 ns, "0000000000" after 23 ns;
    VgaCol <= "0000000000", "0000000001" after 23 ns, "0000001111"  after 33 ns;


    CLK_PROCESS: process
    begin
        Clk <= '0';
        wait for 5 ns;
        Clk <= '1';
        wait for 5 ns;
    end process;

end architecture;