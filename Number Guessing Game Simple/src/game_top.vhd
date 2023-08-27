library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity number_guess is
    port
    (
        clk_top   : in std_logic;
        rst_top   : in std_logic; --debounce
        show      : in std_logic; --debounce
        enter     : in std_logic; --debounce
        randomize : in std_logic; --debounce
        switches  : in std_logic_vector (3 downto 0); --no need for debouncing
        leds      : out std_logic_vector (3 downto 0);
        red_led   : out std_logic;
        blue_led  : out std_logic;
        green_led : out std_logic
    );
end number_guess;

architecture Behavioral of number_guess is
    
    constant clk_freq_top: natural := 125000000; --system clock frequency in Hz
    constant clk_period_top: natural := 1/clk_freq_top; --system clock period in second
    constant debounce_time: natural := 100; --debounce time in ms
    constant desired_freq: natural := 2; --desired frequency after division in Hz
    
    signal debounced_rst, debounced_enter, debounced_show, debounced_randomize: std_logic;
    signal divided_clk: std_logic;
    signal random_nums: std_logic_vector(3 downto 0);
    signal user_choice: natural;
    signal secret_num: natural := 1; --secret num cannot be 0, initialize to 1
    signal blink_flag: boolean;
    signal counter: natural;
    
    component rand_gen is
        port
        (
            clk, rst : in std_logic;
            seed     : in std_logic_vector (7 downto 0);
            output   : out std_logic_vector (3 downto 0)
        );
    end component rand_gen;
    
    component debounce is
        generic
        (
            clk_freq    : integer := 125000; --system clock frequency in Hz divided by 1000
            stable_time : integer := debounce_time);   --time button must remain stable in ms
        port
        (
            clk    : in std_logic;   --input clock
            rst    : in std_logic;   --asynchronous active high reset
            button : in std_logic;   --input signal to be debounced
            result : out std_logic); --debounced signal
    end component debounce;
    
begin
  
    RST_DEBNC: debounce port map (
       clk => clk_top,
       rst => '0',
       button => rst_top,
       result => debounced_rst);
       
    ENTR_DEBNC: debounce port map (
       clk => clk_top,
       rst => debounced_rst,
       button => enter,
       result => debounced_enter);
    
    SHOW_DEBNC: debounce port map (
       clk => clk_top,
       rst => debounced_rst,
       button => show,
       result => debounced_show);
       
    RNDMZ_DEBNC: debounce port map (
       clk => clk_top,
       rst => debounced_rst,
       button => randomize,
       result => debounced_randomize);       
    
    RAND_NUMS: rand_gen port map (
       clk => clk_top,
       rst => debounced_rst,
       seed => "10100001",
       output => random_nums);
       
       
    clock_div: process (clk_top, debounced_rst) --clock divider
        begin
            if debounced_rst = '1' then
                divided_clk <= '0';
                counter <= 0;
            elsif rising_edge(clk_top) then
                counter <= counter + 1;
                if counter = (clk_freq_top/(2*desired_freq))-1 then
                    divided_clk <= not divided_clk;
                    counter <= 0;
                end if;    
            end if;
    end process;
    
    blink_led: process (divided_clk, debounced_rst, blink_flag) --led blinker
        begin
            if debounced_rst = '1' then
                green_led <= '0';
            elsif rising_edge(divided_clk) then
                if blink_flag = true then
                    green_led <= not green_led;
                else 
                    green_led <= '0';
                end if;    
            end if;
    end process;       
    
    process (clk_top, debounced_rst, debounced_enter, debounced_show, debounced_randomize, switches) --seqential 
        begin 
            if debounced_rst = '1' then
                leds <= "0000";
                red_led <= '0';
                blue_led <= '0';
                blink_flag <= false;
            elsif rising_edge(clk_top) then
                if debounced_randomize = '1' then
                    secret_num <= to_integer(unsigned(random_nums));                            
                elsif debounced_show = '1' then
                    leds <= std_logic_vector(to_unsigned(secret_num, 4));                    
                elsif debounced_enter = '1' then
                    if user_choice > secret_num then
                        red_led <= '1';
                        blue_led <= '0';
                        blink_flag <= false;
                    elsif user_choice < secret_num then
                        red_led <= '0';
                        blue_led <= '1';
                        blink_flag <= false;
                    else
                        red_led <= '0';
                        blue_led <= '0';
                        blink_flag <= true;
                    end if; 
                end if;       
            end if;            
            
    end process;

    user_choice <= to_integer(unsigned(switches)); --combinational part
end Behavioral;