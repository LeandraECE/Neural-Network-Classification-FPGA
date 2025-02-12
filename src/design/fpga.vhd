----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/13/2016 07:01:44 PM
-- Design Name: 
-- Module Name: fpga_basicIO - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fpga_basicIO is
  port (
    clk: in std_logic;                            -- 100MHz clock
    btnC, btnU, btnL, btnR, btnD: in std_logic;   -- buttons
    sw: in std_logic_vector(15 downto 0);         -- switches
    led: out std_logic_vector(15 downto 0);       -- leds
    an: out std_logic_vector(3 downto 0);         -- display selectors
    seg: out std_logic_vector(6 downto 0);        -- display 7-segments
    dp: out std_logic                             -- display point
  );
end fpga_basicIO;

architecture Behavioral of fpga_basicIO is
   -- signal dd3, dd2, dd1, dd0 : std_logic_vector(6 downto 0);
  signal no_image : std_logic_vector(6 downto 0);
  signal final_value : std_logic_vector(26 downto 0);
  signal dact,res : std_logic_vector(3 downto 0);
  signal btn, btnDeBnc : std_logic_vector(4 downto 0);
  signal btnCreg, btnUreg, btnLreg, btnRreg, btnDreg, minus_sign: std_logic;   -- registered input buttons
  signal sw_reg : std_logic_vector(15 downto 0);  -- registered input switches
  signal auxdigit3, auxdigit2, auxdigit1, auxdigit0 : std_logic_vector(3 downto 0);
  signal dp_aux :std_logic;
  
  component disp7
  port (
    digit3, digit2, digit1, digit0 : in std_logic_vector(3 downto 0);
    dp3, dp2, dp1, dp0 : in std_logic;
    clk : in std_logic;
    dactive : in std_logic_vector(3 downto 0);
    en_disp_l : out std_logic_vector(3 downto 0);
    segm_l : out std_logic_vector(6 downto 0);
    dp_l : out std_logic);
  end component;
  
  component debouncer
  generic (
    DEBNC_CLOCKS : integer;
    PORT_WIDTH : integer);
  port (
    signal_i : in std_logic_vector(4 downto 0);
    clk_i : in std_logic;          
    signal_o : out std_logic_vector(4 downto 0));
  end component;
  
  component circuito
    port(
     clk,reset: in std_logic;
     no_image : in std_logic_vector (6 downto 0);
     cmp_final : out std_logic_vector (26 downto 0);
     result_final : out std_logic_vector(3 downto 0)
      );
  end component;

begin
  led <= sw_reg;
 
  dact <= "1111";
  
 auxdigit3<= "0000" when sw_reg(15)='1' else
             final_value(25 downto 22);
  auxdigit2<= "0000" when sw_reg(15)='1' else
             final_value(21 downto 18);
  auxdigit1<= "0000" when sw_reg(15)='1' else
             final_value(17 downto 14);
  auxdigit0<= res(3 downto 0) when sw_reg(15)='1' else
             final_value(13 downto 10);
  
  dp_aux <= '1' when  sw_reg(15)='0' else '0';
  

  inst_disp7: disp7 port map(
      digit3 => auxdigit3, 
      digit2 => auxdigit2, 
      digit1 => auxdigit1, 
      digit0 => auxdigit0,
      dp3 => '0', dp2 => '0', dp1 => dp_aux, dp0 => '0', 
      clk => clk,
      dactive => dact,
      en_disp_l => an,
      segm_l => seg,
      dp_l => dp);

  inst_circuito: circuito port map(
      clk => clk,
      reset => btnUreg,
      no_image => sw_reg(6 downto 0),
      cmp_final => final_value, 
      result_final => res);
     
  -- Debounces btn signals
  btn <= btnC & btnU & btnL & btnR & btnD;    
  Inst_btn_debounce: debouncer 
    generic map (
        DEBNC_CLOCKS => (2**20),
        PORT_WIDTH => 5)
    port map (
		signal_i => btn,
		clk_i => clk,
		signal_o => btnDeBnc );
         
  process (clk)
    begin
       if rising_edge(clk) then
           btnCreg <= btnDeBnc(4); 
           btnUreg <= btnDeBnc(3); 
           btnLreg <= btnDeBnc(2); 
           btnRreg <= btnDeBnc(1); 
           btnDreg <= btnDeBnc(0);
           sw_reg <= sw;
       end if; 
    end process; 
       
end Behavioral;
