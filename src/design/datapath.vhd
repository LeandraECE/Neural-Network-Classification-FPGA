
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;




entity datapath is
    port (
        clk, reset, en_counter1,en_counter2 : in std_logic;
        no_image : in std_logic_vector (6 downto 0);
        done1: out std_logic;
        done2: out std_logic;
        cmp_final: out std_logic_vector (26 downto 0);
        result_final : out std_logic_vector (3 downto 0)
       );
end datapath;


architecture Behavioral of datapath is

    --Memories---
    signal no_image_uns : unsigned(6 downto 0):= (others => '0');
    signal add_reg_sg, res_add_sg : signed (13 downto 0):= (others => '0');
    signal addr_im_sg,addr_im_sg_b  : unsigned (11 downto 0):= (others => '0');  
    signal im_row,im_row_b : std_logic_vector (31 downto 0):= (others => '0');
    signal w1_out : std_logic_vector(127 downto 0):= (others => '0');
    signal w1_out_b : std_logic_vector(127 downto 0):= (others => '0');
    signal addr_im,addr_im_b : std_logic_vector (11 downto 0) := (others => '0');
    signal addr_w1 : std_logic_vector (9 downto 0) := (others => '0');
    signal addr_w1_b : std_logic_vector (9 downto 0) := (others => '0');
    signal addr_w2,addr_w2_b : std_logic_vector (6 downto 0) := (others => '0');
    signal w2_out,w2_out_b : std_logic_vector(31 downto 0):= (others => '0'); 

    signal W1_count,Imag_count: unsigned (9 downto 0):=(others => '0');
    signal W2_count: unsigned (6 downto 0):=(others => '0');
    
    
    COMPONENT images_mem
      PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        clkb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
      );
    END COMPONENT;
    COMPONENT weights1
      PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
        clkb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(127 DOWNTO 0) 
      );
    END COMPONENT;
    
    COMPONENT weights2
      PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        clkb : IN STD_LOGIC;
        web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addrb : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
        dinb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
      );
    END COMPONENT;
    
    
    ----Layer1----
    signal res_mul1_sg, res_mul2_sg, res_mul3_sg, res_mul4_sg,res_mul5_sg, res_mul6_sg, res_mul7_sg, res_mul8_sg,res_mul9_sg,res_mul10_sg,res_mul11_sg,res_mul12_sg,res_mul13_sg,res_mul14_sg,res_mul15_sg,res_mul16_sg,res_mul17_sg,res_mul18_sg,res_mul19_sg,res_mul20_sg,res_mul21_sg,res_mul22_sg,res_mul23_sg,res_mul24_sg,res_mul25_sg,res_mul26_sg,res_mul27_sg,res_mul28_sg,res_mul29_sg,res_mul30_sg ,res_mul31_sg, res_mul32_sg, res_mul33_sg, res_mul34_sg,res_mul35_sg, res_mul36_sg, res_mul37_sg, res_mul38_sg,res_mul39_sg,res_mul40_sg,res_mul41_sg,res_mul42_sg,res_mul43_sg,res_mul44_sg,res_mul45_sg,res_mul46_sg,res_mul47_sg,res_mul48_sg,res_mul49_sg,res_mul50_sg,res_mul51_sg,res_mul52_sg,res_mul53_sg,res_mul54_sg,res_mul55_sg,res_mul56_sg,res_mul57_sg,res_mul58_sg,res_mul59_sg,res_mul60_sg,res_mul61_sg,res_mul62_sg,res_mul63_sg,res_mul64_sg : signed (3 downto 0):= (others => '0');  
    signal process1_done:std_logic:='0'; 
    signal select_enables: unsigned (4 downto 0):=(others => '0');    
    signal add_reg,res_add,R0,R1,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11,R12,R13,R14,R15,R16,R17,R18,R19,R20,R21,R22,R23,R24,R25,R26,R27,R28,R29,R30,R31: std_logic_vector (13 downto 0):=(others => '0');
    signal R0_middle,R1_middle,R2_middle,R3_middle,R4_middle,R5_middle,R6_middle,R7_middle,R8_middle,R9_middle,R10_middle,R11_middle,R12_middle,R13_middle,R14_middle,R15_middle,R16_middle,R17_middle,R18_middle,R19_middle,R20_middle,R21_middle,R22_middle,R23_middle,R24_middle,R25_middle,R26_middle,R27_middle,R28_middle,R29_middle,R30_middle,R31_middle: std_logic_vector (13 downto 0):=(others => '0');
    signal counter1: unsigned (8 downto 0):=(others => '0');
    signal counter1_delayed: unsigned (8 downto 0):=(others => '0');
    signal enables1: std_logic_vector(31 downto 0):=(others => '0'); 
    signal start1: std_logic:='0';
    
    
    
    ----Layer 2----
    
    signal add_reg2,res2_add,R0_final,R1_final,R2_final,R3_final,R4_final,R5_final,R6_final,R7_final,R8_final,R9_final: std_logic_vector (26 downto 0):=(others => '0');
    signal enables2: std_logic_vector(9 downto 0):=(others => '0');
    signal V1,V2,V3,V4,V5,V6,V7,V8:std_logic_vector (13 downto 0):= (others => '0');
    signal select_mux2 : std_logic_vector (1 downto 0):=(others => '0');
    signal counter2: unsigned (5 downto 0):=(others => '0');
    signal process2_done:std_logic:='0';
    signal counter2_delayed: unsigned (5 downto 0):=(others => '0');
    signal V1_sg, V2_sg, V3_sg, V4_sg,V5_sg,V6_sg,V7_sg,V8_sg : signed(13 downto 0):= (others => '0');
    signal P1w2_sg,P2w2_sg,P3w2_sg,P4w2_sg,P5w2_sg,P6w2_sg,P7w2_sg,P8w2_sg:signed(7 downto 0):= (others => '0');
    signal res2_mul1_sg,res2_mul2_sg,res2_mul3_sg,res2_mul4_sg,res2_mul5_sg,res2_mul6_sg,res2_mul7_sg,res2_mul8_sg:signed(21 downto 0):= (others => '0');
    signal res2_mul1,res2_mul2,res2_mul3,res2_mul4,res2_mul5,res2_mul6,res2_mul7,res2_mul8:std_logic_vector (21 downto 0):= (others => '0');
    signal sum1,sum2,sum3,sum4:signed (22 downto 0);
    signal sum5,sum6:signed (23 downto 0);
    signal sum7:signed (24 downto 0);
    signal select_enables2:unsigned (3 downto 0):=(others => '0');
    signal cmp1,cmp2,cmp3,cmp4,cmp5,cmp6,cmp7,add_reg2_sg, res2_add_sg : signed (26 downto 0):= (others => '0');
    signal start2: std_logic:='0';
    signal result1,result2,result3,result4,result5,result6,result7: unsigned (3 downto 0):= (others => '0');
    
    
