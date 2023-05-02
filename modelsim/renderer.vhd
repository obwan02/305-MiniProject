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
    component sprite_rom is
        generic(sprite_file: string);

        port(SpriteRow, SpriteCol	:	in std_logic_vector (2 downto 0);
             Clk				: 	in std_logic;
             Red, Green, Blue : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Constants
    -- TODO: Make this more accessible
    constant BirdWidth: signed(10 downto 0) := to_signed(8, 11);
    constant BirdHeight: signed(9 downto 0) := to_signed(8, 10);

    
    signal EnableBird: std_logic;
    signal BirdR, BirdG, BirdB: std_logic_vector(3 downto 0);
    signal BirdRow, BirdCol: std_logic_vector (2 downto 0) := (others => '0');
begin

    BIRD_ROM: sprite_rom generic map("bird_rom.mif") 
                         port map(Clk => Clk,
                                  SpriteRow => BirdRow,
                                  SpriteCol => BirdCol,
                                  Red => BirdR,
                                  Blue => BirdB,
                                  Green => BirdG 
                         );

    ENABLE_BIRD: process(VgaRow, VgaCol, PlayerY, PlayerX)
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

    BIRD_COLOUR: process(Clk)
        variable v_BirdRow, v_BirdCol: unsigned(2 downto 0) := (others => '0');
    begin

        if rising_edge(Clk) then 
            if signed(VgaRow) >= PlayerY and
            signed(VgaCol) >= PlayerX and 
            signed(VgaRow) <= PlayerY + BirdHeight  and 
            signed(VgaCol) <= PlayerX + BirdWidth then
                v_BirdRow := resize(unsigned(VgaRow) - unsigned('0' & PlayerX), 3);
                v_BirdCol := resize(unsigned(VgaCol) - unsigned('0' & PlayerY), 3);
            else
                v_BirdRow := (others => '0');
                v_BirdCol := (others => '0');
            end if;
        end if;

        BirdRow <= std_logic_vector(v_BirdRow);
        BirdCol <= std_logic_vector(v_BirdCol);

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