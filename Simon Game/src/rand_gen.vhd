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
signal temp_out  : std_logic_vector(3 downto 0);

begin
    process (clk, rst, seed)
        begin
            if rst = '1' then
                LFSR_regs <= seed;    
            elsif rising_edge(clk) then
                LFSR_regs <= LFSR_regs(6 downto 0) & feedback;
            end if;     
    end process;    
    
    
    process (temp_out)
        begin
            case temp_out is
                when "0000"|"0001"|"0010"|"0011" => output <= "0001" ;
                when "0100"|"0101"|"0110"|"0111" => output <= "0010" ;
                when "1000"|"1001"|"1010"|"1011" => output <= "0100" ;
                when "1100"|"1101"|"1110"|"1111" => output <= "1000" ;
                when others => output <= "1000" ;
            end case ;
    end process;    
    
    
    feedback <= LFSR_regs(7) xor LFSR_regs(5) xor LFSR_regs(4) xor LFSR_regs(3);
    temp_out <= LFSR_regs(6) & LFSR_regs(2) & LFSR_regs(1) & LFSR_regs(0);              
    
end Behavioral;