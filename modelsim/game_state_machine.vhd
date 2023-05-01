library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_moore_fsm is port(
	Clk: in std_logic;
	Reset : in std_logic;
	Dead: in std_logic;
	Start: in std_logic;
	Train : in std_logic;
	GameRunning: out std_logic;
	TrainingStatus: out std_logic);
end entity game_moore_fsm;

architecture behaviour of game_moore_fsm is
	type fsm_states is (Initial, TrainingSelection, TrainingMode, NormalMode, GameOverMode);
	signal current_state, next_state : fsm_states;					 
begin

-- STATE_CHANGER Process
--
-- This process is triggered by the clock and
-- performs the transitioning of the states.
--
-- If the clock in on the rising edge, check
-- if reset is set, else, set the current
-- state to the next state.
STATE_CHANGER : process (Clk)
begin
	if rising_edge(Clk) then
		if Reset = '1' then
			current_state <= Initial;
		else
			current_state <= next_state;
		end if;
	end if;
end process;
end architecture;