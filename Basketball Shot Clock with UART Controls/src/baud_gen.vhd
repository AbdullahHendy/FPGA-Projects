library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_baud_gen is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           dvsr : in STD_LOGIC_VECTOR (10 downto 0); --allow for baudrate of 9600 dvsr = (topclk/(baudrate * sampling rate))-1, topclk = 125MHz
           tick : out STD_LOGIC);
end uart_baud_gen;

architecture Behavioral of uart_baud_gen is

    signal cntr_reg : unsigned(10 downto 0);
    signal cntr_next: unsigned(10 downto 0);

begin

    process (clk, rst)
    begin
        if rst = '1' then
            cntr_reg <= (others => '0');    
        elsif rising_edge(clk) then
            cntr_reg <= cntr_next;
        end if;
    end process;

    cntr_next <= (others => '0') when cntr_reg = unsigned(dvsr) else cntr_reg + 1;
    tick <= '1' when cntr_reg = 1 else '0'; -- not use 0 because of reset

end Behavioral;
