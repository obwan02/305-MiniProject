library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity menus is port(
	Clk, GameRunning, GameOver, TrainSwitch, LeftMouseButton : in std_logic;
    VGARow, VGACol                                           : in unsigned(9 downto 0);
    Score                                                    : in unsigned(9 downto 0);
    MouseRow, MouseCol                    : in unsigned(9 downto 0); 
    BackgroundR, BackgroundG, BackgroundB                    : in std_logic_vector(3 downto 0);
    R, G, B                                                  : out std_logic_vector(3 downto 0);
    DebugLight : out std_logic);
end entity menus;

architecture behaviour of menus is
    
    component sprite_rom is
        generic(sprite_file: string;
                addr_width: natural := 3);

        port(SpriteRow, SpriteCol	:	in std_logic_vector (ADDR_WIDTH-1 downto 0);
             Clk				: 	in std_logic;
             Red, Green, Blue : out std_logic_vector(3 downto 0);
             Visible: out std_logic
        );
    end component;

    signal MouseR, MouseG, MouseB: std_logic_vector(3 downto 0);
    signal CursorRow, CursorCol: std_logic_vector (3 downto 0) := (others => '0');
    signal ShowCursor, CursorVisible: std_logic;

    signal StartR, StartG, StartB: std_logic_vector(3 downto 0);
    signal StartEnable: std_logic;

begin
    CURSOR_ROM: sprite_rom generic map(Sprite_File => "ROM/CURSOR_ROM.mif",
                                       Addr_Width => 4)
                           port map(Clk => Clk,
                                    SpriteRow => CursorRow,
                                    SpriteCol => CursorCol,
                                    Red => MouseR,
                                    Green => MouseG,
                                    Blue => MouseB,
                                    Visible => CursorVisible);

    DRAW_ORDER: process (ShowCursor, MouseR, MouseG, MouseB, StartEnable, StartR, StartG, StartB, BackgroundR, BackgroundG, BackgroundB)
    begin
        if ShowCursor = '1' then
            R <= MouseR;
            G <= MouseG;
            B <= MouseB;
        elsif StartEnable = '1' then
            R <= StartR;
            G <= StartG;
            B <= StartB;
        else
            R <= BackgroundR;
            G <= BackgroundG;
            B <= BackgroundB;
        end if;
        
        -- elsif (GameRunning = '0' and GameOver = '0') then
        --     -- Code for game mode selection
        --     -- Draw blue rectangle
        --     if ((signed(VGACol) >= 199) and (signed(VGACol) <= 439)
        --     and (signed(VGARow) >= 159) and (signed(VGARow) <= 319)) then
        --         R <= "0000";
        --         G <= "0010";
        --         B <= "0111";
        --         -- Draw two rectangles for button
        --         if ((signed(VGACol) >= 259) and (signed(VGACol) <= 379)
        --         and (signed(VGARow) >= 196) and (signed(VGARow) <= 236)) then
        --             if ((mouse_cursor_column >= 259) and (mouse_cursor_column <= 379)
        --             and (mouse_cursor_row >= 196) and (mouse_cursor_row <= 236)) then 
        --                 -- Light Blue
        --                 R <= "0000";
        --                 G <= "1111";
        --                 B <= "1100";
        --             else
        --                 -- Bright Yellow
        --                 R <= "1101";
        --                 G <= "1111";
        --                 B <= "0010";
        --             end if;
        --         end if;
        --         if ((signed(VGACol) >= 259) and (signed(VGACol) <= 379)
        --         and (signed(VGARow) >= 243) and (signed(VGARow) <= 283)) then
        --             if ((mouse_cursor_column >= 259) and (mouse_cursor_column <= 379)
        --             and (mouse_cursor_row >= 243) and (mouse_cursor_row <= 283)) then
        --                 -- Bright Yellow
        --                 R <= "0000";
        --                 G <= "1111";
        --                 B <= "1100";
        --             else
        --                 -- Light Blue
        --                 R <= "1101";
        --                 G <= "1111";
        --                 B <= "0010";
        --             end if;

        --             -- #### DRAW TRAINING TEXT WITH FUTURE FUNCTION ####

        --             -- #### DRAW NORMAL TEXT WITH FUTURE FUNCTION ####

        --         end if;
        --     else
        --         R <= BackgroundR;
        --         G <= BackgroundG;
        --         B <= BackgroundB;   
        --     end if;
        -- elsif (GameRunning = '0' and GameOver = '1') then
        --     -- Code for game over menu
        --     -- Draw blue rectangle
        --     if ((signed(VGACol) >= 199) and (signed(VGACol) <= 439)
        --     and (signed(VGARow) >= 159) and (signed(VGARow) <= 319)) then
        --         R <= "0000";
        --         G <= "0010";
        --         B <= "0111";

        --         -- #### DRAW Score TEXT WITH FUTURE FUNCTION ####

        --         -- Draw rectangle for button
        --         if ((signed(VGACol) >= 259) and (signed(VGACol) <= 379)
        --         and (signed(VGARow) >= 243) and (signed(VGARow) <= 283)) then
        --             if ((mouse_cursor_column >= 259) and (mouse_cursor_column <= 379)
        --             and (mouse_cursor_row >= 243) and (mouse_cursor_row <= 283)) then
        --                 R <= "1101";
        --                 G <= "1111";
        --                 B <= "0010";

        --             -- #### DRAW TRY AGAIN TEXT WITH FUTURE FUNCTION ####
        --             end if;

        --         end if;   
        --     end if;
        -- else
        --     R <= BackgroundR;
        --     G <= BackgroundG;
        --     B <= BackgroundB;
        -- end if;
