library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity text_renderer is 
	generic(STR: string;
			SIZE: natural);
	port(Clk: in std_logic;
		 X: in signed(10 downto 0);
		 Y: in signed(9 downto 0);
		 VgaCol, VgaRow: in std_logic_vector(9 downto 0);

		 Visible: out std_logic
		 );
end entity text_renderer;

architecture behave of text_renderer is
	type AddrArray is array (STR'length-1 downto 0) of std_logic_vector(5 downto 0);

	-- This function should only be called to generate a constant
	function addr_array return AddrArray is
		variable Result: AddrArray;
		variable Current: integer;
	begin
		for i in 0 to STR'length-1 loop
			Current := character'pos(STR(i + 1));

			case STR(i+1) is 
				when 'a' to 'z' => 
					Result(i) := std_logic_vector(to_unsigned(Current - 96, 6));
				when 'A' to 'Z' =>
					Result(i) := std_logic_vector(to_unsigned(Current - 64, 6));
				when '0' to '9' =>
					Result(i) := std_logic_vector(to_unsigned(Current, 6));
				when ' ' =>
					Result(i) := std_logic_vector(to_unsigned(0, 6));
				when '-' => 
					Result(i) := std_logic_vector(to_unsigned(45, 6));
				when others =>
					-- Anything we haven't defined yet defaults to #
					Result(i) := std_logic_vector(to_unsigned(35, 6));
			end case;
		end loop;

		-- Return the address array
		return Result;
	end function;

	component char_rom is
		port
		(
			character_address	:	in std_logic_vector(5 downto 0);
			font_row, font_col	:	in std_logic_vector(2 downto 0);
			clock				: 	in std_logic;
			rom_mux_output		:	out std_logic
		);
	end component;

	constant Addresses: AddrArray := addr_array;
	constant CharSize: natural := 8 * SIZE;
	constant TextWidth: natural := CharSize * STR'length;

	-- Text rendering signals
	signal CharAddress: std_logic_vector(5 downto 0);
	signal FontRow, FontCol: std_logic_vector(2 downto 0);
	signal FontOutput: std_logic;
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

        if signed('0' & VgaCol) >= X and 
           signed('0' & VgaCol) < (X + TextWidth) and
           signed(VgaRow) >= Y and
           signed(VgaRow) < (Y + CharSize) then
			CharAddress <= Addresses(to_integer(shift_right(signed('0' & VgaCol) - X, 2+SIZE)));
            FontCol <= std_logic_vector(shift_right(signed('0' & VgaCol) - X, SIZE-1))(2 downto 0);
            FontRow <= std_logic_vector(shift_right(signed(VgaRow) - Y, SIZE-1))(2 downto 0);
            Visible <= FontOutput;
        else
            Visible <= '0';    
        end if;
    end process;


	

end architecture;
