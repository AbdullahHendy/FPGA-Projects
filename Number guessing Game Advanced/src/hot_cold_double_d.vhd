library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity hot_cold_double_d is
    port
    (
        clk_top   : in std_logic;
        rst_top   : in std_logic; --debounce
        show      : in std_logic; --debounce
        enter     : in std_logic; --debounce
        randomize : in std_logic; --debounce
        row_top   : in std_logic_vector (3 downto 0); 
        col_top   : out std_logic_vector (3 downto 0);
        seg       : out std_logic_vector (6 downto 0);
        sel       : out std_logic;
        red_led   : out std_logic;
        blue_led  : out std_logic;
        green_led : out std_logic
    );
end hot_cold_double_d;

architecture Behavioral of hot_cold_double_d is
    
    constant clk_freq_top: natural := 50000000; --system clock frequency in Hz
    constant debounce_time: natural := 1000; --debounce time in ms
    constant desired_freq: natural := 2; --desired frequency after division in Hz
    
    type state_type is (IDLE, CHECK, OVER);
    signal state: state_type;
    type state_disp_type is (NUM1, NUM2);
    signal disp_state: state_disp_type;
        
    signal debounced_rst, debounced_enter, debounced_show, debounced_randomize: std_logic;
    signal divided_clk: std_logic;
    signal random_nums: std_logic_vector(3 downto 0);
    signal random_num_tens: std_logic_vector(3 downto 0);
    signal random_num_ones: std_logic_vector(3 downto 0);
    signal user_choice_tens: std_logic_vector(3 downto 0);
    signal user_choice_ones: std_logic_vector(3 downto 0);
    signal user_choice: natural;
    signal secret_num_tens: std_logic_vector(3 downto 0);
    signal secret_num_ones: std_logic_vector(3 downto 0);
    signal secret_num: natural := 0; --secret num can be 0 in this design
    signal blink_flag: boolean;
    signal counter: natural;
    
    signal sel_reg : std_logic;
    signal to_be_displayed : std_logic_vector(3 downto 0);
    signal disp_val_reg : std_logic_vector(3 downto 0);
    signal user_choice_reg : std_logic_vector(3 downto 0);
    signal is_pressed_reg : std_logic;
    signal is_pressed_reg_debounced : std_logic;
    signal disp_counter : natural range 0 to 50000000 := 0;
    
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
            clk_freq    : integer := 50000; --system clock frequency in Hz (divided by 1000)
            stable_time : integer := debounce_time);   --time button must remain stable in ms
        port
        (
            clk    : in std_logic;   --input clock
            rst    : in std_logic;   --asynchronous active high reset
            button : in std_logic;   --input signal to be debounced
            result : out std_logic); --debounced signal
    end component debounce;
    
    component disp_ctrl is
        port
        (
            disp_val : in std_logic_vector (3 downto 0);
            seg_out  : out std_logic_vector(6 downto 0));
    end component disp_ctrl; 
    
    
    component keypad_decoder is
        port
        (
            clk : in std_logic;
            rst : in std_logic;
            row : in std_logic_vector(3 downto 0);
            col : out std_logic_vector(3 downto 0);
            decode_out : out std_logic_vector(3 downto 0);
            is_pressed : out std_logic);
    end component keypad_decoder;
        
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
    
    PRSD_DEBNC: debounce port map (
       clk => clk_top,
       rst => debounced_rst,
       button => is_pressed_reg,
       result => is_pressed_reg_debounced);  
       
    RAND_NUMS: rand_gen port map (
       clk => clk_top,
       rst => debounced_rst,
       seed => "10100001",
       output => random_nums);
                  
    RAND_NUM_TENS: rand_gen port map (
       clk => clk_top,
       rst => debounced_rst,
       seed => "10100001",
       output => random_num_tens);
       
    RAND_NUM_ONES: rand_gen port map (
       clk => clk_top,
       rst => debounced_rst,
       seed => "00110001",
       output => random_num_ones);
       
    SSD_1: disp_ctrl port map (
       disp_val => to_be_displayed,
       seg_out => seg);
       
    KYPD_DCDR: keypad_decoder port map (
             clk => clk_top,
             rst => debounced_rst,
             row => row_top,
             col => col_top,
             decode_out => user_choice_reg,
             is_pressed => is_pressed_reg);
       
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
    
    SHOW_2_NUMS: process(clk_top, debounced_rst)
     begin
        if (debounced_rst = '1') then
            disp_state <= NUM1;
            user_choice_tens <= (others => '0');
            user_choice_ones <= (others => '0');
        elsif rising_edge(clk_top) then
            case disp_state is
                when NUM1 =>
                        if is_pressed_reg_debounced = '1' then
                            user_choice_tens <= user_choice_reg;
                            disp_state <= NUM2;    
                        end if;
                when NUM2 =>
                        if is_pressed_reg_debounced = '1' then
                            user_choice_ones <= user_choice_reg;
                            disp_state <= NUM1;    
                        end if;
            end case;    
        end if;    
    end process;

    process (clk_top, debounced_rst, debounced_enter, debounced_show, debounced_randomize) --seqential 
        begin 
            if debounced_rst = '1' then
                state <= IDLE;
                red_led <= '0';
                blue_led <= '0';
                blink_flag <= false;
            elsif rising_edge(clk_top) then
                case state is
                    when idle =>
                        ----------------------------------------------------- 
                        if disp_counter = 1000000 then --flash at 20ms to show both (1/50 = 0.02)
                            sel_reg <= '1';
                            to_be_displayed <= user_choice_tens;
                            disp_counter <= disp_counter + 1;
                        elsif disp_counter = 2000000 then
                            sel_reg <= '0';
                            to_be_displayed <= user_choice_ones;
                            disp_counter <= 0;
                        else 
                            disp_counter <= disp_counter + 1;
                        end if;
                        -----------------------------------------------------
                        if debounced_randomize = '1' then
                            secret_num_tens <= random_num_tens;
                            secret_num_ones <= random_num_ones;
                            state <= CHECK;                            
                        elsif debounced_show = '1' then
                            state <= OVER;
                        end if;                      
                    when CHECK =>
                        ----------------------------------------------------- 
                        if disp_counter = 1000000 then --flash at 20ms to show both (1/50 = 0.02)
                            sel_reg <= '1';
                            to_be_displayed <= user_choice_tens;
                            disp_counter <= disp_counter + 1;
                        elsif disp_counter = 2000000 then
                            sel_reg <= '0';
                            to_be_displayed <= user_choice_ones;
                            disp_counter <= 0;
                        else 
                            disp_counter <= disp_counter + 1;
                        end if;
                        ----------------------------------------------------- 
                        if debounced_enter = '1' then
                            if user_choice > secret_num then
                                state <= CHECK;
                                red_led <= '1';
                                blue_led <= '0';
                                blink_flag <= false;
                            elsif user_choice < secret_num then
                                state <= CHECK;
                                red_led <= '0';
                                blue_led <= '1';
                                blink_flag <= false;
                            else
                                state <= OVER;
                                red_led <= '0';
                                blue_led <= '0';
                                blink_flag <= true;
                            end if; 
                        elsif debounced_show = '1' then
                            state <= OVER;
                        end if;                        
                    when OVER =>
                        ----------------------------------------------------- 
                        if disp_counter = 1000000 then --flash at 20ms to show both (1/50 = 0.02)
                            sel_reg <= '1';
                            to_be_displayed <= secret_num_tens;
                            disp_counter <= disp_counter + 1;
                        elsif disp_counter = 2000000 then
                            sel_reg <= '0';
                            to_be_displayed <= secret_num_ones;
                            disp_counter <= 0;
                        else 
                            disp_counter <= disp_counter + 1;
                        end if;
                        ----------------------------------------------------- 
                        disp_val_reg <= std_logic_vector(to_unsigned(secret_num, 4));
                        red_led <= '0';
                        blue_led <= '0';
                    end case;
                end if;            
    end process;

    user_choice <= (to_integer(unsigned(user_choice_tens)))*10 + (to_integer(unsigned(user_choice_ones)))*1; --combinational part
    secret_num  <= (to_integer(unsigned(secret_num_tens)))*10 + (to_integer(unsigned(secret_num_ones)))*1;
    sel <= sel_reg;
    
end Behavioral;