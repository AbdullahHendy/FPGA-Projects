library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity test_uart is
   Port ( clk : in STD_LOGIC;
          rst : in STD_LOGIC;
          led : out std_logic_vector(3 downto 0);
          ssd_disp : out std_logic_vector(6 downto 0);
          tx : out STD_LOGIC;
          rx : in STD_LOGIC);
end test_uart;

architecture Behavioral of test_uart is

component uart_top is
   generic(
      D_BITS       : integer := 8;   -- # data bits
      STOP_SAMPLES : integer := 16;  -- # ticks for stop bits, 16 per bit
      FIFO_ADDR_W  : integer := 5    -- # FIFO addr bits (depth: 2^FIFO_W)
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
end component uart_top;

component disp_ctrl is
    port(
        disp_val : in std_logic_vector(3 downto 0);
        seg_out  : out std_logic_vector(6 downto 0)
    );
end component disp_ctrl;


constant dvsr: std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(68, 11)); -- dvsr = SYS_CLK_FREQ_M*1000000 / 16 / baud - 1; roundup(125 * 1_000_000)/16/(115200-1);


signal wr_uart  : std_logic;
signal rd_uart  : std_logic;
signal tx_full  : std_logic;
signal rx_empty : std_logic;
signal r_data   : std_logic_vector(7 downto 0);
signal w_data   : std_logic_vector(7 downto 0);

signal counter : integer range 0 to 125000000 := 0;


begin

uart_i: uart_top port map (
     clk_uart       => clk,
     rst_uart       => rst,
     wr_uart        => wr_uart,
     rd_uart        => rd_uart,
     dvsr_uart      => dvsr,
     rx_uart        => rx,
     w_data_uart    => w_data,
     tx_full_uart   => tx_full,
     rx_empty_uart  => rx_empty,
     r_data_uart    => r_data,
     tx_uart        => tx
);


display_ctrl: disp_ctrl port map (
    disp_val => r_data(3 downto 0),
    seg_out => ssd_disp
    );

process (clk, rst) 
begin

    if rst = '1' then
        w_data <= (others => '0');
    elsif rising_edge(clk) then
        if counter = 125000000-4 then
            wr_uart <= '1';
            w_data <= "00110010"; -- ascii 2
            counter <= counter + 1;
        elsif counter = 125000000-4+1 then
            wr_uart <= '1';
            w_data <= "00001010"; -- ascii LF
            counter <= counter + 1;
        elsif counter = 125000000-4+2 then
            wr_uart <= '1';
            w_data <= "00001101"; -- ascii CR
            counter <= counter + 1;            
        elsif counter = 125000000-4+3 then
            wr_uart <= '0';
            counter <= 0;
        else 
            counter <= counter + 1;    
        end if;    
    end if;

end process;

led <= r_data(3 downto 0);
rd_uart <= '1';

end Behavioral;




