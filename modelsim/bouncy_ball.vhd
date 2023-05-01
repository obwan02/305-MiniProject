LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_SIGNED.all;


ENTITY bouncy_ball IS
	PORT
		( Clk: in std_logic;
		  VgaRedOut, VgaGreenOut, VgaBlueOut: out std_logic_vector(3 downto 0);
          VgaHSync, VgaVSync: out std_logic);		
END bouncy_ball;

architecture behavior of bouncy_ball is

	component VGA_SYNC IS
	PORT(	clock_25Mhz: IN STD_LOGIC;
			red, green, blue		: IN	std_logic_vector(3 downto 0);
			red_out, green_out, blue_out  		: OUT std_logic_vector(3 downto 0);
			horiz_sync_out, vert_sync_out	: OUT STD_LOGIC;
			pixel_row, pixel_column: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
	END component;


	SIGNAL ball_on					: std_logic;
	SIGNAL size 					: std_logic_vector(9 DOWNTO 0);  
	SIGNAL ball_y_pos				: std_logic_vector(9 DOWNTO 0);
	SiGNAL ball_x_pos				: std_logic_vector(10 DOWNTO 0);
	SIGNAL ball_y_motion			: std_logic_vector(9 DOWNTO 0);

	signal pixel_row, pixel_column: std_logic_vector(9 DOWNTO 0);
	signal red, green, blue, vsync:  std_logic;

	signal Clk25MHz: std_logic;

BEGIN    

VGA_CLOCK: process(Clk)
        variable v_25MHzClk: std_logic := '0';
    begin
        if rising_edge(Clk) then
            v_25MHzClk := not v_25MHzClk;
        end if;

        Clk25MHz <= v_25MHzClk;
end process;

C2: vga_sync port map(
	clock_25Mhz => Clk25MHz,
	red => (others => red), green => (others => green), blue => (others => blue),
	red_out => VgaRedOut, green_out => VgaGreenOut, blue_out => VgaBlueOut,
	horiz_sync_out => VgaHSync, vert_sync_out => vsync,
	pixel_row => pixel_row, pixel_column => pixel_column
);

VgaVSync <= vsync;


size <= CONV_STD_LOGIC_VECTOR(8,10);
-- ball_x_pos and ball_y_pos show the (x,y) for the centre of ball
ball_x_pos <= CONV_STD_LOGIC_VECTOR(590,11);

ball_on <= '1' when ( ('0' & ball_x_pos <= '0' & pixel_column + size) and ('0' & pixel_column <= '0' & ball_x_pos + size) 	-- x_pos - size <= pixel_column <= x_pos + size
					and ('0' & ball_y_pos <= pixel_row + size) and ('0' & pixel_row <= ball_y_pos + size) )  else	-- y_pos - size <= pixel_row <= y_pos + size
			'0';


-- Colours for pixel data on video signal
-- Changing the background and ball colour by pushbuttons
Red <= not ball_on;
Green <= (not ball_on);
Blue <=  not ball_on;

Move_Ball: process (vsync)  	
begin
	-- Move ball once every vertical sync
	if (rising_edge(vsync)) then			
		-- Bounce off top or bottom of the screen
		if ( ('0' & ball_y_pos >= CONV_STD_LOGIC_VECTOR(479,10) - size) ) then
			ball_y_motion <= - CONV_STD_LOGIC_VECTOR(2,10);
		elsif (ball_y_pos <= size) then 
			ball_y_motion <= CONV_STD_LOGIC_VECTOR(2,10);
		end if;
		-- Compute next ball Y position
		ball_y_pos <= ball_y_pos + ball_y_motion;
	end if;
end process Move_Ball;

END behavior;

