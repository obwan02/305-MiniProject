library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_state_machine is port(
	Clk: in std_logic;
	Die: in std_logic;
	Start: in std_logic;
	GameRunning: out std_logic;
	Reset: out std_logic);
end entity game_state_machine;

architecture behave of game_state_machine is
	type t_State is (WaitingToStart,
					 NormalRunning,
					 TrainingRunning,
					 Dead);					 
begin
	
	STATE_CHANGER: process(Clk)
	begin
		if rising_edge(Clk) then
			null;
		end if;
	end process;

end architecture;
