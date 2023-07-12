library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity model is 
    port (
        data_in : in std_logic_vector (7 downto 0);
        data_out : out std_logic_vector (7 downto 0);
        clk : in std_logic
    );
end entity model;

architecture type_subtype of model is 

    subtype row_type is std_logic_vector (1 downto 0);
    type  array_type is array (3 downto 0) of row_type;
    signal var : array_type;

begin
    my_block : process (clk)
    begin
        if (clk'event and clk = '1') then 
            for i in 0 to 3 loop
                var(i) <= data_in (i*4 + 1 downto i*4);
            end loop;

            data_out <= var(3)&var(2)&var(1)&var(0);
        end if;
    end process my_block;
end architecture type_subtype;