begin

------------IMAGES AND WEIGHTS--------------------

instance_images : images_mem
  PORT MAP (
    clka => clk,
    wea => "0",
    addra => addr_im,
    dina => (others => '0'),
    douta => im_row,
    clkb => clk,
    web => "0",
    addrb => addr_im_b,
    dinb => (others => '0'),
    doutb => im_row_b
  );

instance_weights1 : weights1
  PORT MAP (
    clka => clk,
    wea => "0",
    addra => addr_w1,
    dina => (others => '0'),
    douta => w1_out,
    clkb => clk,
    web => "0",
    addrb => addr_w1_b,
    dinb => (others => '0'),
    doutb => w1_out_b
  );
  
  
  instance_weights2 : weights2
  PORT MAP (
    clka => clk,
    wea => "0",
    addra => addr_w2,
    dina => (others => '0'),
    douta => w2_out,
    clkb => clk,
    web => "0",
    addrb => addr_w2_b,
    dinb => (others => '0'),
    doutb => w2_out_b
  );   
  
  
----------LAYER 1---------------------    
    
    --multiplying the image bit with the weights
    res_mul1_sg <= "0000" when im_row(0)='0' else  signed(w1_out(3 downto 0));
    res_mul2_sg <= "0000" when im_row(1)='0' else  signed(w1_out(7 downto 4));
    res_mul3_sg <= "0000" when im_row(2)='0' else  signed(w1_out(11 downto 8));
    res_mul4_sg <= "0000" when im_row(3)='0' else  signed(w1_out(15 downto 12));
    res_mul5_sg <= "0000" when im_row(4)='0' else  signed(w1_out(19 downto 16));
    res_mul6_sg <= "0000" when im_row(5)='0' else  signed(w1_out(23 downto 20));
    res_mul7_sg <= "0000" when im_row(6)='0' else  signed(w1_out(27 downto 24));
    res_mul8_sg <= "0000" when im_row(7)='0' else  signed(w1_out(31 downto 28));
    res_mul9_sg <= "0000" when im_row(8)='0' else  signed(w1_out(35 downto 32));
    res_mul10_sg <= "0000" when im_row(9)='0' else  signed(w1_out(39 downto 36));
    res_mul11_sg <= "0000" when im_row(10)='0' else  signed(w1_out(43 downto 40));
    res_mul12_sg <= "0000" when im_row(11)='0' else  signed(w1_out(47 downto 44));
    res_mul13_sg <= "0000" when im_row(12)='0' else  signed(w1_out(51 downto 48));
    res_mul14_sg <= "0000" when im_row(13)='0' else  signed(w1_out(55 downto 52));
    res_mul15_sg <= "0000" when im_row(14)='0' else  signed(w1_out(59 downto 56));
    res_mul16_sg <= "0000" when im_row(15)='0' else  signed(w1_out(63 downto 60));
    res_mul17_sg <= "0000" when im_row(16)='0' else  signed(w1_out(67 downto 64));
    res_mul18_sg <= "0000" when im_row(17)='0' else  signed(w1_out(71 downto 68));
    res_mul19_sg <= "0000" when im_row(18)='0' else  signed(w1_out(75 downto 72));
    res_mul20_sg <= "0000" when im_row(19)='0' else  signed(w1_out(79 downto 76));
    res_mul21_sg <= "0000" when im_row(20)='0' else  signed(w1_out(83 downto 80));
    res_mul22_sg <= "0000" when im_row(21)='0' else  signed(w1_out(87 downto 84));
    res_mul23_sg <= "0000" when im_row(22)='0' else  signed(w1_out(91 downto 88));
    res_mul24_sg <= "0000" when im_row(23)='0' else  signed(w1_out(95 downto 92));
    res_mul25_sg <= "0000" when im_row(24)='0' else  signed(w1_out(99 downto 96));
    res_mul26_sg <= "0000" when im_row(25)='0' else  signed(w1_out(103 downto 100));
    res_mul27_sg <= "0000" when im_row(26)='0' else  signed(w1_out(107 downto 104));
    res_mul28_sg <= "0000" when im_row(27)='0' else  signed(w1_out(111 downto 108));
    res_mul29_sg <= "0000" when im_row(28)='0' else  signed(w1_out(115 downto 112));
    res_mul30_sg <= "0000" when im_row(29)='0' else  signed(w1_out(119 downto 116));
    res_mul31_sg <= "0000" when im_row(30)='0' else  signed(w1_out(123 downto 120));
    res_mul32_sg <= "0000" when im_row(31)='0' else  signed(w1_out(127 downto 124));
    res_mul33_sg <= "0000" when im_row_b(0)='0' else  signed(w1_out_b(3 downto 0));
    res_mul34_sg <= "0000" when im_row_b(1)='0' else  signed(w1_out_b(7 downto 4));
    res_mul35_sg <= "0000" when im_row_b(2)='0' else  signed(w1_out_b(11 downto 8));
    res_mul36_sg <= "0000" when im_row_b(3)='0' else  signed(w1_out_b(15 downto 12));
    res_mul37_sg <= "0000" when im_row_b(4)='0' else  signed(w1_out_b(19 downto 16));
    res_mul38_sg <= "0000" when im_row_b(5)='0' else  signed(w1_out_b(23 downto 20));
    res_mul39_sg <= "0000" when im_row_b(6)='0' else  signed(w1_out_b(27 downto 24));
    res_mul40_sg <= "0000" when im_row_b(7)='0' else  signed(w1_out_b(31 downto 28));
    res_mul41_sg <= "0000" when im_row_b(8)='0' else  signed(w1_out_b(35 downto 32));
    res_mul42_sg <= "0000" when im_row_b(9)='0' else  signed(w1_out_b(39 downto 36));
    res_mul43_sg <= "0000" when im_row_b(10)='0' else  signed(w1_out_b(43 downto 40));
    res_mul44_sg <= "0000" when im_row_b(11)='0' else  signed(w1_out_b(47 downto 44));
    res_mul45_sg <= "0000" when im_row_b(12)='0' else  signed(w1_out_b(51 downto 48));
    res_mul46_sg <= "0000" when im_row_b(13)='0' else  signed(w1_out_b(55 downto 52));
    res_mul47_sg <= "0000" when im_row_b(14)='0' else  signed(w1_out_b(59 downto 56));
    res_mul48_sg <= "0000" when im_row_b(15)='0' else  signed(w1_out_b(63 downto 60));
    res_mul49_sg <= "0000" when im_row_b(16)='0' else  signed(w1_out_b(67 downto 64));
    res_mul50_sg <= "0000" when im_row_b(17)='0' else  signed(w1_out_b(71 downto 68));
    res_mul51_sg <= "0000" when im_row_b(18)='0' else  signed(w1_out_b(75 downto 72));
    res_mul52_sg <= "0000" when im_row_b(19)='0' else  signed(w1_out_b(79 downto 76));
    res_mul53_sg <= "0000" when im_row_b(20)='0' else  signed(w1_out_b(83 downto 80));
    res_mul54_sg <= "0000" when im_row_b(21)='0' else  signed(w1_out_b(87 downto 84));
    res_mul55_sg <= "0000" when im_row_b(22)='0' else  signed(w1_out_b(91 downto 88));
    res_mul56_sg <= "0000" when im_row_b(23)='0' else  signed(w1_out_b(95 downto 92));
    res_mul57_sg <= "0000" when im_row_b(24)='0' else  signed(w1_out_b(99 downto 96));
    res_mul58_sg <= "0000" when im_row_b(25)='0' else  signed(w1_out_b(103 downto 100));
    res_mul59_sg <= "0000" when im_row_b(26)='0' else  signed(w1_out_b(107 downto 104));
    res_mul60_sg <= "0000" when im_row_b(27)='0' else  signed(w1_out_b(111 downto 108));
    res_mul61_sg <= "0000" when im_row_b(28)='0' else  signed(w1_out_b(115 downto 112));
    res_mul62_sg <= "0000" when im_row_b(29)='0' else  signed(w1_out_b(119 downto 116));
    res_mul63_sg <= "0000" when im_row_b(30)='0' else  signed(w1_out_b(123 downto 120));
    res_mul64_sg <= "0000" when im_row_b(31)='0' else  signed(w1_out_b(127 downto 124));
    
    
    --"selection" of the register to enable
    enables1 <= "00000000000000000000000000000001" when select_enables = "00000" else
                "00000000000000000000000000000010" when select_enables = "00001" else
                "00000000000000000000000000000100" when select_enables = "00010" else
                "00000000000000000000000000001000" when select_enables = "00011" else
                "00000000000000000000000000010000" when select_enables = "00100" else
                "00000000000000000000000000100000" when select_enables = "00101" else
                "00000000000000000000000001000000" when select_enables = "00110" else
                "00000000000000000000000010000000" when select_enables = "00111" else
                "00000000000000000000000100000000" when select_enables = "01000" else
                "00000000000000000000001000000000" when select_enables = "01001" else
                "00000000000000000000010000000000" when select_enables = "01010" else
                "00000000000000000000100000000000" when select_enables = "01011" else
                "00000000000000000001000000000000" when select_enables = "01100" else
                "00000000000000000010000000000000" when select_enables = "01101" else
                "00000000000000000100000000000000" when select_enables = "01110" else
                "00000000000000001000000000000000" when select_enables = "01111" else
                "00000000000000010000000000000000" when select_enables = "10000" else
                "00000000000000100000000000000000" when select_enables = "10001" else
                "00000000000001000000000000000000" when select_enables = "10010" else
                "00000000000010000000000000000000" when select_enables = "10011" else
                "00000000000100000000000000000000" when select_enables = "10100" else
                "00000000001000000000000000000000" when select_enables = "10101" else
                "00000000010000000000000000000000" when select_enables = "10110" else
                "00000000100000000000000000000000" when select_enables = "10111" else
                "00000001000000000000000000000000" when select_enables = "11000" else
                "00000010000000000000000000000000" when select_enables = "11001" else
                "00000100000000000000000000000000" when select_enables = "11010" else
                "00001000000000000000000000000000" when select_enables = "11011" else
                "00010000000000000000000000000000" when select_enables = "11100" else
                "00100000000000000000000000000000" when select_enables = "11101" else
                "01000000000000000000000000000000" when select_enables = "11110" else
                "10000000000000000000000000000000";
    
    
    
    --recover the result from the previous cycle 
    add_reg <= R0 when select_enables = "00000" else
              R1 when select_enables= "00001" else
              R2 when select_enables = "00010" else
              R3 when select_enables = "00011"else
              R4 when select_enables= "00100" else
              R5 when select_enables = "00101"else
              R6 when select_enables = "00110" else
              R7 when select_enables = "00111" else
              R8 when select_enables = "01000" else
              R9 when select_enables = "01001" else
              R10 when select_enables = "01010" else
              R11 when select_enables = "01011" else
              R12 when select_enables = "01100" else
              R13 when select_enables = "01101" else
              R14 when select_enables = "01110" else
              R15 when select_enables = "01111" else
              R16 when select_enables = "10000" else
              R17 when select_enables = "10001" else
              R18 when select_enables = "10010" else
              R19 when select_enables = "10011" else
              R20 when select_enables = "10100" else
              R21 when select_enables = "10101" else
              R22 when select_enables = "10110" else
              R23 when select_enables = "10111" else
              R24 when select_enables = "11000" else
              R25 when select_enables = "11001" else
              R26 when select_enables = "11010" else
              R27 when select_enables = "11011" else
              R28 when select_enables = "11100" else
              R29 when select_enables = "11101" else
              R30 when select_enables = "11110" else
              R31;
    
    --summing the results from this cycle with the previous one
    add_reg_sg <= signed (add_reg);
    res_add <= std_logic_vector (res_add_sg);
    res_add_sg <= add_reg_sg
                 + res_mul1_sg
                 + res_mul2_sg
                 + res_mul3_sg
                 + res_mul4_sg
                 + res_mul5_sg
                 + res_mul6_sg
                 + res_mul7_sg 
                 + res_mul8_sg
                 + res_mul9_sg
                 + res_mul10_sg
                 + res_mul11_sg
                 + res_mul12_sg
                 + res_mul13_sg
                 + res_mul14_sg
                 + res_mul15_sg
                 + res_mul16_sg
                 + res_mul17_sg
                 + res_mul18_sg 
                 + res_mul19_sg
                 + res_mul20_sg
                 + res_mul21_sg
                 + res_mul22_sg
                 + res_mul23_sg
                 + res_mul24_sg
                 + res_mul25_sg
                 + res_mul26_sg
                 + res_mul27_sg
                 + res_mul28_sg
                 + res_mul29_sg
                 + res_mul30_sg
                 + res_mul31_sg
                 + res_mul32_sg
                 + res_mul33_sg
                 + res_mul34_sg
                 + res_mul35_sg
                 + res_mul36_sg 
                 + res_mul37_sg
                 + res_mul38_sg
                 + res_mul39_sg
                 + res_mul40_sg
                 + res_mul41_sg
                 + res_mul42_sg
                 + res_mul43_sg
                 + res_mul44_sg
                 + res_mul45_sg
                 + res_mul46_sg
                 + res_mul47_sg
                 + res_mul48_sg 
                 + res_mul49_sg
                 + res_mul50_sg 
                 + res_mul51_sg
                 + res_mul52_sg
                 + res_mul53_sg
                 + res_mul54_sg
                 + res_mul55_sg
                 + res_mul56_sg
                 + res_mul57_sg
                 + res_mul58_sg
                 + res_mul59_sg
                 + res_mul60_sg
                 + res_mul61_sg
                 + res_mul62_sg
                 + res_mul63_sg
                 + res_mul64_sg;
     
                 
                 
   
   --Counters, addresses and control signals
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                counter1 <= (others => '0');
                W1_count<= (others => '0');
                Imag_count<= (others => '0');
                done1<='0';
                start1<='0';
                process1_done<='0';
            elsif en_counter1 = '1' then
                start1<='1';
                counter1 <= counter1+1;
                W1_count<=W1_count+2;
                Imag_count<= Imag_count+2;
                if counter1_delayed="111111111"  then
                    done1<='1';
                    process1_done<='1';
                end if;
            end if;
        end if;
    end process; 
    
    
   process (clk)
    begin
        if clk'event and clk='1' then
            if en_counter1 = '1' then
                select_enables<=counter1(8 downto 4);
                counter1_delayed<=counter1;
            end if;
        end if;
    end process; 
    
    --selecting the address to retrieve the next bits from the image
    no_image_uns <= unsigned (no_image);
    
    addr_im <= std_logic_vector (addr_im_sg);
    addr_im_sg <= no_image_uns & Imag_count(4 downto 0);
    
    addr_im_b <= std_logic_vector (addr_im_sg_b);
    addr_im_sg_b <= no_image_uns & (Imag_count(4 downto 0)+1);
    
    --selecting the address to retrieve the next weights from layer1
    addr_w1 <= std_logic_vector(W1_count);
    addr_w1_b <= std_logic_vector(W1_count+1);
    
    
    
              
    ----Storage of the results before the RELU function            
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R0 <= (others => '0');
            elsif enables1(0)='1' and process1_done = '0' and start1='1' then
                R0 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R1 <= (others => '0');
            elsif enables1(1) = '1' and process1_done = '0' and start1='1' then 
                R1 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R2 <= (others => '0');
            elsif enables1(2) = '1' and process1_done = '0' and start1='1' then
                R2 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R3 <= (others => '0');
            elsif enables1(3) = '1' and process1_done = '0' and start1='1' then
                R3 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R4 <= (others => '0');
            elsif enables1(4) = '1' and process1_done = '0' and start1='1' then
                R4 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R5 <= (others => '0');
            elsif enables1(5) = '1' and process1_done = '0' and start1='1' then
                R5 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R6 <= (others => '0');
            elsif enables1(6) = '1' and process1_done = '0' and start1='1' then
                R6 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R7 <= (others => '0');
            elsif enables1(7) = '1' and process1_done = '0' and start1='1' then
                R7 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R8 <= (others => '0');
            elsif enables1(8) = '1' and process1_done = '0' and start1='1' then
                R8 <= res_add;
            end if;
        end if;
    end process;   
    
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R9 <= (others => '0');
            elsif enables1(9) = '1' and process1_done = '0' and start1='1' then
                R9 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R10 <= (others => '0');
            elsif enables1(10) = '1' and process1_done = '0' and start1='1' then
                R10 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R11 <= (others => '0');
            elsif enables1(11) = '1' and process1_done = '0' and start1='1' then
                R11 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R12 <= (others => '0');
            elsif enables1(12) = '1' and process1_done = '0' and start1='1' then
                R12 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R13 <= (others => '0');
            elsif enables1(13) = '1' and process1_done = '0' and start1='1' then
                R13 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R14 <= (others => '0');
            elsif enables1(14) = '1' and process1_done = '0' and start1='1' then
                R14 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R15 <= (others => '0');
            elsif enables1(15) = '1' and process1_done = '0' and start1='1' then
                R15 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R16 <= (others => '0');
            elsif enables1(16) = '1' and process1_done = '0' and start1='1' then
                R16 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R17 <= (others => '0');
            elsif enables1(17) = '1' and process1_done = '0' and start1='1' then
                R17 <= res_add;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R18 <= (others => '0');
            elsif enables1(18)= '1' and process1_done = '0' and start1='1' then
                R18 <= res_add;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R19 <= (others => '0');
            elsif enables1(19) = '1' and process1_done = '0' and start1='1' then
                R19 <= res_add;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R20 <= (others => '0');
            elsif enables1(20) = '1' and process1_done = '0' and start1='1' then
                R20 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R21 <= (others => '0');
            elsif enables1(21) = '1' and process1_done = '0' and start1='1' then
                R21 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R22 <= (others => '0');
            elsif enables1(22) = '1' and process1_done = '0' and start1='1' then
                R22 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R23 <= (others => '0');
            elsif enables1(23) = '1' and process1_done = '0' and start1='1' then
                R23 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R24 <= (others => '0');
            elsif enables1(24) = '1' and process1_done = '0' and start1='1' then
                R24 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R25 <= (others => '0');
            elsif enables1(25) = '1' and process1_done = '0' and start1='1' then
                R25 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R26 <= (others => '0');
            elsif enables1(26) = '1' and process1_done = '0' and start1='1' then
                R26 <= res_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R27 <= (others => '0');
            elsif enables1(27) = '1' and process1_done = '0' and start1='1' then
                R27 <= res_add;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R28 <= (others => '0');
            elsif enables1(28) = '1' and process1_done = '0' and start1='1' then
                R28 <= res_add;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R29 <= (others => '0');
            elsif enables1(29) = '1' and process1_done = '0' and start1='1' then
                R29 <= res_add;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R30 <= (others => '0');
            elsif enables1(30) = '1' and process1_done = '0' and start1='1' then
                R30 <= res_add;
            end if;
        end if;
    end process; 
    
     process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R31 <= (others => '0');
            elsif enables1(31)= '1' and process1_done = '0' and start1='1' then
                R31 <= res_add;
            end if;
        end if;
    end process; 
    
    
    --------MIDDLE LAYER (after RELU) -------------
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R0_middle <= (others => '0');
            elsif process1_done = '1' then
                if R0(13) = '1' then
                    R0_middle <= "00000000000000";
                else
                    R0_middle <= R0;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R1_middle <= (others => '0');
            elsif process1_done = '1' then
                if R1(13) = '1' then
                    R1_middle <= "00000000000000";
                else
                    R1_middle <= R1;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R2_middle <= (others => '0');
            elsif process1_done = '1' then
                if R2(13) = '1' then
                    R2_middle <= "00000000000000";
                else
                    R2_middle <= R2;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R3_middle <= (others => '0');
            elsif process1_done = '1' then
                if R3(13) = '1' then
                    R3_middle <= "00000000000000";
                else
                    R3_middle <= R3;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R4_middle <= (others => '0');
            elsif process1_done = '1' then
                if R4(13) = '1' then
                    R4_middle <= "00000000000000";
                else
                    R4_middle <= R4;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R5_middle <= (others => '0');
            elsif process1_done = '1' then
                if R5(13) = '1' then
                    R5_middle <= "00000000000000";
                else
                    R5_middle <= R5;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R6_middle <= (others => '0');
            elsif process1_done = '1' then
                if R6(13) = '1' then
                    R6_middle <= "00000000000000";
                else
                    R6_middle <= R6;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R7_middle <= (others => '0');
            elsif process1_done = '1' then
                if R7(13) = '1' then
                    R7_middle <= "00000000000000";
                else
                    R7_middle <= R7;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R8_middle <= (others => '0');
            elsif process1_done = '1' then
                if R8(13) = '1' then
                    R8_middle <= "00000000000000";
                else
                    R8_middle <= R8;
                end if;
            end if;
        end if;
    end process;   
    
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R9_middle <= (others => '0');
            elsif process1_done = '1' then
                if R9(13) = '1' then
                    R9_middle <= "00000000000000";
                else
                    R9_middle <= R9;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R10_middle <= (others => '0');
            elsif process1_done = '1' then
                if R10(13) = '1' then
                    R10_middle <= "00000000000000";
                else
                    R10_middle <= R10;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R11_middle <= (others => '0');
            elsif process1_done = '1' then
                if R11(13) = '1' then
                    R11_middle <= "00000000000000";
                else
                    R11_middle <= R11;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R12_middle <= (others => '0');
            elsif process1_done = '1' then
                if R12(13) = '1' then
                    R12_middle <= "00000000000000";
                else
                    R12_middle <= R12;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R13_middle <= (others => '0');
            elsif process1_done = '1' then
                if R13(13) = '1' then
                    R13_middle <= "00000000000000";
                else
                    R13_middle <= R13;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R14_middle <= (others => '0');
            elsif process1_done = '1' then
                if R14(13) = '1' then
                    R14_middle <= "00000000000000";
                else
                    R14_middle <= R14;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R15_middle <= (others => '0');
            elsif process1_done = '1' then
                if R15(13) = '1' then
                    R15_middle <= "00000000000000";
                else
                    R15_middle <= R15;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R16_middle <= (others => '0');
            elsif process1_done = '1' then
                if R16(13) = '1' then
                    R16_middle <= "00000000000000";
                else
                    R16_middle <= R16;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R17_middle <= (others => '0');
            elsif process1_done = '1' then
                if R17(13) = '1' then
                    R17_middle <= "00000000000000";
                else
                    R17_middle <= R17;
                end if;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R18_middle <= (others => '0');
            elsif process1_done = '1' then
                if R18(13) = '1' then
                    R18_middle <= "00000000000000";
                else
                    R18_middle <= R18;
                end if;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R19_middle <= (others => '0');
            elsif process1_done = '1' then
                if R19(13) = '1' then
                    R19_middle <= "00000000000000";
                else
                    R19_middle <= R19;
                end if;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R20_middle <= (others => '0');
            elsif process1_done = '1' then
                if R20(13) = '1' then
                    R20_middle <= "00000000000000";
                else
                    R20_middle <= R20;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R21_middle <= (others => '0');
            elsif process1_done = '1' then
                if R21(13) = '1' then
                    R21_middle <= "00000000000000";
                else
                    R21_middle <= R21;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R22_middle <= (others => '0');
            elsif process1_done = '1' then
                if R22(13) = '1' then
                    R22_middle <= "00000000000000";
                else
                    R22_middle <= R22;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R23_middle <= (others => '0');
            elsif process1_done = '1' then
                if R23(13) = '1' then
                    R23_middle <= "00000000000000";
                else
                    R23_middle <= R23;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R24_middle <= (others => '0');
            elsif process1_done = '1' then
                if R24(13) = '1' then
                    R24_middle <= "00000000000000";
                else
                    R24_middle <= R24;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R25_middle <= (others => '0');
            elsif process1_done = '1' then
                if R25(13) = '1' then
                    R25_middle <= "00000000000000";
                else
                    R25_middle <= R25;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R26_middle <= (others => '0');
            elsif process1_done = '1' then
                if R26(13) = '1' then
                    R26_middle <= "00000000000000";
                else
                    R26_middle <= R26;
                end if;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R27_middle <= (others => '0');
            elsif process1_done = '1' then
                if R27(13) = '1' then
                    R27_middle <= "00000000000000";
                else
                    R27_middle <= R27;
                end if;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R28_middle <= (others => '0');
            elsif process1_done = '1' then
                if R28(13) = '1' then
                    R28_middle <= "00000000000000";
                else
                    R28_middle <= R28;
                end if;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R29_middle <= (others => '0');
            elsif process1_done = '1' then
                if R29(13) = '1' then
                    R29_middle <= "00000000000000";
                else
                    R29_middle <= R29;
                end if;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R30_middle <= (others => '0');
            elsif process1_done = '1' then
                if R30(13) = '1' then
                    R30_middle <= "00000000000000";
                else
                    R30_middle <= R30;
                end if;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R31_middle <= (others => '0');
            elsif process1_done = '1' then
                if R31(13) = '1' then
                    R31_middle <= "00000000000000";
                else
                    R31_middle <= R31;
                end if;
            end if;
        end if;
    end process; 
    
    
    ----------2nd Layer---------------------------
    
    --counter, delays and processing signals
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                counter2 <= (others => '0');
                done2<='0';
                start2<='0';
                process2_done<='0';
            elsif en_counter2 = '1' and reset='0' then
                start2<='1';
                counter2 <= counter2+1;
                if counter2_delayed="100111"  then
                    done2<='1';
                    process2_done<='1';
                end if;
            end if;
        end if;
    end process; 
    
    --weight address---
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                W2_count<=(others => '0');
            elsif en_counter2 = '1' then 
                if W2_count<="1001111" then      
                    W2_count<=W2_count+2;  
                else    
                    W2_count<=(others => '0');   
                end if;                            
            end if;
        end if;
    end process; 
    
    --multiplexer to select the neuron from layer 1
    V1 <= R0_middle when select_mux2="00" else
          R8_middle when select_mux2="01" else
          R16_middle when select_mux2="10" else
          R24_middle;
          
     V2 <= R1_middle when select_mux2="00" else
          R9_middle when select_mux2="01" else
          R17_middle when select_mux2="10" else
          R25_middle;
         
     
      V3 <= R2_middle when select_mux2="00" else      
          R10_middle when select_mux2="01" else
          R18_middle when select_mux2="10" else        
          R26_middle;
          
          
          
      V4 <= R3_middle when select_mux2="00" else        
          R11_middle when select_mux2="01" else       
          R19_middle when select_mux2="10" else    
          R27_middle;
          
          
     V5 <= R4_middle when select_mux2="00" else
          R12_middle when select_mux2="01" else
          R20_middle when select_mux2="10" else
          R28_middle;
          
     V6 <= R5_middle when select_mux2="00" else
          R13_middle when select_mux2="01" else
          R21_middle when select_mux2="10" else
          R29_middle;
         
     
      V7 <= R6_middle when select_mux2="00" else      
          R14_middle when select_mux2="01" else
          R22_middle when select_mux2="10" else        
          R30_middle;
          
          
          
      V8 <= R7_middle when select_mux2="00" else        
          R15_middle when select_mux2="01" else       
          R23_middle when select_mux2="10" else    
          R31_middle;     
          
          
    
    --mul 1
    V1_sg <= signed(V1);
    P1w2_sg <= signed(w2_out(7 downto 0));
    res2_mul1 <= std_logic_vector (res2_mul1_sg);
    res2_mul1_sg <= P1w2_sg*V1_sg;
    
    --mul 2
    V2_sg <= signed(V2);
    P2w2_sg <= signed(w2_out(15 downto 8));
    res2_mul2 <= std_logic_vector (res2_mul2_sg);
    res2_mul2_sg <= P2w2_sg*V2_sg;
    
    --mul 3
    V3_sg <= signed(V3);
    P3w2_sg <= signed(w2_out(23 downto 16));
    res2_mul3 <= std_logic_vector (res2_mul3_sg);
    res2_mul3_sg <= P3w2_sg*V3_sg;
    
    --mul 4
    V4_sg <= signed(V4);
    P4w2_sg <= signed(w2_out(31 downto 24));
    res2_mul4 <= std_logic_vector (res2_mul4_sg);
    res2_mul4_sg <= P4w2_sg*V4_sg;
    
    --mul 5
    V5_sg <= signed(V5);
    P5w2_sg <= signed(w2_out_b(7 downto 0));
    res2_mul5 <= std_logic_vector (res2_mul5_sg);
    res2_mul5_sg <= P5w2_sg*V5_sg;
    
    --mul 6
    V6_sg <= signed(V6);
    P6w2_sg <= signed(w2_out_b(15 downto 8));
    res2_mul6 <= std_logic_vector (res2_mul6_sg);
    res2_mul6_sg <= P6w2_sg*V6_sg;
    
    --mult 7
    V7_sg <= signed(V7);
    P7w2_sg <= signed(w2_out_b(23 downto 16));
    res2_mul7 <= std_logic_vector (res2_mul7_sg);
    res2_mul7_sg <= P7w2_sg*V7_sg;
    
    --mult 8
    V8_sg <= signed(V8);
    P8w2_sg <= signed(w2_out_b(31 downto 24));
    res2_mul8 <= std_logic_vector (res2_mul8_sg);
    res2_mul8_sg <= P8w2_sg*V8_sg;
    
    --selecting the stored result from previous cycle
    add_reg2 <= R0_final when select_enables2 = "0000" else
              R1_final when select_enables2= "0001" else
              R2_final when select_enables2 = "0010" else
              R3_final when select_enables2 = "0011"else
              R4_final when select_enables2= "0100" else
              R5_final when select_enables2 = "0101"else
              R6_final when select_enables2 = "0110" else
              R7_final when select_enables2 = "0111" else
              R8_final when select_enables2 = "1000" else
              R9_final;
             
    --adding the current result with previous cycle's one
    add_reg2_sg <= signed (add_reg2);
    res2_add <= std_logic_vector (res2_add_sg);
    res2_add_sg <= add_reg2_sg+ resize(res2_mul1_sg,res2_add_sg'length)+ resize(res2_mul2_sg,res2_add_sg'length)+ resize(res2_mul3_sg,res2_add_sg'length) + resize(res2_mul4_sg,res2_add_sg'length)+ resize(res2_mul5_sg,res2_add_sg'length)+resize(res2_mul6_sg,res2_add_sg'length)+resize(res2_mul7_sg,res2_add_sg'length)+resize(res2_mul8_sg,res2_add_sg'length);
   
    
    
   process (clk)
    begin
        if clk'event and clk='1' then
            if en_counter2 = '1' then
                select_mux2<=std_logic_vector(counter2(1 downto 0));               
                select_enables2<=counter2(5 downto 2);
                counter2_delayed<=counter2;
            end if;
        end if;
    end process; 
    

    --address selection for the next cycles' weights
    addr_w2 <= std_logic_vector(W2_count);
    addr_w2_b <= std_logic_vector(W2_count+1);       

    
    
    --"selecting" where to which registor to store the neuron's result
    enables2 <= "0000000001" when select_enables2 = "0000" else
                "0000000010" when select_enables2 = "0001" else
                "0000000100" when select_enables2 = "0010" else
                "0000001000" when select_enables2 = "0011" else
                "0000010000" when select_enables2 = "0100" else
                "0000100000" when select_enables2 = "0101" else
                "0001000000" when select_enables2 = "0110" else
                "0010000000" when select_enables2 = "0111" else
                "0100000000" when select_enables2 = "1000" else
                "1000000000"; 
             
             
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R0_final <= (others => '0');
            elsif enables2(0)='1' and process2_done = '0' and start2='1' then
                R0_final <= res2_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R1_final <= (others => '0');
            elsif enables2(1)='1' and process2_done = '0' and start2='1' then
                R1_final <= res2_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R2_final <= (others => '0');
            elsif enables2(2)='1' and process2_done = '0' and start2='1' then
                R2_final <= res2_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R3_final <= (others => '0');
            elsif enables2(3)='1' and process2_done = '0' and start2='1' then
                R3_final <= res2_add;
            end if;
        end if;
    end process;  
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R4_final <= (others => '0');
            elsif enables2(4)='1' and process2_done = '0' and start2='1' then
                R4_final <= res2_add;
            end if;
        end if;
    end process; 
    
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R5_final <= (others => '0');
            elsif enables2(5)='1' and process2_done = '0' and start2='1' then
                R5_final <= res2_add;
            end if;
        end if;
    end process; 
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R6_final <= (others => '0');
            elsif enables2(6)='1' and process2_done = '0' and start2='1' then
                R6_final <= res2_add;
            end if;
        end if;
    end process;
    
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R7_final <= (others => '0');
            elsif enables2(7)='1' and process2_done = '0' and start2='1' then
                R7_final <= res2_add;
            end if;
        end if;
    end process;  
    
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R8_final <= (others => '0');
            elsif enables2(8)='1' and process2_done = '0' and start2='1' then
                R8_final <= res2_add;
            end if;
        end if;
    end process;    
    
    process (clk)
    begin
        if clk'event and clk='1' then
            if reset='1' then
                R9_final <= (others => '0');
            elsif enables2(9)='1' and process2_done = '0' and start2='1' then
                R9_final <= res2_add;
            end if;
        end if;
    end process;  
    
    
    ---Comparisons and final result
    process (R0_final,R1_final)
    begin
        if signed(R0_final) >= signed(R1_final) then
            cmp1 <= signed(R0_final);
            result1<="0000";
        else
            cmp1 <= signed(R1_final);
            result1<="0001";
        end if;
    end process;
    
    
    process (R2_final,R3_final)
    begin
        if signed(R2_final) >= signed(R3_final) then
            cmp2 <= signed(R2_final);
            result2<="0010";
        else
            cmp2 <= signed(R3_final);
            result2<="0011";
        end if;
    end process;
    
    process (R4_final,R5_final)
    begin
        if signed(R4_final) >= signed(R5_final) then
            cmp3 <= signed(R4_final);
            result3<="0100";
        else
            cmp3 <= signed(R5_final);
            result3<="0101";
        end if;
    end process;
    
    process (R6_final,R7_final)
    begin
        if signed(R6_final) >= signed(R7_final) then
            cmp4 <= signed(R6_final);
            result4<="0110";
        else
            cmp4 <= signed(R7_final);
            result4<="0111";
        end if;
    end process;
    
    process (R8_final,R9_final)
    begin
        if signed(R8_final) >= signed(R9_final) then
            cmp5 <= signed(R8_final);
            result5<="1000";
        else
            cmp5 <= signed(R9_final);
            result5<="1001";
        end if;
    end process;
    
    
    
    process (cmp1,cmp2,cmp3)
    begin
        if cmp1 >= cmp2 and cmp1 >= cmp3 then
            cmp6 <= cmp1;
            result6<=result1;
        elsif cmp2 >= cmp1 and cmp2 >= cmp3 then
            cmp6 <= cmp2;
            result6<=result2;
        else
            cmp6 <= cmp3;
            result6<=result3;
        end if;
    end process;
    
    process (cmp4,cmp5)
    begin
        if cmp4 >= cmp5 then
            cmp7 <= cmp4;
            result7<=result4;
        else
            cmp7 <= cmp5;
            result7<=result5;
        end if;
    end process;
    
    
    process (cmp6,cmp7)
    begin
        if cmp6 >= cmp7 then
            result_final<=std_logic_vector(result6);
            cmp_final<=std_logic_vector(cmp6);
        else
            result_final<=std_logic_vector(result7);
            cmp_final<=std_logic_vector(cmp7);
        end if;
    end process;
    
    

end Behavioral;

