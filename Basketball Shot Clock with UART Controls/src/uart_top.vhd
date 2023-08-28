library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--baud rate = clock rate/16/(dvsr+1)
entity uart_top is
   generic(
      D_BITS       : integer := 8;   -- # data bits
      STOP_SAMPLES : integer := 16;  -- # ticks for stop bits, 16 per bit
      FIFO_ADDR_W  : integer := 4    -- # FIFO addr bits (depth: 2^FIFO_W)
   );
   port(
      clk_uart      : in  std_logic;
      rst_uart      : in std_logic;
      wr_uart       : in  std_logic;
      rd_uart       : in  std_logic;
      dvsr_uart     : in  std_logic_vector(10 downto 0);
      rx_uart       : in  std_logic;
      w_data_uart   : in  std_logic_vector(7 downto 0);
      tx_full_uart  : out std_logic;
      rx_empty_uart : out std_logic;
      r_data_uart   : out std_logic_vector(7 downto 0);
      tx_uart       : out std_logic
   );
end uart_top;

architecture Behavioral of uart_top is

    component uart_baud_gen is
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               dvsr : in STD_LOGIC_VECTOR (10 downto 0); --allow for baudrate of 9600 dvsr = (topclk/(baudrate * sampling rate))-1, topclk = 125MHz
               tick : out STD_LOGIC);
    end component uart_baud_gen;
    
    component uart_rx is
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
    end component uart_rx;
    
    component uart_tx is
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
    end component uart_tx;
    
    component std_fifo_top is
      generic(
         ADDR_WIDTH : integer := 3;
         DATA_WIDTH : integer := 8
      );
      port(
         std_clk_top, std_rst_top : in  std_logic;
         std_wr_top, std_rd_top   : in  std_logic;
         std_w_data_top     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
         std_empty_top      : out std_logic;
         std_full_top       : out std_logic;
         std_r_data_top     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
      );
    end component std_fifo_top;
    
    signal tick_uart           : std_logic;
    signal rx_done_uart        : std_logic;
    signal rx_d_out_uart       : std_logic_vector(7 downto 0);
    signal tx_done_uart        : std_logic;
    signal tx_fifo_empty_uart  : std_logic;
    signal tx_fifo_not_empty_uart : std_logic;
    signal tx_fifo_r_data_uart : std_logic_vector(7 downto 0);


begin

    baud_gen_unit : uart_baud_gen
        port map(
            clk  => clk_uart,
            rst => rst_uart,
            dvsr => dvsr_uart,
            tick => tick_uart
        );

   fifo_tx_unit : std_fifo_top
      generic map(DATA_WIDTH => D_BITS, ADDR_WIDTH => FIFO_ADDR_W)
      port map(
         std_clk_top    => clk_uart,
         std_rst_top    => rst_uart,
         std_wr_top     => wr_uart,
         std_rd_top     => tx_done_uart,
         std_w_data_top => w_data_uart,
         std_empty_top  => tx_fifo_empty_uart,
         std_full_top   => tx_full_uart,
         std_r_data_top => tx_fifo_r_data_uart
      );

    uart_tx_unit : uart_tx
        generic map(D_BITS => D_BITS, STOP_SAMPLES => STOP_SAMPLES)
        port map(
            clk      => clk_uart,
            rst      => rst_uart,
            tx_start => tx_fifo_not_empty_uart, --as long as tx fifo is not empty keep sending
            tx       => tx_fifo_r_data_uart,
            tick     => tick_uart,
            tx_done  => tx_done_uart,
            d_out    => tx_uart
      );

    tx_fifo_not_empty_uart <= not tx_fifo_empty_uart;

    uart_rx_unit : uart_rx
        generic map(D_BITS => D_BITS, STOP_SAMPLES => STOP_SAMPLES)
        port map(
            clk     => clk_uart,
            rst     => rst_uart,
            rx      => rx_uart,
            tick    => tick_uart,
            rx_done => rx_done_uart,
            d_out   => rx_d_out_uart
      );

   fifo_rx_unit : std_fifo_top
      generic map(DATA_WIDTH => D_BITS, ADDR_WIDTH => FIFO_ADDR_W)
      port map(
         std_clk_top    => clk_uart,
         std_rst_top    => rst_uart,
         std_wr_top     => rx_done_uart,
         std_rd_top     => rd_uart,
         std_w_data_top => rx_d_out_uart,
         std_empty_top  => rx_empty_uart,
         std_full_top   => open,
         std_r_data_top => r_data_uart
      );

end Behavioral;
