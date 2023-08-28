library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    generic(
        D_BITS  : integer := 8; --data size
        SAMPLES : integer := 16; -- sample rate
        STOP_SAMPLES : integer := 16 -- to allow for 1, 1.5, 2 stop bits 
        );
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           tx_start : STD_LOGIC;
           tx : in STD_LOGIC_VECTOR (7 downto 0); --data to be transmitted
           tick : in STD_LOGIC;
           tx_done : out STD_LOGIC;
           d_out : out STD_LOGIC);
end uart_tx;

architecture Behavioral of uart_tx is

    type state_type is (idle, start, data, stop);
    signal curr_state        : state_type;
    signal next_state        : state_type;    
    signal sample_count_reg  : unsigned(4 downto 0);
    signal sample_count_next : unsigned(4 downto 0);
    signal data_count_reg    : unsigned(2 downto 0);
    signal data_count_next   : unsigned(2 downto 0);
    signal data_reg          : std_logic_vector(7 downto 0);
    signal data_next         : std_logic_vector(7 downto 0);
    signal d_out_reg         : std_logic;
    signal d_out_next        : std_logic;
    
begin

   -- data state machine
    process(clk, rst)
    begin
        if rst = '1' then
            curr_state <= idle;
            sample_count_reg   <= (others => '0');
            data_count_reg     <= (others => '0');
            data_reg           <= (others => '0');
            d_out_reg       <= '1';
        elsif rising_edge(clk) then
            curr_state         <= next_state;
            sample_count_reg   <= sample_count_next;
            data_count_reg     <= data_count_next;
            data_reg           <= data_next;
            d_out_reg       <= d_out_next;
        end if;
    end process;

    -- next-state logic & data path 
    process(curr_state, sample_count_reg, data_count_reg, data_reg, tick, d_out_reg, tx, tx_start)
    begin
        next_state <= curr_state;    
        sample_count_next <= sample_count_reg;
        data_count_next <= data_count_reg;
        data_next <= data_reg;
        d_out_next <= d_out_reg;
        tx_done <= '0';
        case curr_state is
            when idle =>
                d_out_next <= '1';
                if tx_start = '1' then
                    next_state <= start;
                    sample_count_next   <= (others => '0');
                    data_next <= tx;
                    end if;
            when start =>
                d_out_next <= '0';
                if tick = '1' then
                    if sample_count_reg = SAMPLES - 1 then --send the start bit
                        next_state <= data;
                        sample_count_next <= (others => '0');
                        data_count_next   <= (others => '0');
                    else
                        sample_count_next <= sample_count_reg + 1;    
                    end if;                
                end if;
            when data => 
                d_out_next <= data_reg(0);
                if tick = '1' then
                    if sample_count_reg = SAMPLES - 1 then --send the start bit
                        sample_count_next <= (others => '0');
                        data_next <= data_reg srl 1;
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
                d_out_next <= '1';
                if tick = '1' then
                    if sample_count_reg = STOP_SAMPLES - 1 then
                        next_state <= idle;
                        tx_done <= '1';
                    else
                        sample_count_next <= sample_count_reg + 1;    
                    end if;    
                end if;
        end case;        
    end process;

d_out <= d_out_reg;

end Behavioral;
