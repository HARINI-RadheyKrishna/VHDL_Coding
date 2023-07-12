library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity My_Design is 
    port (
        input1 : in std_logic_vector (7 downto 0);
        input2 : in std_logic_vector (7 downto 0);
        resetb : in std_logic;
        sel : in std_logic;
        output1 : out std_logic_vector (7 downto 0)
    );
end entity My_Design;

architecture mux of My_Design is

    begin
    my_mux: process(sel, resetb)
        begin
        if (resetb = '0') then
            output1 <= "00000000";
        else
            if (sel) then 
                output1 <= input2;
            else 
                output1 <= input1; -- Even if the output1 is assigned using non-blocking assignment operator, it doesnt infer a register in VHDL Coding. 
            -- only if you include a clk at the sensitivity list a register is inferred.
            end if;
        end if;
    end process my_mux;
end architecture mux;
