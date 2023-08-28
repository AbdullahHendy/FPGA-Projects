library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity std_fifo_top is
  generic(
     ADDR_WIDTH : integer := 3;
     DATA_WIDTH : integer := 4
  );
  port(
     std_clk_top, std_rst_top : in  std_logic;
     std_wr_top, std_rd_top   : in  std_logic;
     std_w_data_top     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
     std_empty_top      : out std_logic;
     std_full_top       : out std_logic;
     std_r_data_top     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
  );
end std_fifo_top;

architecture Behavioral of std_fifo_top is

component fwft_fifo_top is
  generic(
     ADDR_WIDTH : integer := 3;
     DATA_WIDTH : integer := 8
  );
  port(
     fwft_clk_top, fwft_rst_top : in  std_logic;
     fwft_wr_top, fwft_rd_top   : in  std_logic;
     fwft_w_data_top     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
     fwft_empty_top      : out std_logic;
     fwft_full_top       : out std_logic;
     fwft_r_data_top     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
  );
end component fwft_fifo_top;

signal fwft_r_data_top_temp: std_logic_vector(DATA_WIDTH - 1 downto 0);

begin

    FWFT_FIFO: fwft_fifo_top
    
    port map(
        fwft_clk_top => std_clk_top,
        fwft_rst_top => std_rst_top,
        fwft_wr_top => std_wr_top,
        fwft_rd_top => std_rd_top,
        fwft_w_data_top => std_w_data_top,
        fwft_empty_top => std_empty_top,
        fwft_full_top => std_full_top,
        fwft_r_data_top => fwft_r_data_top_temp
    );


process (std_clk_top, std_rst_top)
begin
    if std_rst_top = '1' then
        std_r_data_top <= (others => '0');
    elsif rising_edge(std_clk_top) then
        if std_rd_top = '1' then
            std_r_data_top <= fwft_r_data_top_temp;    
        end if;
    end if;
        
end process;

end Behavioral;
