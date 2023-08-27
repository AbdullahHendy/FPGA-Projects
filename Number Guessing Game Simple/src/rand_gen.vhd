library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rand_gen is
    port
    (
        clk, rst : in std_logic;
        seed     : in std_logic_vector (7 downto 0);
        output   : out std_logic_vector (3 downto 0)
    );
end rand_gen;

architecture Behavioral of rand_gen is

signal LFSR_regs : std_logic_vector(7 downto 0) := (others => '0');
signal feedback  : std_logic;

begin
    process (clk, rst, seed)
        begin
            if rst = '1' then
                LFSR_regs <= seed;    
            elsif rising_edge(clk) then
                LFSR_regs <= LFSR_regs(6 downto 0) & feedback;
            end if;     
    end process;    
    
    feedback <= LFSR_regs(7) xor LFSR_regs(5) xor LFSR_regs(4) xor LFSR_regs(3); 
    output <= "0001" when (LFSR_regs(6) & LFSR_regs(2) & LFSR_regs(1) & LFSR_regs(0)) = 0 else
              LFSR_regs(6) & LFSR_regs(2) & LFSR_regs(1) & LFSR_regs(0);              
    
end Behavioral;