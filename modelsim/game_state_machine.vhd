library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity game_state_machine is port(
	Clk: in std_logic;
	Die, Start, Train, TryAgain: in std_logic;
	GameRunning, Reset, IsTraining, GameOver: out std_logic
	);
end entity game_state_machine;

architecture behave of game_state_machine is
	type t_State is (Initial,
					 TrainingSelection,
					 TrainingMode,
					 NormalMode,
					 WaitingToStart,
					 GameOverMode);					 
	signal current_state, next_state: t_State;
begin
	
	STATE_CHANGER: process(Clk)
	begin
		if rising_edge(Clk) then
			null;
		end if;
	end process;

-- FIND_NEXT_STATE Process
--
-- This process is triggered by the the current_state, and all of the
-- input signals.
-- 
-- Given the current state of the FSM, if the relevant conditions are
-- met, set the next_state to the corresponding next state.
FIND_NEXT_STATE : process (current_state, Reset, Die, Start, Train)
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
			if (Die = '1') then
				next_state <= GameOverMode;
			end if;
		when NormalMode =>
			if (Die = '1') then
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
			IsTraining <= '0';
			GameOver <= '0';
		when TrainingSelection  =>
			GameRunning <= '0';
			IsTraining <= '0';
			GameOver <= '0';
		when TrainingMode =>
			GameRunning <= '1';
			IsTraining <= '1';
			GameOver <= '0';
		when NormalMode =>
			GameRunning <= '1';
			IsTraining <= '0';
			GameOver <= '0';
		when GameOverMode =>
			GameRunning <= '0';
			IsTraining <= '0';
			GameOver <= '1';
		when others =>
			GameRunning <= '0';
			IsTraining <= '0';
			GameOver <= '0';
	end case;
end process;

end architecture;

