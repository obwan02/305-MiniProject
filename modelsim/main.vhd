library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity main is
    port (Clk: in std_logic;
          VgaRedOut, VgaGreenOut, VgaBlueOut: out std_logic_vector(3 downto 0);
          VgaHSync, VgaVSync: out std_logic);
end entity main;

architecture behave of main is
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

    component vga_sync is
    port(clock_25Mhz: in std_logic;
         red, green, blue: in std_logic_vector(3 downto 0);
         red_out, green_out, blue_out: out std_logic_vector(3 downto 0);
         horiz_sync_out, vert_sync_out: out std_logic;
         pixel_row, pixel_column: out std_logic_vector(9 DOWNTO 0));
    end component;

    component player_update is
        port (
            Clk   : in std_logic;
            Reset : in std_logic;
    
            LeftMouseButton: in std_logic;
    
            NewX: out signed(10 downto 0);
            NewY: out signed(9 downto 0)
        );
    end component;

    signal VgaRow, VgaCol: std_logic_vector(9 downto 0);
    signal R, G, B: std_logic_vector(3 downto 0);
    signal Clk25MHz: std_logic;

    signal PlayerX: signed(10 downto 0);
    signal PlayerY: signed(9 downto 0);
begin

    VGA_CLOCK: process(Clk)
        variable v_25MHzClk: std_logic := '0';
    begin
        if rising_edge(Clk) then
            v_25MHzClk := not v_25MHzClk;
        end if;

        Clk25MHz <= v_25MHzClk;
    end process;

    C1: renderer port map(Clk => Clk, 
                          Reset => '0', 
                          PlayerX => PlayerX, 
                          PlayerY => PlayerY, 
                          VgaRow => VgaRow,
                          VgaCol => VgaCol,
                          R => R,
                          G => G,
                          B => B);

    C2: vga_sync port map(
        clock_25Mhz => Clk25MHz,
        red => R, green => G, blue => B,
        red_out => VgaRedOut, green_out => VgaGreenOut, blue_out => VgaBlueOut,
        horiz_sync_out => VgaHSync, vert_sync_out => VgaVSync
    );

    C3: player_update port map(Clk => Clk,
                               Reset => '0',
                               LeftMouseButton => '0',
                               NewX => PlayerX,
                               NewY => PlayerY
    );
    

end architecture;