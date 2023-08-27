library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lock is
    Port ( clk : in STD_LOGIC;
           e : in STD_LOGIC;
           s : in STD_LOGIC;
           w : in STD_LOGIC;
           n : in STD_LOGIC;
           unlock : out STD_LOGIC;
           alarm : out STD_LOGIC;
           leds : out STD_LOGIC_VECTOR(3 DOWNTO 0)
           );
end lock;

architecture Behavioral of lock is

    constant clk_freq_top: natural := 125000000; --system clock frequency in Hz
    constant debounce_time: natural := 400; --debounce time in ms
    constant desired_freq: natural := 2; --desired frequency after division in Hz
    
    type state_type is (IDLE, C1, C2, C3, UNLK, W1, W2, W3, ALRM, A1, R1, R2, R3, REST);
    signal state: state_type;

    signal rst: std_logic;
    signal e_dbc, s_dbc, w_dbc, n_dbc: std_logic;
    signal divided_clk: std_logic;
    signal unlock_flag: boolean;
    signal alarm_flag: boolean;
    signal counter: natural;

    component debounce is
        generic
        (
            clk_freq    : integer := 125000; --system clock frequency in Hz (divided by 1000)
            stable_time : integer := debounce_time);   --time button must remain stable in ms
        port
        (
            clk    : in std_logic;   --input clock
            rst    : in std_logic;   --asynchronous active high reset
            button : in std_logic;   --input signal to be debounced
            result : out std_logic); --debounced signal
    end component debounce;


