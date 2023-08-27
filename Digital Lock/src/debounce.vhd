library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity debounce is
    generic
    (
        clk_freq    : integer := 125000; --system clock frequency in Hz
        stable_time : integer := 100);   --time button must remain stable in ms
    port
    (
        clk    : in std_logic;   --input clock
        rst    : in std_logic;   --asynchronous active high reset
        button : in std_logic;   --input signal to be debounced
        result : out std_logic); --debounced signal
end debounce;

architecture Behavioral of debounce is

signal curr_state, next_state: std_logic := '0';
signal counter_enable: std_logic;

component single_pulse_detector is 
    port
    (
        clk          : in std_logic;
        rst          : in std_logic;
        input_signal : in std_logic;
        output_pulse : out std_logic);
end component single_pulse_detector;

begin

    SPD: single_pulse_detector port map (
       clk => clk,
       rst => rst,
       input_signal => button,
       output_pulse => counter_enable);
           
    process (clk, rst)
        variable count: natural := 0;
        variable counting: boolean := false;
        begin
            if rst = '1' then
                result <= '0';
            elsif rising_edge(clk) then
              
                if (counter_enable = '1' and counting = false) then -- if positive edge on button and not counting, start counting and set output
                    result <= '1'; 
                    count := 0;
                    counting := true;
                elsif count < clk_freq * stable_time then -- if counting, check if debouncing period passed, if not count
                        count := count + 1;
                        result <= '0'; -- as long as counting is running, output is 0
                        if count =  clk_freq * stable_time then -- if debouncing period passed, stop counting and reset count
                            count := 0;
                            counting := false;
                        end if;
                end if;     
            end if;    
    end process;    
    
end Behavioral;