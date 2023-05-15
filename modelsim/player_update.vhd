library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.constants;

entity player_update is
    port (
        Clk   : in std_logic;
        Reset : in std_logic;

        LeftMouseButton: in std_logic;

        NewX: out signed(10 downto 0) := to_signed(420, 11);
        NewY: out signed(9 downto 0);

		HitTopOrBottom: out std_logic;

		-- Trigger and output
		Trigger: in std_logic;
		Done: out std_logic;

		Collided: in std_logic
    );
end entity player_update;

architecture rtl of player_update is
	-- Track the previous trigger value
	signal  PrevTrigger : std_logic := '0';
begin

    MOVEMENT: process
        constant MAX_OUT: signed(9 downto 0) := to_signed(479, 10);  
    
		-- Here, we keep track of the current
		-- y velocity, and position
        variable v_YVel: signed(9 downto 0) := to_signed(1, 10);  
        variable v_CurrentY: signed(9 downto 0) := to_signed(240, 10);

		-- This is used to keep
		-- track of the previous state
		-- of the left mouse button
		variable v_PrevLeftMB: std_logic := '0';

		-- These are temporary variables
		-- that tell us wether or not we 
		-- have hit the top or bottom of the 
		-- screen
		variable v_HitTop : std_logic := '0';
		variable v_HitBottom : std_logic := '0';

		variable v_Processing : std_logic := '0';
    begin
		wait until rising_edge(Clk);

		if PrevTrigger /= Trigger then
            Done <= '0';

            if Trigger = '1' then 
                v_Processing := '1';
            end if;
        end if;

			
		if v_Processing = '1' then
			-- Change our velocity so that we
			-- go upwards if the LMB was clicked.
			-- Otherwise, we increment the velocity to
			-- simulate gravity.
			if (LeftMouseButton /= v_PrevLeftMB) and v_PrevLeftMB = '0' then 
				v_YVel := to_signed(-10, v_YVel'length);
			else
				v_YVel := v_YVel + 1;
			end if;
			v_PrevLeftMB := LeftMouseButton;
			
			-- Here, we put a cap on the amount of downwards
			-- velocity we can obtain
			if v_YVel >= 10 then
				v_Yvel := to_signed(10, v_YVel'length); 
			end if;
			
			v_CurrentY := v_CurrentY + v_YVel;
			
			
			-- Here, we limit the birds position so
			-- that we can't fall through the floor
			-- TODO: die here?
			if v_CurrentY <= 0 then
				v_CurrentY := (others => '0');
				v_YVel := (others => '0');
				v_HitTop := '1';
			else
				v_HitTop := '0';
			end if;
			
			if (v_CurrentY + constants.BIRD_HEIGHT) >= constants.SCREEN_HEIGHT then
				v_CurrentY := to_signed(constants.SCREEN_HEIGHT - constants.BIRD_HEIGHT, v_CurrentY'length);
				v_YVel := (others => '0');
				v_HitBottom := '1';
			else 
				v_HitBottom := '0';
			end if;
			
			Done <= '1';
			v_Processing := '0';
		end if;
		
		HitTopOrBottom <= v_HitTop or v_HitBottom;
		NewY <= v_CurrentY;
		
		PrevTrigger <= Trigger;
    end process;
	
    
	
end architecture;
