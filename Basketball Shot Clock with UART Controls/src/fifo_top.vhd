library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fwft_fifo_top is
  generic(
     ADDR_WIDTH : integer := 3;
     DATA_WIDTH : integer := 4
  );
  port(
     fwft_clk_top, fwft_rst_top : in  std_logic;
     fwft_wr_top, fwft_rd_top   : in  std_logic;
     fwft_w_data_top     : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
     fwft_empty_top      : out std_logic;
     fwft_full_top       : out std_logic;
     fwft_r_data_top     : out std_logic_vector(DATA_WIDTH - 1 downto 0)
  );
end fwft_fifo_top;

architecture behavioural of fwft_fifo_top is

component reg_file is
    generic(
        ADDR_WIDTH : integer := 3;
        DATA_WIDTH : integer := 8;
        REG_FILE_DEPTH : integer := 2**ADDR_WIDTH
    );
    port(
        clk    : in  std_logic;
        wr_en  : in  std_logic;
        w_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        r_addr : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        w_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        r_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end component reg_file;

component fifo_ctrl is
  generic(ADDR_WIDTH : natural := 3);
  port(
     clk, rst  : in  std_logic;
     wr, rd      : in  std_logic;
     empty, full : out std_logic;
     w_addr      : out std_logic_vector(ADDR_WIDTH-1 downto 0);
     r_addr      : out std_logic_vector(ADDR_WIDTH-1 downto 0)
  );
end component fifo_ctrl;

signal fwft_w_addr_top, fwft_r_addr_top : std_logic_vector(ADDR_WIDTH-1 downto 0);


begin

    FIFO_CONTROL: fifo_ctrl
    port map(
        clk => fwft_clk_top,
        rst => fwft_rst_top,
        wr => fwft_wr_top,
        rd => fwft_rd_top,
        empty => fwft_empty_top,
        full => fwft_full_top,
        w_addr => fwft_w_addr_top,
        r_addr => fwft_r_addr_top
    );

    REGISTER_FILE: reg_file
    port map(
        clk => fwft_clk_top,
        wr_en => fwft_wr_top and not fwft_full_top,
        w_addr => fwft_w_addr_top,
        r_addr => fwft_r_addr_top,
        w_data => fwft_w_data_top,
        r_data => fwft_r_data_top
    );
    

end architecture;