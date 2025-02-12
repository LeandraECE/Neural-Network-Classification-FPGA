LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY circuito_tb IS
END circuito_tb;
 
ARCHITECTURE behavior OF circuito_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT circuito
    PORT(
        clk,reset: in std_logic;
        no_image : in std_logic_vector (6 downto 0);  --Image number
        cmp_final: out std_logic_vector (26 downto 0);   --Value of the final result
        result_final : out std_logic_vector (3 downto 0)  --Final result (Number on the image)
    );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset  : std_logic := '1';
   signal no_image : std_logic_vector (6 downto 0) := "0001000";

 	--Outputs
   signal cmp_final: std_logic_vector (26 downto 0);
   signal result_final : std_logic_vector (3 downto 0);

   -- Clock period definitions  
   constant clk_period : time := 23 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: circuito PORT MAP (
          clk => clk,
          reset => reset,
          no_image=>no_image,
          result_final => result_final,
          cmp_final => cmp_final
        );

   -- Clock definition
   clk <= not clk after clk_period/2;
   
   
    -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;
      wait for 1 ns;
      
	  reset <= '1' ;
	  wait for clk_period*2;
	  reset <= '0' ;
      wait;
   end process;

END;