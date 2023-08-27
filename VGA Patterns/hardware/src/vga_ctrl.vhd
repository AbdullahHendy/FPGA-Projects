library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity top is
    Port ( CLK_I : in  STD_LOGIC;
           SW    : in  STD_LOGIC_VECTOR(3 downto 0);
           BTN   : in  STD_LOGIC_VECTOR(3 downto 0);
           VGA_HS_O : out  STD_LOGIC;
           VGA_VS_O : out  STD_LOGIC;
           VGA_R : out  STD_LOGIC_VECTOR (3 downto 0);
           VGA_B : out  STD_LOGIC_VECTOR (3 downto 0);
           VGA_G : out  STD_LOGIC_VECTOR (3 downto 0));
           
end top;


architecture Behavioral of top is

component clk_wiz_0
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic
 );
end component;

component rand_gen is
    port
    (
        clk : in std_logic;
        seed     : in std_logic_vector (7 downto 0);
        output   : out std_logic_vector (3 downto 0)
    );
end component rand_gen;
-------------------------------------------------------------------------------------
--***1920x1080@60Hz***-- Requires 148.5 MHz pxl_clk
constant FRAME_WIDTH : natural := 1920;
constant FRAME_HEIGHT : natural := 1080;

constant H_FP : natural := 88; --H front porch width (pixels)
constant H_PW : natural := 44; --H sync pulse width (pixels)
constant H_MAX : natural := 2200; --H total period (pixels)

constant V_FP : natural := 4; --V front porch width (lines)
constant V_PW : natural := 5; --V sync pulse width (lines)
constant V_MAX : natural := 1125; --V total period (lines)

constant H_POL : std_logic := '1'; --Holds the value of the horizontal sync pulse
constant V_POL : std_logic := '1'; --Holds the value of the vertical sync pulse

signal pxl_clk : std_logic;
signal active : std_logic;

signal h_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');
signal v_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');

signal h_sync_reg : std_logic := not(H_POL);
signal v_sync_reg : std_logic := not(V_POL);

signal h_sync_dly_reg : std_logic := not(H_POL);
signal v_sync_dly_reg : std_logic :=  not(V_POL);

signal vga_red_reg : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_green_reg : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_blue_reg : std_logic_vector(3 downto 0) := (others =>'0');

signal vga_red : std_logic_vector(3 downto 0);
signal vga_green : std_logic_vector(3 downto 0);
signal vga_blue : std_logic_vector(3 downto 0);
-------------------------------------------------------------------------------------
constant third_of_frame_h  : natural := 640;
constant third_of_frame_v  : natural := 360; -- unused
constant eighth_of_frame_h : natural := 240;
constant eighth_of_frame_v : natural := 135; -- unused
-------------------------------------------------------------------------------------
constant BOX_WIDTH : natural := 10;
constant BOX_CLK_DIV : natural := 500000; --MAX=(2^25 - 1)

constant BOX_X_MAX : natural := (FRAME_WIDTH - BOX_WIDTH);
constant BOX_Y_MAX : natural := (FRAME_HEIGHT - BOX_WIDTH);

constant BOX_X_MIN : natural := 0;
constant BOX_Y_MIN : natural := 0;

constant BOX_X_INIT : std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(FRAME_WIDTH/2, 12));
constant BOX_Y_INIT : std_logic_vector(11 downto 0) := std_logic_vector(to_unsigned(FRAME_HEIGHT/2, 12));

signal box_cntr_reg : std_logic_vector(24 downto 0) := (others =>'0');
signal update_box : std_logic;
signal pixel_in_box : std_logic;
signal box_x_reg : std_logic_vector(11 downto 0) := BOX_X_INIT;
signal box_x_dir : std_logic := '1'; -- 1 -> move forward, 0 -> move back
signal box_y_reg : std_logic_vector(11 downto 0) := BOX_Y_INIT;
signal box_y_dir : std_logic := '1'; -- 1 -> move forward, 0 -> move back
-------------------------------------------------------------------------------------
constant BALL_SIZE : natural := BOX_WIDTH;

type rom_type is array (0 to BALL_SIZE-2) of std_logic_vector (BALL_SIZE-1 downto 0);

constant BALL_ROM : rom_type := 
(
"0011111100",
"0111111110",
"1111111111",
"1111111111",
"1111111111",
"1111111111",
"1111111111",
"0111111110",
"0011111100"
);

