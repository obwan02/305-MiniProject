library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;
use work.constants;

entity pickup is port(
			Clk, Reset, Enable: in std_logic;
			Lives: in unsigned(2 downto 0);
			Rand: in std_logic_vector(7 downto 0);

			PlayerX: in signed(10 downto 0);
			
			PickupX: out signed(10 downto 0);
			PickupY: out signed(9 downto 0);
			PickupType: out PickupType;
			
			HasCollided: in std_logic;

			Trigger: in std_logic;
			Done: out std_logic);
end entity;

architecture behave of pickup is
	signal s_Done: std_logic := '0';
begin

	Done <= s_Done;
	PlayerX <= X;
	PlayerY <= Y;

	MOVEMENT: process
		variable v_ShouldFall: std_logic := '0';

		variable X: std_logic_vector(10 downto 0);
		variable Y: std_logic_vector(9 downto 0);
	begin
		wait until rising_edge(Clk);

		if Trigger = '0' then
			if Reset = '1' then 
				ShouldFall := '0';
				X := PlayerX;
				Y := to_signed(-constants.PICKUP_HEIGHT, Y'length);
			end if;

			s_Done <= '0';
		end if;

		if (Trigger = '1' and s_Done = '0') and Enable = '1' then 
				
			-- If we are not falling, check if we should fall
			if ShouldFall = '0' then 
				-- Check if Rand is at this
				-- random value
				if Rand = "0100100" then 
					ShouldFall := '1';
					X := PlayerX;
					Y := to_signed(-constants.PICKUP_HEIGHT, Y'length);
				end if;
			else 
				Y := Y - 1;
			end if;

			-- Check to see if we are off the screen
			if Y > constants.SCREEN_HEIGHT then
				ShouldFall := '0';
				X := PlayerX;
				Y := to_signed(-constants.PICKUP_HEIGHT, Y'length);
			end if;

			s_Done <= '1';
		end if;

	end process;


end architecture;
