library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Screen size of 640x480

entity renderer is
    port (
        Clk   : in std_logic;
        Reset : in std_logic;

        PlayerX: in signed(10 downto 0);
        PlayerY: in signed(9 downto 0);

        -- TODO: Add pipe arrays in here
        VgaRow, VgaCol: in std_logic_vector(9 downto 0);
        R, G, B: out std_logic_vector(3 downto 0)
    );
end entity renderer;

architecture behave of renderer is
    signal BirdR, BirdG, BirdB: std_logic_vector(3 downto 0);
    signal EnableBird: std_logic;

    -- Constants
    -- TODO: Make this more accessible
    constant BirdWidth: signed(10 downto 0) := to_signed(8, 11);
    constant BirdHeight: signed(9 downto 0) := to_signed(8, 10);
begin

    -- TODO: Read from file
    BirdR <= "1111";
    BirdG <= "1111";
    BirdB <= "1111";

    RENDER_BIRD: process(VgaRow, VgaCol, PlayerY, PlayerX)
    begin

        if signed(VgaRow) >= PlayerY and
        signed(VgaCol) >= PlayerX and 
        signed(VgaRow) <= PlayerY + BirdHeight  and 
        signed(VgaCol) <= PlayerX + BirdWidth then
            EnableBird <= '1';
        else
            EnableBird <= '0';
        end if;
    end process;

    RENDER_ALL: process(EnableBird, BirdR, BirdG, BirdB)
    begin

        if EnableBird = '1' then
            R <= BirdR; G <= BirdG; B <= BirdB;
        else 
            R <= (others => '1'); G <= (others => '0'); B <= (others => '0');
        end if;

    end process;


    

end architecture;