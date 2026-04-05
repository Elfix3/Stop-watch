----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.04.2026 18:43:31
-- Design Name: 
-- Module Name: stop_watch - Behavioral
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

entity stop_watch is
    Port(
        --we can shrink that to 2 buttons only
        resetBtn : in std_logic;
        playBtn : in std_logic;
        
        
        
        clk : in std_logic;
        seg : out std_logic_vector(6 downto 0);
        an : out std_logic_vector(3 downto 0)
    );
end stop_watch;

architecture Behavioral of stop_watch is

    --state machine
    type t_state is (IDLE, RUNNING, PAUSE);
    signal current_state : t_state := IDLE;


    --counting signals    
    signal tick_counter : unsigned(19 downto 0) := (others => '0');
    signal tens_ms : unsigned(6 downto 0) := (others => '0');
    signal seconds : unsigned(5 downto 0) := (others => '0');
    signal minutes : unsigned(5 downto 0) := (others => '0');
    signal hours : unsigned(4 downto 0) := (others => '0');
    
    --digits signals
    signal time_digits : std_logic_vector(15 downto 0);
    
    --clean buttons Inputs
    signal cleanBtns : std_logic_vector(1 downto 0); --0th is reset, 1st is play
    signal cleanReset : std_logic;
    signal cleanPlay : std_logic;
    signal prev_cleanPlay : std_logic := '0'; --to detect play/pause rising edge
    
    --display modes
    type t_display_mode is (SEC, MIN, H);
    signal display : t_display_mode := SEC;
    
begin
    SEVEN_SEG : entity work.seven_seg_driver port map(
        digits => time_digits,
        clk => clk,
        rst => '0',
        segments => seg,
        anodes => an
    );
    
    DBOUNCER : entity work.debouncer generic map(n => 2) port map(
        clk => clk,
        raw => playBtn & resetBtn,
        clean =>  cleanBtns
    );
    
    cleanReset <= cleanBtns(0);
    cleanPlay <= cleanBtns(1);
    
    process(clk) begin
        if rising_edge(clk)then
            if current_state = IDLE then
                tick_counter <= (others => '0');
                tens_ms <= (others => '0');
                seconds <= (others => '0');
                minutes <= (others => '0');
            
            elsif current_state = RUNNING then
                if tick_counter < 999999 then
                    tick_counter <= tick_counter + 1;
                elsif tick_counter = 999999 then
                    tick_counter  <= (others => '0');
                    if tens_ms <99 then
                        tens_ms <= tens_ms + 1;
                     else 
                        tens_ms <= (others => '0');
                        if seconds < 59 then
                            seconds <= seconds + 1;
                        else
                            seconds <= (others => '0');
                            
                            if minutes < 59 then
                                minutes <= minutes + 1;
                            else
                                minutes <= (others => '0');
                                
                                if hours < 23 then
                                    hours <= hours + 1;
                                else
                                    hours <= (others => '0');
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
                
                elsif current_state = PAUSE then
                      --nothing to do here :)
                end if;
            end if;
   
    end process;
    
    
    process(clk) begin
        if rising_edge(clk)then
            case current_state is
                when IDLE =>
                    if  cleanPlay = '1' and prev_CleanPlay  = '0' then
                        current_state <= RUNNING;
                    end if;
                when RUNNING =>
                    if cleanReset = '1' then
                        current_state <= IDLE;                    
                    elsif cleanPlay = '1' and prev_CleanPlay  = '0'  then
                        current_state <= PAUSE;
                    end if;
                when PAUSE =>
                    if cleanReset = '1' then
                        current_state <= IDLE;
                    elsif cleanPlay = '1' and prev_CleanPlay  = '0' then 
                        current_state <= RUNNING;
                    end if;
                when others =>
                
            end case;
            prev_CleanPlay <= cleanPlay;
        end if;
    end process;
    
    
    process(clk) begin
        if rising_edge(clk) then
             if current_state = IDLE then
                display <= SEC;
            elsif minutes > 0 then
                display <= MIN;
            elsif hours > 0 then
                display <= H;
            end if;
        end if;
    end process;
    
    
    time_digits <=  std_logic_vector(resize(seconds / 10,4))
                    & std_logic_vector(resize(seconds mod 10,4)) 
                    & std_logic_vector(resize(tens_ms / 10,4))
                    & std_logic_vector(resize(tens_ms mod 10,4)) when display = SEC
    else            std_logic_vector(resize(minutes / 10,4))
                    & std_logic_vector(resize(minutes mod 10,4)) 
                    & std_logic_vector(resize(seconds / 10,4))
                    & std_logic_vector(resize(seconds mod 10,4)) when display = MIN
    else            std_logic_vector(resize(hours / 10,4))
                    & std_logic_vector(resize(hours mod 10,4)) 
                    & std_logic_vector(resize(minutes / 10,4))
                    & std_logic_vector(resize(minutes mod 10,4));
    
        
    

end Behavioral;
