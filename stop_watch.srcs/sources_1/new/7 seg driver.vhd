----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.04.2026 17:48:07
-- Design Name: 
-- Module Name: 7 seg driver - Behavioral
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

entity seven_seg_driver is
    Port(
        digits : in std_logic_vector(15 downto 0); --bit fields for the 4 digits
        clk : in std_logic;
        rst : in std_logic;
        
        segments : out std_logic_vector(6 downto 0);
        anodes : out std_logic_vector(3 downto 0)
    );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is

    signal refreshCount : unsigned(19 downto 0) := (others => '0'); --count for 2.6 ms refresh period for on digit
    signal digitToDisplay : std_logic_vector(3 downto 0) := "0000";

begin
    process(clk, rst)
    begin
        if rst = '1' then
            refreshCount <= (others => '0');
        elsif rising_edge(clk) then
            refreshCount <= refreshCount + 1;
            
            case std_logic_vector(refreshCount(19 downto 18)) is
                when "00" =>
                    anodes <= "1110"; digitToDisplay <= digits(3 downto 0);
                when "01" =>
                    anodes <= "1101"; digitToDisplay <= digits(7 downto 4);
                when "10" =>
                    anodes <= "1011"; digitToDisplay <= digits(11 downto 8);
                when others =>
                    anodes <= "0111"; digitToDisplay <= digits(15 downto 12);
            end case;
        end if;
    end process;

    with digitToDisplay select segments <=
        "0000001" when "0000", -- 0
        "1001111" when "0001", -- 1
        "0010010" when "0010", -- 2
        "0000110" when "0011", -- 3
        "1001100" when "0100", -- 4
        "0100100" when "0101", -- 5
        "0100000" when "0110", -- 6
        "0001111" when "0111", -- 7
        "0000000" when "1000", -- 8
        "0000100" when "1001", -- 9
        "0001000" when "1010", -- A
        "1100000" when "1011", -- b
        "0110001" when "1100", -- C
        "1000010" when "1101", -- d
        "0110000" when "1110", -- E
        "0111000" when "1111", -- F
        "1111111" when others; -- éteint
    
end Behavioral;
