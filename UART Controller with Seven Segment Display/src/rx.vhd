library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    generic(
        D_BITS  : integer := 8; --data size
        SAMPLES : integer := 16; -- sample rate
        STOP_SAMPLES : integer := 16 -- to allow for 1, 1.5, 2 stop bits 
        );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rx : in STD_LOGIC; -- data recieved
           tick : in STD_LOGIC;
           rx_done : out STD_LOGIC;
           d_out : out STD_LOGIC_VECTOR (7 downto 0));
end uart_rx;

architecture Behavioral of uart_rx is

    type state_type is (idle, start, data, stop);
    signal curr_state        : state_type;
    signal next_state        : state_type;    
    signal sample_count_reg  : unsigned(4 downto 0);
    signal sample_count_next : unsigned(4 downto 0);
    signal data_count_reg    : unsigned(2 downto 0);
    signal data_count_next   : unsigned(2 downto 0);
    signal data_reg          : std_logic_vector(7 downto 0);
    signal data_next         : std_logic_vector(7 downto 0);
    signal sync1_reg         : std_logic; --resolve metastability sync signals 
    signal sync2_reg         : std_logic;
    signal sync_rx           : std_logic;
    
begin
   -- synchronization for rx
    process(clk, rst)
    begin
        if rst = '1' then
            sync1_reg <= '0';
            sync2_reg <= '0';
        elsif rising_edge(clk) then
            sync1_reg <= rx;
            sync2_reg <= sync1_reg;
        end if;
    end process;
    sync_rx <= sync2_reg;

   -- data state machine
    process(clk, rst)
    begin
        if rst = '1' then
            curr_state <= idle;
            sample_count_reg   <= (others => '0');
            data_count_reg     <= (others => '0');
            data_reg           <= (others => '0');
        elsif rising_edge(clk) then
            curr_state         <= next_state;
            sample_count_reg   <= sample_count_next;
            data_count_reg     <= data_count_next;
            data_reg           <= data_next;
        end if;
    end process;

    -- next-state logic & data path 
    process(curr_state, sample_count_reg, data_count_reg, data_reg, tick, sync_rx)
    begin
        next_state        <= curr_state;
        sample_count_next <= sample_count_reg;
        data_count_next   <= data_count_reg;
        data_next         <= data_reg;
        rx_done <= '0';
        case curr_state is
            when idle =>
                if sync_rx = '0' then
                    next_state <= start;
                    sample_count_next <= (others => '0');
                end if;
            when start =>
                if tick = '1' then
                    if sample_count_reg = (SAMPLES/2) - 1 then
                        next_state <= data;
                        sample_count_next <= (others => '0');
                        data_count_next   <= (others => '0');
                    else
                        sample_count_next <= sample_count_reg + 1;    
                    end if;
                end if;        
            when data => 
                if tick = '1' then
                    if sample_count_reg = SAMPLES - 1 then
                        sample_count_next <= (others => '0');
                        data_next <= sync_rx & data_reg(7 downto 1);
                        if data_count_reg = (D_BITS - 1) then
                            next_state <= stop;
                        else
                            data_count_next <= data_count_reg + 1;
                        end if;    
                    else
                        sample_count_next <= sample_count_reg + 1;    
                    end if;
                end if;  
            when stop =>
                if tick = '1' then
                    if sample_count_reg = STOP_SAMPLES - 1 then
                        next_state <= idle;
                        rx_done <= '1';
                    else
                        sample_count_next <= sample_count_reg + 1;    
                    end if;    
                end if;
        end case;
    end process;
    d_out <= data_reg;

end Behavioral;
