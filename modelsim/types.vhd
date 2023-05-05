library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.constants;

package types is
    type PipesArray is array (constants.PIPE_MAX_INDEX downto 0) of signed(10 downto 0);
    type UnsignedPipesArray is array (constants.PIPE_MAX_INDEX downto 0) of unsigned(10 downto 0);
    type RandomPipesHeightArray is array (constants.PIPE_MAX_INDEX downto 0) of unsigned(7 downto 0);
end types;

--TODO: Make PIPE width a constant
package constants is 
    -- These numbers should be a power of 2
    -- if these are changed, tell ollie he needs
    -- to change some stuff in the renderer
    constant BIRD_WIDTH: integer := 32;
    constant BIRD_HEIGHT: integer := 32;
    constant SCREEN_HEIGHT: integer := 479;
    constant SCREEN_WIDTH: integer := 639;

    constant PIPE_COUNT: integer := 4;
    constant PIPE_MAX_INDEX: integer := PIPE_COUNT - 1;
    constant PIPE_WIDTH: integer := 80;
end constants;
