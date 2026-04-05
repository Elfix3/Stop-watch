----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.04.2026 14:46:54
-- Design Name: 
-- Module Name: debouncer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debouncer is
    Generic(N : integer := 1);

    Port (
    raw : in std_logic_vector(n-1 downto 0);
    clk : in std_logic;
    clean : out std_logic_vector(n-1 downto 0)
    );
end debouncer;

architecture Behavioral of debouncer is

    signal stable   : std_logic_vector(n-1 downto 0) := (others => '0');
    signal previous : std_logic_vector(n-1 downto 0) := (others => '1');
    

begin

    process(clk)
        variable count : unsigned(20 downto 0);

    begin
        if rising_edge(clk) then
            if raw /= previous then
                count := (others => '0');        
            elsif count(20) = '1' then
                stable <= raw;
            else 
                count := count + 1;
            end if;
            previous <= raw;
        end if;

    end process;


    clean <= stable;

end Behavioral;
