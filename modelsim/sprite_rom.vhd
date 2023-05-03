LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_ARITH.all;
USE IEEE.std_logic_UNSIGNED.all;

LIBRARY altera_mf;
USE altera_mf.all;

entity sprite_rom IS
    generic(sprite_file: string);

	port
	(
		SpriteRow, SpriteCol	:	in std_logic_vector (2 downto 0);
		Clk				: 	in std_logic;
        Red, Green, Blue : out std_logic_vector(3 downto 0);
		Visible: out std_logic
	);
end sprite_rom;


architecture behave of sprite_rom is

	signal rom_data		: std_logic_VECTOR (11 downto 0);
	signal rom_address	: std_logic_VECTOR (5 downto 0);

	COMPONENT altsyncram
	generic (
		address_aclr_a			: string;
		clock_enable_input_a	: string;
		clock_enable_output_a	: string;
		init_file				: string;
		intended_device_family	: string;
		lpm_hint				: string;
		lpm_type				: string;
		numwords_a				: natural;
		operation_mode			: string;
		outdata_aclr_a			: string;
		outdata_reg_a			: string;
		widthad_a				: natural;
		width_a					: natural;
		width_byteena_a			: natural
	);
	port (
		clock0		: in std_logic ;
		address_a	: in std_logic_VECTOR (5 downto 0);
		q_a			: out std_logic_VECTOR (11 downto 0)
	);
	end component;

begin

	altsyncram_component : altsyncram
	generic map (
		address_aclr_a => "NONE",
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => sprite_file,
		intended_device_family => "Cyclone III",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 64,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "UNREGISTERED",
		widthad_a => 6,
		width_a => 12,
		width_byteena_a => 1
	)
	port map (
		clock0 => Clk,
		address_a => rom_address,
		q_a => rom_data
	);

	rom_address <= SpriteRow & SpriteCol;
    Red <= rom_data(11 downto 8);
    Green <= rom_data(7 downto 4);
    Blue <= rom_data(3 downto 0);
	Visible <= '1';

end behave;