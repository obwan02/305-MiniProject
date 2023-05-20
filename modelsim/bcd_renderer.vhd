library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bcd_renderer is 
	generic(SIZE: natural);
	port(Clk: in std_logic;
		 X: in signed(10 downto 0);
		 Y: in signed(9 downto 0);
		 VgaCol, VgaRow: in std_logic_vector(9 downto 0);

		 ScoreOnes, ScoreTens: std_logic_vector(3 downto 0);

		 Visible: out std_logic
		 );
end entity bcd_renderer;

architecture behave of bcd_renderer is
	component char_rom is
		port
		(
			character_address	:	in std_logic_vector(5 downto 0);
			font_row, font_col	:	in std_logic_vector(2 downto 0);
			clock				: 	in std_logic;
			rom_mux_output		:	out std_logic
		);
	end component;

	-- Text rendering signals
	signal CharAddress: std_logic_vector(5 downto 0);
	signal FontRow, FontCol: std_logic_vector(2 downto 0);
	signal FontOutput: std_logic;

	constant CharSize: natural := 8 * SIZE;
	constant TextWidth: natural := CharSize * 2;
begin
	

	TEXT_ROM: char_rom port map(Clock => Clk,
		Character_Address => CharAddress,
		Font_Row => FontRow,
		Font_Col => FontCol,
		rom_mux_output => FontOutput);
	
	TEXT_RENDER: process
		variable v_Index: unsigned(5 downto 0) := (others => '0');
    begin
        wait until rising_edge(Clk);

		-- Process the first number
        if signed('0' & VgaCol) >= X and 
           signed('0' & VgaCol) < (X + CharSize) and
           signed(VgaRow) >= Y and
           signed(VgaRow) < (Y + CharSize) then
			CharAddress <= std_logic_vector(48 + unsigned("00" & ScoreTens));
            FontCol <= std_logic_vector(shift_right(signed('0' & VgaCol) - X, SIZE-1))(2 downto 0);
            FontRow <= std_logic_vector(shift_right(signed(VgaRow) - Y, SIZE-1))(2 downto 0);
            Visible <= FontOutput;
		else
            Visible <= '0';
        end if;

		-- Process the second number
        if signed('0' & VgaCol) >= (X + CharSize) and 
           signed('0' & VgaCol) <  (X + 2*CharSize) and
           signed(VgaRow) >= Y and
           signed(VgaRow) < (Y + CharSize) then
			CharAddress <= std_logic_vector(48 + unsigned("00" & ScoreOnes));
            FontCol <= std_logic_vector(shift_right(signed('0' & VgaCol) - X, SIZE-1))(2 downto 0);
            FontRow <= std_logic_vector(shift_right(signed(VgaRow) - Y, SIZE-1))(2 downto 0);
            Visible <= FontOutput;
        end if;
    end process;


	

end architecture;
