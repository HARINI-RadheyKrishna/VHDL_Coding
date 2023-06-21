-------------------------------------------------------------------------------
--
-- Description  : Data width & Address width - Generics
--                Dual port synchronous memory. Supports Read / Write on both ports 
--                Read / Write ports can be different clocks.
--                Infers BRAM resource in Xilinx FPGAs.
--                If the width / depth specified require more bits than in a single 
--                BRAM, multiple BRAMs are automatically cascaded to form a larger 
--                memory. Memory has to be of (2**n) depth
--
-------------------------------------------------------------------------------

-- libraries and use clauses
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity data_mem_dp is 
generic (
         DATA_WIDTH     : integer := 32; 
         ADDR_WIDTH     : integer := 5
        );
port ( 
      addr_a        : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_in_a     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      mem_write     : in  std_logic; 
      data_out_a    : out std_logic_vector(DATA_WIDTH-1 downto 0);
	  mem_read		: in  std_logic;	
	  clka          : in  std_logic
     ); 
end data_mem_dp ; 

architecture inferrable of data_mem_dp is 

-- type declarations
type mem_type is array (0 to (2**ADDR_WIDTH)-1) of std_logic_vector((DATA_WIDTH-1) downto 0); 

-- signals declarations.
signal data_internal    : std_logic_vector(DATA_WIDTH-1 downto 0);

signal mem : mem_type := (X"00000000", X"00000001", X"00000002", X"00000003",X"00000004", X"00000005",X"00000006", X"00000007", X"00000008", X"00000009", X"0000000A", X"0000000B", X"0000000C", X"0000000D", X"0000000E",X"0000000F",
                                   X"00000010", X"00000011", X"00000012", X"00000013",X"00000014", X"00000015",X"00000016", X"00000017", X"00000018", X"00000019", X"0000001A", X"0000001B", X"0000001C", X"0000001D", X"0000001E",X"0000001F") ;


begin 
porta_oper : process (clka) 
begin 
		if (clka'event and clka ='1') then
			if (mem_read = '1' or mem_write = '1') then
				if (mem_write = '1') then
    				mem(CONV_INTEGER(addr_a)) <= data_in_a; 
                    data_internal <= data_in_a;
				else
                    data_internal  <= mem(CONV_INTEGER(addr_a));
				end if;
			end if;

        -- the output is available one clock later because of the output reg
            data_out_a <= data_internal;
		end if;
end process; 

end inferrable ;
