library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity state_machine is port(
    Clk: in std_logic;
    Reset : in std_logic;
    Dead: in std_logic;
    Start: in std_logic;
    Train : in std_logic;
    TryAgain: in std_logic;
    GameRunning: out std_logic;
    TrainingStatus: out std_logic;
    GameOver: out std_logic;
    DebugLight : out std_logic);
end entity state_machine;

architecture rtl of state_machine is
    type FSM_State is (Init, Normal, Training, GameFinished);
    signal State: FSM_State := Init;
begin

    Current_State: process
    begin
        wait until rising_edge(Clk);

        case State is
            -- When state is in the initial state:
            when Init => 
                -- Start the game
                if Start = '1' then
                    if Train = '0' then 
                        State <= Normal;
                -- Game stays at mode selection 
                    else
                        State <= Training;
                    end if;
                end if;

            when Normal | Training =>
                if Dead = '1' then 
                    State <= GameFinished;
                end if;

            when GameFinished => null;
            when others => null;
        end case;
    end process;


    STATE_DECODE: process(State)
    begin

        case State is 
            when Init =>
                GameRunning <= '0';
                TrainingStatus <= '0';
            when Training =>
                GameRunning <= '1';
                TrainingStatus <= '1';
            when Normal =>
                GameRunning <= '1';
                TrainingStatus <= '0';
            when GameFinished =>
                GameRunning <= '0';
                TrainingStatus <= '0';
        end case;

    end process;

    

end architecture;