signal pixel_in_ball     : std_logic;
signal rom_row_select    : integer range 0 to BALL_SIZE-2 := 0; 
signal rom_column_select : integer range BALL_SIZE-1 downto 0 := BALL_SIZE-1;
signal rom_row_vector    : std_logic_vector (BALL_SIZE-1 downto 0);
signal rom_column_bit    : std_logic;

-------------------------------------------------------------------------------------


begin

clk_div_inst : clk_wiz_0 port map (CLK_IN1 => CLK_I, CLK_OUT1 => pxl_clk);

------------------------------------------------------------------------------------------
--SYNC
------------------------------------------------------------------------------------------
  process (pxl_clk) -- horizontal counter
  begin
    if (rising_edge(pxl_clk)) then
      if (h_cntr_reg = (H_MAX - 1)) then
        h_cntr_reg <= (others =>'0');
      else
        h_cntr_reg <= h_cntr_reg + 1;
      end if;
    end if;
  end process;
  
  process (pxl_clk) -- vertical counter
  begin
    if (rising_edge(pxl_clk)) then
      if ((h_cntr_reg = (H_MAX - 1)) and (v_cntr_reg = (V_MAX - 1))) then
        v_cntr_reg <= (others =>'0');
      elsif (h_cntr_reg = (H_MAX - 1)) then
        v_cntr_reg <= v_cntr_reg + 1;
      end if;
    end if;
  end process;
  
  process (pxl_clk) -- horizontal sync pulse
  begin
    if (rising_edge(pxl_clk)) then
      if (h_cntr_reg >= (H_FP + FRAME_WIDTH - 1)) and (h_cntr_reg < (H_FP + FRAME_WIDTH + H_PW - 1)) then
        h_sync_reg <= H_POL;
      else
        h_sync_reg <= not(H_POL);
      end if;
    end if;
  end process;
  
  
  process (pxl_clk) -- vertical sync pulse
  begin
    if (rising_edge(pxl_clk)) then
      if (v_cntr_reg >= (V_FP + FRAME_HEIGHT - 1)) and (v_cntr_reg < (V_FP + FRAME_HEIGHT + V_PW - 1)) then
        v_sync_reg <= V_POL;
      else
        v_sync_reg <= not(V_POL);
      end if;
    end if;
  end process;
  
  
  active <= '1' when ((h_cntr_reg < FRAME_WIDTH) and (v_cntr_reg < FRAME_HEIGHT))else
            '0';  

  process (pxl_clk) -- synchronize with clock
  begin
    if (rising_edge(pxl_clk)) then
      v_sync_dly_reg <= v_sync_reg;
      h_sync_dly_reg <= h_sync_reg;
      vga_red_reg <= vga_red;
      vga_green_reg <= vga_green;
      vga_blue_reg <= vga_blue;
    end if;
  end process;

------------------------------------------------------------------------------------------
--BOX 
------------------------------------------------------------------------------------------

  process (pxl_clk) -- box counter
  begin
    if (rising_edge(pxl_clk)) then
      if SW = "1011" then
          if (box_cntr_reg = (BOX_CLK_DIV - 1)) then
            box_cntr_reg <= (others=>'0');
          else
            box_cntr_reg <= box_cntr_reg + 1;     
          end if;
      end if;
    end if;
  end process;
  
  process (pxl_clk, SW) -- move the box
  begin
    if rising_edge(pxl_clk) then
        if SW = "1011" then
            if update_box = '1' then
                if box_x_dir = '1' then
                    box_x_reg <= box_x_reg + 1; -- move forward
                else
                    box_x_reg <= box_x_reg - 1; -- back off
                end if;
                if box_y_dir = '1' then
                    box_y_reg <= box_y_reg + 1; -- move forward
                else
                    box_y_reg <= box_y_reg - 1; -- back off
                end if;
            end if;
        end if; 
    end if;  
  end process;
  
  process (pxl_clk, SW) -- change direction when hitting the edges
  begin
    if rising_edge(pxl_clk) then
        if SW = "1011" then
            if update_box = '1' then
                if (box_x_dir = '1' and (box_x_reg = BOX_X_MAX - 1)) or (box_x_dir = '0' and (box_x_reg = BOX_X_MIN + 1)) then
                  box_x_dir <= not(box_x_dir);
                end if;
                if (box_y_dir = '1' and (box_y_reg = BOX_Y_MAX - 1)) or (box_y_dir = '0' and (box_y_reg = BOX_Y_MIN + 1)) then
                  box_y_dir <= not(box_y_dir);
                end if;
            end if;
        end if; 
    end if;  
  end process;
  
  
  update_box <= '1' when box_cntr_reg = BOX_CLK_DIV - 1 else '0';
  pixel_in_box <= '1' when (h_cntr_reg >= box_x_reg) and (h_cntr_reg < (box_x_reg + BOX_WIDTH)) and
                           (v_cntr_reg >= box_y_reg) and (v_cntr_reg < (box_y_reg + BOX_WIDTH)) else
                           '0'; 

