library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package types is
<<<<<<< HEAD
    type PipesArray is array (3 downto 0) of signed(10 downto 0);
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

    constant PIPE_WIDTH: integer := 80;
end constants;
=======
    type PipesArray is array (3 downto 0) of signed(9 downto 0);
    constant PLAYER_WIDTH: integer := 8;
    constant PLAYER_HEIGHT: integer := 8;
end types;
>>>>>>> 6a24afc (update(collision.vhd): Implemented collision detection functionality)
