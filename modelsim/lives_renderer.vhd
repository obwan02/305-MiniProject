library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;

entity lives_renderer is 
	generic(SIZE: natural);
	port(Clk: in std_logic;
		 X: in signed(10 downto 0);
		 Y: in signed(9 downto 0);
		 VgaCol, VgaRow: in std_logic_vector(9 downto 0);

		 Lives: in unsigned(2 downto 0);

		 Visible: out std_logic
		 );
end entity lives_renderer;

architecture behave of lives_renderer is
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
	signal FontRow, FontCol: std_logic_vector(2 downto 0);
	signal FontOutput: std_logic;

	constant CharSize: natural := 8 * SIZE;
begin
	

	TEXT_ROM: char_rom port map(Clock => Clk,
		Character_Address => std_logic_vector(to_unsigned(32, 6)),
		Font_Row => FontRow,
		Font_Col => FontCol,
		rom_mux_output => FontOutput);
	
	TEXT_RENDER: process
		variable v_Enables: std_logic_vector(2**Lives'length-1 downto 0);
    begin
        wait until rising_edge(Clk);

		v_Enables := (others => '0');
		for i in 0 to 7 loop
			-- Process the first number
			if signed('0' & VgaCol) >= (X + i*CharSize) and 
			signed('0' & VgaCol) < (X + (i+1)*CharSize) and
			signed(VgaRow) >= Y and
			signed(VgaRow) < (Y + CharSize) and Lives > i then
				FontCol <= std_logic_vector(shift_right(signed('0' & VgaCol) - (X + i*CharSize), SIZE-1))(2 downto 0);
				FontRow <= std_logic_vector(shift_right(signed(VgaRow) - Y, SIZE-1))(2 downto 0);
				v_Enables(i) := FontOutput;
			end if;
		end loop;

		Visible <= or_reduce(v_Enables);
    end process;


	

end architecture;
