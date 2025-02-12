library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


------Circuit of datapath + control-----------

entity circuito is
  port (
    clk,reset: in std_logic;
    no_image : in std_logic_vector (6 downto 0);  --Image number
    cmp_final: out std_logic_vector (26 downto 0);   --Value of the final result
    result_final : out std_logic_vector (3 downto 0)  --Final result (Number on the image)
    );
end circuito;

architecture Behavioral of circuito is
  component control
   port (
    clk,reset: in std_logic;
    Done1:in std_logic;
    Done2: in std_logic;
    en_counter1 : out std_logic;
    en_counter2 : out std_logic
    );
  end component;
  component datapath
    port (
        clk, reset, en_counter1,en_counter2 : in std_logic;
        no_image : in std_logic_vector (6 downto 0);
        done1: out std_logic;
        done2: out std_logic;
        cmp_final: out std_logic_vector (26 downto 0);
        result_final : out std_logic_vector (3 downto 0)
       );
  end component;

    signal done_signal : std_logic;
    signal done_signal2 : std_logic;
    signal contador1 : std_logic;
    signal contador2 : std_logic;
    

begin
  inst_control: control port map(
    clk => clk,
    reset => reset,
    Done1=>done_signal,
    Done2=>done_signal2,
    en_counter2 => contador2,
    en_counter1 => contador1
    );
  inst_datapath: datapath port map(
    done1=>done_signal,
    done2=>done_signal2,
    en_counter1 => contador1,
    en_counter2 => contador2,
    no_image=> no_image,
    reset => reset,
    clk => clk,
    result_final => result_final,
    cmp_final => cmp_final
    );
    
    
 end Behavioral;
 
 
 