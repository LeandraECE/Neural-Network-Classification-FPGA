library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-----Control unit to command which layer to strat processing----

entity control is
  port (
    clk,reset: in std_logic;
    Done1:in std_logic;
    Done2: in std_logic;
    en_counter1 : out std_logic;
    en_counter2 : out std_logic
    );
  
end control;

architecture Behavioral of control is
  type fsm_states is (init,processing1,processing2);
  signal state, next_state: fsm_states:=init;

begin

    process (clk)
        begin 
            if clk'event and clk = '1' then
                if reset='1' then
                    state<=init;
                else
                    state <= next_state;
               end if;
            end if ;
    end process;
    

    process (state,Done1,Done2)
    begin
        case state is
            when init => 
                if Done1='0'and Done2='0' then
                    next_state <= processing1;
                elsif Done1='1'and Done2='0' then  
                    next_state <= processing2;
                else
                    next_state <= init;
                end if;
            when processing1 =>   
                if Done1='1' then
                    next_state <= init;
                else   
                    next_state <= processing1;
                end if;
                
            when processing2 =>   
                if Done2='1' then
                    next_state <= init;
                else   
                    next_state <= processing2;
                end if;
        end case;                 
    end process;

    process (state)
    begin
        case state is
            when processing1 => 
                en_counter1<='1';
                en_counter2<='0';
            
            when processing2 => 
                en_counter1<='0';
                en_counter2<='1';

            when others=>
                en_counter1<='0';
                en_counter2<='0';
            
        end case;
    end process;

end Behavioral;

