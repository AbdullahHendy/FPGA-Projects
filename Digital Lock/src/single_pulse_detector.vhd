library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity single_pulse_detector is 
    port
    (
        clk          : in std_logic;
        rst          : in std_logic;
        input_signal : in std_logic;
        output_pulse : out std_logic);
end single_pulse_detector;

architecture Behavioral of single_pulse_detector is

signal curr_state, next_state: std_logic := '0';

begin
    process (clk, rst)
        begin
            if rst = '1' then
                curr_state <= '0';
                next_state <= '0';
            elsif rising_edge(clk) then
                next_state <= input_signal;
                curr_state <= next_state;          
            end if;    
    end process;    
    
    output_pulse <= not curr_state and next_state;
end Behavioral;