end process;

-- Handle mouse events for button presses (initial menu and game over menu)
    MOUSE_RENDER: process (VGARow, VGACol, MouseRow, MouseCol, CursorVisible)
        variable v_Enable: std_logic;
        variable v_Row, v_Col: unsigned(3 downto 0); 
    begin
        if VGARow >= MouseRow and
        VGACol >= MouseCol and
        VGARow < MouseRow + 16 and
        VGACol < MouseCol + 16 then
            v_Enable := '1' and CursorVisible;
            v_Row := resize(VGARow - MouseRow, 4);
            v_Col := resize(VGACol - MouseCol, 4);
        else
            v_Enable := '0';
            v_Row := (others => '0');
            v_Col := (others => '0');
        end if;

        ShowCursor <= v_Enable;
        CursorRow <= std_logic_vector(v_Row);
        CursorCol <= std_logic_vector(v_Col);
    end process;

    RENDER_START : process(Clk)
        variable init : std_logic := '1';
        variable v_Enable: std_logic;
    begin
    if (rising_edge(Clk)) then
        if (init = '1') then
            -- Code for inital start menu
            -- Draw blue rectangle
            if VGACol >= 199 and VGACol <= 439
            and VGARow >= 159 and VGARow <= 319 then
                StartEnable <= '1';
                StartR <= "0000";
                StartG <= "0010";
                StartB <= "0111";
                -- Draw yellow rectangle for button
                if VGACol >= 259 and VGACol <= 379
                and VGARow >= 219 and VGARow <= 259 then
                    if MouseCol >= 259 and MouseCol <= 379
                    and MouseRow >= 219 and MouseRow <= 259 then 
                        StartR <= "1111";
                        StartG <= "1111";
                        StartB <= "0110";
                        if LeftMouseButton = '1' then
                            DebugLight <= '1';
                        else
                            DebugLight <= '0';
                        end if;
                    else
                        StartR <= "1101";
                        StartG <= "1100";
                        StartB <= "0010";
                    end if;
                end if;
            else
                StartEnable <= '0';
            end if;
        end if;
    end if;
    end process;
end architecture;
