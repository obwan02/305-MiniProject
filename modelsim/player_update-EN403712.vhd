library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity player_update is
    port (
        Clk   : in std_logic;
        Reset : in std_logic;

        LeftMouseButton: in std_logic;

        NewX: out signed(10 downto 0);
        NewY: out signed(9 downto 0)
    );
end entity player_update;

architecture rtl of player_update is
begin
    process(clk)
        variable CurrentY : signed(9 downto 0);
        constant ConstantYChanged: signed(9 downto 0) := to_signed(11, 10);  
        constant MaxOut: signed(9 downto 0) := to_signed(479, 10);  
    begin
        
        if (LeftMouseButton /= '0') then 
            if (CurrentY - ConstantYChanged <= 0) then
                newY <= (others => '0');
                CurrentY  := (others => '0');
            else
                newY <= CurrentY - ConstantYChanged;
                CurrentY  := CurrentY - ConstantYChanged;
            end if;
        else
            if (CurrentY + ConstantYChanged >= 479) then
                NewY <= maxOut;
                CurrentY := maxOut;
            else
                NewY <= CurrentY + constantYChanged;
                currentY := CurrentY + constantYChanged;
            end if;
        end if;
    
    end process;

    

end architecture;