begin

    E_DEBNC: debounce port map (
       clk => clk,
       rst => rst,
       button => e,
       result => e_dbc);

    S_DEBNC: debounce port map (
       clk => clk,
       rst => rst,
       button => s,
       result => s_dbc);

    W_DEBNC: debounce port map (
       clk => clk,
       rst => rst,
       button => w,
       result => w_dbc);

    N_DEBNC: debounce port map (
       clk => clk,
       rst => rst,
       button => n,
       result => n_dbc);

    clock_div: process (clk, rst) --clock divider
        begin
            if rst = '1' then
                divided_clk <= '0';
                counter <= 0;
            elsif rising_edge(clk) then
                counter <= counter + 1;
                if counter = (clk_freq_top/(2*desired_freq))-1 then
                    divided_clk <= not divided_clk;
                    counter <= 0;
                end if;    
            end if;
    end process;
    
    blink_unlock: process (clk, rst, unlock_flag) --led blinker
        begin
            if rst = '1' then
                unlock <= '0';
            elsif rising_edge(divided_clk) then
                if unlock_flag = true then
                    unlock <= not unlock;
                else 
                    unlock <= '0';
                end if;    
            end if;
    end process;     
    
    blink_alarm: process (clk, rst, alarm_flag) --led blinker
        begin
            if rst = '1' then
                alarm <= '0';
            elsif rising_edge(divided_clk) then
                if alarm_flag = true then
                    alarm <= not alarm;
                else 
                    alarm <= '0';
                end if;    
            end if;
    end process;     
    
    process (clk, rst, e_dbc, s_dbc, w_dbc, n_dbc) --seqential 
        begin 
            if rst = '1' then
                state <= IDLE;
                unlock_flag <= false;
                alarm_flag <= false;
                leds <= (others => '0');
            elsif rising_edge(clk) then
                case state is
                
                    when idle => 

                        unlock_flag <= false;
                        alarm_flag <= false;
                        leds <= (others => '0');
                        if  s_dbc = '1' then
                            state <= C1;
                        elsif e_dbc = '1' then
                            state <= R1;
                        elsif w_dbc = '1' or n_dbc = '1' then
                            state <= W1;
                        else
                            state <= idle;            
                        end if;
                        
                    when C1 =>
                    
                        unlock_flag <= false;
                        alarm_flag <= false;
                        leds(3) <= '1';                    
                        if  w_dbc = '1' then
                            state <= C2;
                        elsif e_dbc = '1' then
                            state <= R2;
                        elsif s_dbc = '1' or n_dbc = '1' then
                            state <= W2;
                        else
                            state <= C1;            
                        end if;                                              
                        
                    when C2 =>

                        unlock_flag <= false;
                        alarm_flag <= false;
                        leds(2) <= '1';
                        if  e_dbc = '1' then
                            state <= C3;
                        elsif s_dbc = '1' or w_dbc = '1' or n_dbc = '1' then
                            state <= W3;
                        else
                            state <= C2;            
                        end if;
                                            
                    when C3 =>
                        
                        unlock_flag <= false;
                        alarm_flag <= false; 
                        leds(1) <= '1';                       
                        if  w_dbc = '1' then
                            state <= UNLK;
                        elsif e_dbc = '1' then
                            state <= REST;    
                        elsif s_dbc = '1' or n_dbc = '1' then
                            state <= ALRM;
                        else
                            state <= C3;            
                        end if;
                                            
                    when UNLK =>

                        unlock_flag <= true;
                        alarm_flag <= false;  
                        leds(0) <= '1';
                        if e_dbc = '1' or s_dbc = '1' or w_dbc = '1' or n_dbc = '1' then
                            state <= IDLE;
                        else
                            state <= UNLK;
                        end if;                            
                                            
                    when W1 =>
                    
                        unlock_flag <= false;
                        alarm_flag <= false; 
                        leds(3) <= '1';
                        if e_dbc = '1' then
                            state <= R2;
                        elsif s_dbc = '1' or w_dbc = '1' or n_dbc = '1' then
                            state <= W2;
                        else
                            state <= W1;                            
                        end if;
                    
                    when W2 =>

                        unlock_flag <= false;
                        alarm_flag <= false;
                        leds(2) <= '1';
                        if e_dbc = '1' then
                            state <= R3;
                        elsif s_dbc = '1' or w_dbc = '1' or n_dbc = '1' then
                            state <= W3;
                        else
                            state <= W2;                            
                        end if;

                    when W3 =>
                    
                        unlock_flag <= false;
                        alarm_flag <= false;
                        leds(1) <= '1';
                        if e_dbc = '1' or s_dbc = '1' or w_dbc = '1' or n_dbc = '1' then
                            state <= ALRM;
                        else
                            state <= W3;                            
                        end if;
                    
                    when ALRM =>

                        unlock_flag <= false;
                        alarm_flag <= true;
                        leds(0) <= '1';
                        if w_dbc = '1' then
                            state <= A1;
                        elsif e_dbc = '1' or s_dbc = '1' or n_dbc = '1' then
                            state <= ALRM;
                        else
                            state <= ALRM;    
                        end if;    
                        
                    when A1 =>
                    
                        unlock_flag <= false;
                        alarm_flag <= false;
                        if e_dbc = '1' then
                            state <= REST;
                        elsif w_dbc = '1' or s_dbc = '1' or n_dbc = '1' then
                            state <= ALRM;
                        else
                            state <= A1;
                        end if;
                        
                    when R1 =>
                        
                        unlock_flag <= false;
                        alarm_flag <= false;
                        leds(3) <= '1';
                        if e_dbc = '1' then
                            state <= REST;
                        elsif w_dbc = '1' or s_dbc = '1' or n_dbc = '1' then
                            state <= W2;
                        else
                            state <= R1;
                        end if;                        
                        
                    when R2 =>
                    
                        unlock_flag <= false;
                        alarm_flag <= false;
                        leds(2) <= '1';
                        if e_dbc = '1' then
                            state <= REST;
                        elsif w_dbc = '1' or s_dbc = '1' or n_dbc = '1' then
                            state <= W3;
                        else
                            state <= R2;
                        end if;
                        
                    when R3 =>
                    
                        unlock_flag <= false;
                        alarm_flag <= false;
                        leds(1) <= '1';
                        if e_dbc = '1' then
                            state <= REST;
                        elsif w_dbc = '1' or s_dbc = '1' or n_dbc = '1' then
                            state <= ALRM;
                        else
                            state <= R3;
                        end if;                    
                    
                    when REST =>

                        unlock_flag <= false;
                        alarm_flag <= false;
                        state <= IDLE;                        

                    end case;
                end if;            
    end process;

    rst <= n and e;

end Behavioral;
