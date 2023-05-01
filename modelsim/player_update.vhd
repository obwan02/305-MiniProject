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
        constant MaxOut: signed(9 downto 0) := to_signed(479, 10);  
    
        variable YVelocity: signed(9 downto 0) := to_signed(1, 10);  
        variable CurrentY : signed(9 downto 0);
    begin

    if rising_edge(Clk) then
        if (LeftMouseButton /= '0') then 
            if (CurrentY - YVelocity <= 0) then
                YVelocity := (others => '0');
            else
                YVelocity := YVelocity + 1;
            end if;
        else
            if (CurrentY + YVelocity >= 479) then
                YVelocity := (others => '0');
            else
                YVelocity := YVelocity - 10;
            end if;
        end if;

        CurrentY := CurrentY - YVelocity;
        NewY <= CurrentY;
    end if;
    
    end process;

    

end architecture;