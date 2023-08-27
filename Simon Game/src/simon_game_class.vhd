library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity simon_game_class is
    Port ( clk_top : in STD_LOGIC;
           btns : in STD_LOGIC_VECTOR (3 downto 0);
           leds : out STD_LOGIC_VECTOR (3 downto 0);
           red : out STD_LOGIC;
           green : out STD_LOGIC;
           blue : out STD_LOGIC);
end simon_game_class;

architecture Behavioral of simon_game_class is

    constant MAX_LEVEL: natural := 32;

    type state_type is (IDLE, NUM_GEN, NUM_DISP, USER_INP, CHECK_INP, CORRECT_INP, INCORRECT_INP, WON, OVER);
    signal state: state_type;
    
    type mem_type is array (1 to MAX_LEVEL) of std_logic_vector(3 downto 0);
    signal nums_mem: mem_type;
    signal user_mem: mem_type;
    
    -- set clk_freq_top = 10, debounce_time = 1 for simulation to work, also change debounce generic parameters in the port map
    constant clk_freq_top: natural := 125000000; --system clock frequency in Hz
    constant debounce_time: natural := 200; --debounce time in ms

    signal rst_top: std_logic;
    signal debounced_btns: std_logic_vector(3 downto 0);
    signal random_nums: std_logic_vector(3 downto 0);
    signal level: positive := 1;
    signal mems_index: positive := 1;
    signal disp_counter: integer := 0;
    signal leds_reg: std_logic_vector(3 downto 0);
    signal rgb_reg: std_logic_vector(2 downto 0);

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
            clk_freq    : integer := 125000; --system clock frequency in Hz (divided by 1000) --set to 1 for simulation to work
            stable_time : integer := debounce_time);   --time button must remain stable in ms
        port
        (
            clk    : in std_logic;   --input clock
            rst    : in std_logic;   --asynchronous active high reset
            button : in std_logic;   --input signal to be debounced
            result : out std_logic); --debounced signal
    end component debounce;


begin

    PB0_DEBNC: debounce port map (clk => clk_top, rst => rst_top, button => btns(0), result => debounced_btns(0));
    PB1_DEBNC: debounce port map (clk => clk_top, rst => rst_top, button => btns(1), result => debounced_btns(1));
    PB2_DEBNC: debounce port map (clk => clk_top, rst => rst_top, button => btns(2), result => debounced_btns(2));
    PB3_DEBNC: debounce port map (clk => clk_top, rst => rst_top, button => btns(3), result => debounced_btns(3));
       
    RAND_NUMS: rand_gen port map (clk => clk_top, rst => rst_top, seed => "01010111", output => random_nums); 

   
    state_logic: process (clk_top, rst_top) --current state and output
    begin
    
        if rst_top = '1' then
            state <= IDLE;
            rgb_reg <= (others => '0');
            leds_reg <= (others => '0');            
            level <= 1;
            nums_mem <= (others => (others => '0'));
            user_mem <= (others => (others => '0'));
            mems_index <= 1;
            disp_counter <= 0;
            -- make sure everything is reset
        elsif rising_edge(clk_top) then
            case state is 
                when IDLE =>
                    state <= NUM_GEN;  
                      
                when NUM_GEN =>
                    nums_mem(level) <= random_nums;
                    if level = MAX_LEVEL then
                        state <= WON; -- maybe change to keep going

                    end if;        
                    state <= NUM_DISP; -- generate a number then display it
                    
                when NUM_DISP =>
                    rgb_reg <= "000";
                    if mems_index <= level then
                        if disp_counter = 0 then
                            leds_reg <= (others => '0');
                        elsif disp_counter = 1 then -- wait for 1 clock cycle to allow nums_mem to be updated before reading it
                            leds_reg <= nums_mem(mems_index);
                        elsif disp_counter = clk_freq_top/2 then
                            leds_reg <= (others => '0');
                        elsif disp_counter = clk_freq_top then
                            mems_index <= mems_index + 1;
                            disp_counter <= 0;
                        end if;
                        if disp_counter < clk_freq_top then
                            disp_counter <= disp_counter + 1;                                     
                        end if;
                    else
                        user_mem <= (others => (others => '0'));
                        leds_reg <= (others => '0');
                        mems_index <= 1;
                        state <= USER_INP;
                    end if;
                        
                when USER_INP =>
                    rgb_reg <= "001";
                    if mems_index <= level then
                        if debounced_btns(0) = '1' then --priority mux to prevent two simultanious clicks
                            user_mem(mems_index) <= "0001";
                            state <= CHECK_INP;
                        elsif debounced_btns(1) = '1' then
                            user_mem(mems_index) <= "0010";
                            state <= CHECK_INP;
                        elsif debounced_btns(2) = '1' then
                            user_mem(mems_index) <= "0100"; 
                            state <= CHECK_INP;
                        elsif debounced_btns(3) = '1' then
                            user_mem(mems_index) <= "1000";
                            state <= CHECK_INP;
                        end if;
                    else    
                        mems_index <= 1;
                        rgb_reg <= "000";
                        state <= CORRECT_INP;
                        --state <= CHECK_INP;
                    end if;
                    
                when CHECK_INP =>
                    if mems_index <= level then
                        if user_mem(mems_index) /= nums_mem(mems_index) then
                            mems_index <= 1;
                            disp_counter <= 0;
                            state <= INCORRECT_INP;
                        else
                            mems_index <= mems_index + 1;
                            state <= USER_INP;
                        end if;
                    else -- means all inputs are correct  
                        mems_index <= 1;
                        disp_counter <= 0;
                        state <= CORRECT_INP;
                    end if;    
                
                when CORRECT_INP =>
                    rgb_reg <= "010";
                    if disp_counter < clk_freq_top-1 then
                        disp_counter <= disp_counter + 1;
                    elsif disp_counter = clk_freq_top-1 then
                            state <= NUM_GEN;
                            level <= level + 1;
                            disp_counter <= 0;
                    end if;
                
                when INCORRECT_INP =>
                    if mems_index < level then
                        if disp_counter = 0 then
                            rgb_reg <= "100";
                        elsif disp_counter = clk_freq_top/2 then
                            rgb_reg <= "000";
                        elsif disp_counter = clk_freq_top then
                            mems_index <= mems_index + 1;
                            disp_counter <= 0;
                        end if;
                        if disp_counter < clk_freq_top then
                            disp_counter <= disp_counter + 1;                                     
                        end if;
                    else -- means all inputs are correct  
                        mems_index <= 1;
                        disp_counter <= 0;
                        state <= OVER;
                    end if; 
                                        
                when WON =>
                    rgb_reg <= "010";
                    state <= WON;
                    
                when OVER =>
                    rgb_reg <= "100";
                    state <= OVER;
            end case;
       
            
        end if;

end process;

rst_top <= btns(0) and btns(3);
leds <= leds_reg;
red <= rgb_reg(2); 
green <= rgb_reg(1);
blue <= rgb_reg(0);

end Behavioral;
