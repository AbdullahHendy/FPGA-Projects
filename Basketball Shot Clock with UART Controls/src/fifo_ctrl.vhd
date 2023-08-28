library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo_ctrl is
  generic(ADDR_WIDTH : natural := 3);
  port(
     clk, rst  : in  std_logic;
     wr, rd      : in  std_logic;
     empty, full : out std_logic;
     w_addr      : out std_logic_vector(ADDR_WIDTH-1 downto 0);
     r_addr      : out std_logic_vector(ADDR_WIDTH-1 downto 0)
  );
end fifo_ctrl;

architecture arch of fifo_ctrl is

signal w_ptr_reg, r_ptr_reg : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal w_ptr_reg_next, r_ptr_reg_next : std_logic_vector(ADDR_WIDTH-1 downto 0);
signal empty_reg, full_reg : std_logic;
signal empty_reg_next, full_reg_next : std_logic; 


begin

process (clk, rst) 
begin
    if rst = '1' then
        empty_reg <= '1';
        full_reg <= '0';
        w_ptr_reg <= (others => '0');
        r_ptr_reg <= (others => '0');       
    elsif rising_edge(clk) then
        empty_reg <= empty_reg_next;
        full_reg <= full_reg_next;
        w_ptr_reg <= w_ptr_reg_next;
        r_ptr_reg <= r_ptr_reg_next;        
    end if;
    

end process;

process (clk, w_ptr_reg, r_ptr_reg, empty_reg, full_reg, rd, wr) 
begin
    empty_reg_next <= empty_reg;
    full_reg_next  <= full_reg;
    w_ptr_reg_next <= w_ptr_reg;
    r_ptr_reg_next <= r_ptr_reg;    
    if (wr = '0' and rd = '0') or (wr = '1' and rd = '1') then
    --do nothing
    elsif wr = '1' and rd = '0' then
        if empty_reg = '1' and r_ptr_reg /= w_ptr_reg  then -- if its not the initial case and fifo is empty, increment read ptr to read the next data written
            r_ptr_reg_next <= std_logic_vector(unsigned(r_ptr_reg) + 1);    
        end if;    
        if full_reg /= '1' then
            empty_reg_next <= '0'; --queue is not empty after the first write
            w_ptr_reg_next <= std_logic_vector(unsigned(w_ptr_reg) + 1);
            if std_logic_vector(unsigned(w_ptr_reg) + 1) = r_ptr_reg then --circular queue, if write ptr is the same as read ptr, queue is full 
                full_reg_next <= '1';
            end if;
        end if;     
    elsif wr = '0' and rd = '1' then
        if empty_reg /= '1' then
            full_reg_next <= '0'; --queue is not full after a value is read
            r_ptr_reg_next <= std_logic_vector(unsigned(r_ptr_reg) + 1);
            if std_logic_vector(unsigned(r_ptr_reg) + 1) = w_ptr_reg then --circular queue, if read ptr is the same as write ptr, queue is empty
                empty_reg_next <= '1';
            end if;
        end if;
    end if;

end process;

empty <= empty_reg;
full <= full_reg;
w_addr <= w_ptr_reg;
r_addr <= r_ptr_reg;

end architecture;