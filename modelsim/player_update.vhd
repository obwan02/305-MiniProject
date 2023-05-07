library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity player_update is
    port (
        Clk   : in std_logic;
        Reset : in std_logic;

        LeftMouseButton: in std_logic;

        NewX: out signed(10 downto 0) := to_signed(420, 11);
        NewY: out signed(9 downto 0)
    );
end entity player_update;

architecture rtl of player_update is
begin
    process(Clk)
        constant MAX_OUT: signed(9 downto 0) := to_signed(479, 10);  
    
		-- Here, we keep track of the current
		-- y velocity, and position
        variable v_YVel: signed(9 downto 0) := to_signed(1, 10);  
        variable v_CurrentY: signed(9 downto 0);

		-- This is used to keep
		-- track of the previous state
		-- of the left mouse button
		variable v_PrevLeftMB: std_logic := '0';
    begin

		if rising_edge(Clk) then

			-- Change our velocity so that we
			-- go upwards if the LMB was clicked.
			-- Otherwise, we increment the velocity to
			-- simulate gravity.
			if (LeftMouseButton /= v_PrevLeftMB) then 
				v_YVel := -10;
			else
				v_YVel := v_YVel + 1;
			end if;

			-- Here, we put a cap on the amount of downwards
			-- velocity we can obtain
			if v_YVel <= 10 then
				v_Yvel := 10; 
			end if;

			v_CurrentY := v_CurrentY + v_YVel;
			
			-- Once we have updated the velocity,
			-- we check if we are out of bounds
			-- TODO: wait for collision checking results


			NewY <= v_CurrentY;

			v_PrevLeftMB <= LeftMouseButton;

		end if;
    
    end process;

    

end architecture;
