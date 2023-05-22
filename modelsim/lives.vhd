library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;
use work.types.all;
use work.constants;

entity lives_system is port(
    Clk, Enable, Reset, HasCollided: in std_logic;
    Trigger: in std_logic;
    Done: inout std_logic;

    LifeCount: out unsigned(2 downto 0);
    Dead: out std_logic
    );
end entity lives_system;

architecture behaviour of lives_system is	 

    signal Lives: unsigned(2 downto 0) := to_unsigned(3, 3);
begin

    LifeCount <= Lives;
    Dead <= '1' when Lives = 0 else '0';

    process
        variable v_PrevCollideValue: std_logic := '0';
    begin
        wait until rising_edge(Clk);

        if Enable = '1' then
            if Trigger = '0' then 
                Done <= '0';
            end if;

            if Trigger = '1' and Done = '0' then 
                -- Detect rising edge
                if v_PrevCollideValue /= HasCollided and HasCollided = '1' then 
                    if Lives /= 0 then 
                        Lives <= Lives - 1;
                    end if;
                end if;
                v_PrevCollideValue := HasCollided;

                Done <= '1';
            end if;

            if Reset = '1' then 
                Lives <= to_unsigned(3, 3); 
            end if;
        end if;
    end process;
end architecture;