------------------------------------------------------------------------------------------
--BALL
------------------------------------------------------------------------------------------
    -- ball just re-adjusts the pixel_in_box to look like a ball
     
    --choose the row/column data of BALL_ROM based on where the horizontal and vertical counters are
    rom_row_select <= to_integer(unsigned(v_cntr_reg(6 downto 0))) - to_integer(unsigned(box_y_reg(6 downto 0)));
    rom_column_select <= to_integer(unsigned(h_cntr_reg(6 downto 0))) - to_integer(unsigned(box_x_reg(6 downto 0)));
    rom_row_vector <= BALL_ROM(rom_row_select);
    rom_column_bit <= rom_row_vector(rom_column_select);
    
    pixel_in_ball <= '1' when pixel_in_box = '1' and rom_column_bit = '1' else
                     '0';   
------------------------------------------------------------------------------------------
--PATTERN GENERATION
------------------------------------------------------------------------------------------

    process(active, h_cntr_reg, v_cntr_reg, SW, BTN)
    begin
        if active = '1' then   
            case SW is
                when "0000" => -- off
                    vga_red <= (others=>'0'); vga_green <= (others=>'0'); vga_blue <= (others=>'0');               
                when "0001" => -- red
                    vga_red <= (others=>'1'); vga_green <= (others=>'0'); vga_blue <= (others=>'0');               
                when "0010" => -- green
                    vga_red <= (others=>'0'); vga_green <= (others=>'1'); vga_blue <= (others=>'0');               
                when "0011" => -- blue
                    vga_red <= (others=>'0'); vga_green <= (others=>'0'); vga_blue <= (others=>'1');               
                when "0100" => -- 3 vertical stripes
                    if h_cntr_reg < third_of_frame_h then
                        vga_red <= (others=>'1'); vga_green <= (others=>'0'); vga_blue <= (others=>'0');               
                    elsif h_cntr_reg < 2*third_of_frame_h then
                        vga_red <= (others=>'0'); vga_green <= (others=>'1'); vga_blue <= (others=>'0');               
                    else
                        vga_red <= (others=>'0'); vga_green <= (others=>'0'); vga_blue <= (others=>'1');               
                    end if;                     
                when "0101" => 
                    if h_cntr_reg < eighth_of_frame_h then
                        vga_red <= (others=>'1'); vga_green <= (others=>'1'); vga_blue <= (others=>'1');               
                    elsif h_cntr_reg < 2*eighth_of_frame_h then
                        vga_red <= (others=>'1'); vga_green <= (others=>'1'); vga_blue <= (others=>'0');               
                    elsif h_cntr_reg < 3*eighth_of_frame_h then
                        vga_red <= (others=>'0'); vga_green <= (others=>'1'); vga_blue <= (others=>'1');               
                    elsif h_cntr_reg < 4*eighth_of_frame_h then
                        vga_red <= (others=>'0'); vga_green <= (others=>'1'); vga_blue <= (others=>'0');                     
                    elsif h_cntr_reg < 5*eighth_of_frame_h then
                        vga_red <= (others=>'1'); vga_green <= (others=>'0'); vga_blue <= (others=>'1');                     
                    elsif h_cntr_reg < 6*eighth_of_frame_h then
                        vga_red <= (others=>'1'); vga_green <= (others=>'0'); vga_blue <= (others=>'0');                     
                    elsif h_cntr_reg < 7*eighth_of_frame_h then
                        vga_red <= (others=>'0'); vga_green <= (others=>'0'); vga_blue <= (others=>'1');  
                    else
                        vga_red <= (others=>'0'); vga_green <= (others=>'0'); vga_blue <= (others=>'0'); 
                    end if;
                when "0110" => 
                    if h_cntr_reg < eighth_of_frame_h then
                        vga_red <= "1110"; vga_green <= "1110"; vga_blue <= "1110";               
                    elsif h_cntr_reg < 2*eighth_of_frame_h then
                        vga_red <= "1100"; vga_green <= "1100"; vga_blue <= "1100";               
                    elsif h_cntr_reg < 3*eighth_of_frame_h then
                        vga_red <= "1010"; vga_green <= "1010"; vga_blue <= "1010";               
                    elsif h_cntr_reg < 4*eighth_of_frame_h then
                        vga_red <= "1000"; vga_green <= "1000"; vga_blue <= "1000";                     
                    elsif h_cntr_reg < 5*eighth_of_frame_h then
                        vga_red <= "0110"; vga_green <= "0110"; vga_blue <= "0110";                     
                    elsif h_cntr_reg < 6*eighth_of_frame_h then
                        vga_red <= "0100"; vga_green <= "0100"; vga_blue <= "0100";                     
                    elsif h_cntr_reg < 7*eighth_of_frame_h then
                        vga_red <= "0010"; vga_green <= "0010"; vga_blue <= "0010";  
                    else
                        vga_red <= (others=>'0'); vga_green <= (others=>'0'); vga_blue <= (others=>'0'); 
                    end if;                    
                when "0111" => 
                    case BTN is
                       when "0000" => vga_red <= h_cntr_reg(11 downto 8);
                                      vga_green <= h_cntr_reg(11 downto 8);
                                      vga_blue <= h_cntr_reg(11 downto 8);
                       when "0001" => vga_red <= h_cntr_reg(9 downto 6);
                                      vga_green <= h_cntr_reg(9 downto 6);
                                      vga_blue <= h_cntr_reg(9 downto 6);
                       when "0010" => vga_red <= h_cntr_reg(7 downto 4);
                                      vga_green <= h_cntr_reg(7 downto 4);
                                      vga_blue <= h_cntr_reg(7 downto 4);
                       when "0100" => vga_red <= h_cntr_reg(5 downto 2);
                                      vga_green <= h_cntr_reg(5 downto 2);
                                      vga_blue <= h_cntr_reg(5 downto 2);
                       when "1000" => vga_red <= h_cntr_reg(3 downto 0);
                                      vga_green <= h_cntr_reg(3 downto 0);
                                      vga_blue <= h_cntr_reg(3 downto 0);
                       when others =>
                                       vga_red <= (others=>'0');
                                       vga_green <= (others=>'0');
                                       vga_blue <= (others=>'0');
                    end case;
                when "1000" => 
                    case BTN is
                       when "0000" => vga_red <= v_cntr_reg(11 downto 8);
                                      vga_green <= v_cntr_reg(11 downto 8);
                                      vga_blue <= v_cntr_reg(11 downto 8);
                       when "0001" => vga_red <= v_cntr_reg(9 downto 6);
                                      vga_green <= v_cntr_reg(9 downto 6);
                                      vga_blue <= v_cntr_reg(9 downto 6);
                       when "0010" => vga_red <= v_cntr_reg(7 downto 4);
                                      vga_green <= v_cntr_reg(7 downto 4);
                                      vga_blue <= v_cntr_reg(7 downto 4);
                       when "0100" => vga_red <= v_cntr_reg(5 downto 2);
                                      vga_green <= v_cntr_reg(5 downto 2);
                                      vga_blue <= v_cntr_reg(5 downto 2);
                       when "1000" => vga_red <= v_cntr_reg(3 downto 0);
                                      vga_green <= v_cntr_reg(3 downto 0);
                                      vga_blue <= v_cntr_reg(3 downto 0);
                       when others =>
                                       vga_red <= (others=>'0');
                                       vga_green <= (others=>'0');
                                       vga_blue <= (others=>'0');
                    end case;
                when "1001" =>
                    case BTN is
                        when "0000" =>
                                       vga_red <= (others=>(v_cntr_reg(3) xor h_cntr_reg(3)));
                                       vga_green <= (others=>(v_cntr_reg(3) xor h_cntr_reg(3)));
                                       vga_blue <= (others=>(v_cntr_reg(3) xor h_cntr_reg(3)));
                        when "0001" =>
                                       vga_red <= (others=>(v_cntr_reg(4) xor h_cntr_reg(4)));
                                       vga_green <= (others=>(v_cntr_reg(4) xor h_cntr_reg(4)));
                                       vga_blue <= (others=>(v_cntr_reg(4) xor h_cntr_reg(4)));
                        when "0010" =>
                                       vga_red <= (others=>(v_cntr_reg(5) xor h_cntr_reg(5)));
                                       vga_green <= (others=>(v_cntr_reg(5) xor h_cntr_reg(5)));
                                       vga_blue <= (others=>(v_cntr_reg(5) xor h_cntr_reg(5)));
                        when "0100" =>
                                       vga_red <= (others=>(v_cntr_reg(7) xor h_cntr_reg(7)));
                                       vga_green <= (others=>(v_cntr_reg(7) xor h_cntr_reg(7)));
                                       vga_blue <= (others=>(v_cntr_reg(7) xor h_cntr_reg(7)));
                        when "1000" =>
                                       vga_red <= (others=>(v_cntr_reg(8) xor h_cntr_reg(8)));
                                       vga_green <= (others=>(v_cntr_reg(8) xor h_cntr_reg(8)));
                                       vga_blue <= (others=>(v_cntr_reg(8) xor h_cntr_reg(8)));
                        when others =>
                                   vga_red <= (others=>'0');
                                   vga_green <= (others=>'0');
                                   vga_blue <= (others=>'0');
                    end case;
                when "1010" =>
                    case BTN is
                        when "0000" =>
                                       vga_red <= v_cntr_reg(5 downto 2) and h_cntr_reg(5 downto 2);
                                       vga_green <= v_cntr_reg(5 downto 2) and h_cntr_reg(5 downto 2);
                                       vga_blue <= v_cntr_reg(5 downto 2) and h_cntr_reg(5 downto 2);
                        when "0001" =>
                                       vga_red <= v_cntr_reg(6 downto 3) or h_cntr_reg(6 downto 3);
                                       vga_green <= v_cntr_reg(6 downto 3) or h_cntr_reg(6 downto 3);
                                       vga_blue <= v_cntr_reg(6 downto 3) or h_cntr_reg(6 downto 3);
                        when "0010" =>
                                       vga_red <= v_cntr_reg(7 downto 4) xor h_cntr_reg(7 downto 4);
                                       vga_green <= v_cntr_reg(7 downto 4) xor h_cntr_reg(7 downto 4);
                                       vga_blue <= v_cntr_reg(7 downto 4) xor h_cntr_reg(7 downto 4);
                        when "0100" =>
                                       vga_red <= v_cntr_reg(4 downto 1) xnor h_cntr_reg(4 downto 1);
                                       vga_green <= v_cntr_reg(4 downto 1) xnor h_cntr_reg(4 downto 1);
                                       vga_blue <= v_cntr_reg(4 downto 1) xnor h_cntr_reg(4 downto 1);
                        when "1000" =>
                                       vga_red <= v_cntr_reg(5 downto 2) nand h_cntr_reg(5 downto 2);
                                       vga_green <= v_cntr_reg(5 downto 2) nand h_cntr_reg(5 downto 2);
                                       vga_blue <= v_cntr_reg(5 downto 2) nand h_cntr_reg(5 downto 2);
                        when others =>
                                   vga_red <= (others=>'0');
                                   vga_green <= (others=>'0');
                                   vga_blue <= (others=>'0');
                    end case;                    
                when "1011" => -- box
                    vga_red <= (others=>'0') when pixel_in_ball = '1' else (others=>'1');
                    vga_green <= (others=>'0') when pixel_in_ball = '1' else (others=>'1');
                    vga_blue <= (others=>'0') when pixel_in_ball = '1' else (others=>'1');             
                                                         
                when others =>
                    vga_red <= (others=>'0'); vga_green <= (others=>'0'); vga_blue <= (others=>'0');               
           end case;
       else
           vga_red <= (others=>'0');
           vga_green <= (others=>'0');
           vga_blue <= (others=>'0');
       end if;
    end process;


  VGA_HS_O <= h_sync_dly_reg;
  VGA_VS_O <= v_sync_dly_reg;
  VGA_R <= vga_red_reg;
  VGA_G <= vga_green_reg;
  VGA_B <= vga_blue_reg;


end Behavioral;
