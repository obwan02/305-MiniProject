library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity text_storage is 
	generic(STR: string);
	port(Index: in unsigned(5 downto 0)
		 Address: out std_logic_vector(5 downto 0));
end entity text_storage;

architecture behave of text_storage is
	type AddrArray is array (STR'length-1 downto 0) of std_logic_vector(5 downto 0);

	constant Addresses: AddrArray := addr_array();
begin
	
	-- This function should only be called to generate a constant
	function addr_array() return AddrArray is
		variable Result: AddrArray;
		variable Current: integer;
	begin
		for i in 0 to STR'length-1 then
			Current := character'pos(STR(i));

			case STR(i) is 
				when 'a' to 'z' => 
					Result(i) := Current - 96;
				when 'A' to 'Z' =>
					Result(i) := Current - 64;
				when '0' to '9' =>
					Result(i) := Current;
				when others =>
					-- Anyhting we haven't defined yet defaults to #
					Result(i) := 35;
			end case;
		end loop;

		-- Return the address array
		return Result;
	end function;

	
	Address <= Addresses(to_integer(Index));
	

end architecture;
