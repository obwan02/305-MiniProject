library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_moore_fsm is port(
	Clk: in std_logic;
	Reset : in std_logic;
	Dead: in std_logic;
	Start: in std_logic;
	Train : in std_logic;
	TryAgain: in std_logic;
	-- Bird flying
	GameRunning: out std_logic;
	TrainingStatus: out std_logic;
	-- set to 1 when you have 0 lives
	GameOver: out std_logic);
end entity game_moore_fsm;

architecture behaviour of game_moore_fsm is
	type fsm_states is (Initial, 
						TrainingSelection, 
						TrainingMode, 
						NormalMode, 
						GameOverMode);
	signal current_state, next_state : fsm_states;					 
begin

-- STATE_CHANGER Process
--
-- This process is triggered by the clock and performs the transitioning
-- of the states.
--
-- If the clock in on the rising edge, check if reset is set, else, set
-- the current state to the next state.
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

-- FIND_NEXT_STATE Process
--
-- This process is triggered by the the current_state, and all of the
-- input signals.
-- 
-- Given the current state of the FSM, if the relevant conditions are
-- met, set the next_state to the corresponding next state.
FIND_NEXT_STATE : process (current_state, Reset, Dead, Start, Train)
begin
	next_state <= Initial;
	case (current_state) is
		when Initial =>
			if (Start = '1') then
				next_state <= TrainingSelection;
			end if;
		when TrainingSelection  =>
			if (Train = '1') then
				next_state <= TrainingMode;
			else
				next_state <= NormalMode;
			end if;
		when TrainingMode =>
			if (Dead = '1') then
				next_state <= GameOverMode;
			end if;
		when NormalMode =>
			if (Dead = '1') then
				next_state <= GameOverMode;
			end if;
		when GameOverMode =>
			if (TryAgain = '1') then
				next_state <= TrainingSelection;
			end if;
		when others =>
			next_state <= Initial;
	end case;
end process;

-- SET_OUTPUTS Process
--
-- This process is triggered when the current_state of the FSM changes.
--
-- Given the current state of the FSM, the three outputs, GameRunning,
-- TrainingStatus and GameOver are set.
SET_OUTPUTS : process (current_state)
begin
	case (current_state) is
		when Initial =>
			GameRunning <= '0';
			TrainingStatus <= '0';
			GameOver <= '0';
		when TrainingSelection  =>
			GameRunning <= '0';
			TrainingStatus <= '0';
			GameOver <= '0';
		when TrainingMode =>
			GameRunning <= '1';
			TrainingStatus <= '1';
			GameOver <= '0';
		when NormalMode =>
			GameRunning <= '1';
			TrainingStatus <= '0';
			GameOver <= '0';
		when GameOverMode =>
			GameRunning <= '0';
			TrainingStatus <= '0';
			GameOver <= '1';
		when others =>
			GameRunning <= '0';
			TrainingStatus <= '0';
			GameOver <= '0';
	end case;
end process;

end architecture;

