-------------------------------------------------------------------------------
--
-- Design       : sprom 
-- Project      : Digilent Terminal 
-- Author       : Srinivas Vaduvatha 
-- Company      : University of Southern California 
--
-------------------------------------------------------------------------------
--
-- File         : sprom.vhd
-- Version      : 1.0
--
-------------------------------------------------------------------------------
--
-- Description  : Data width & Address width - Generics
--                Single port synchronous memory. 
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
use work.instr_stream_pkg.all; -- instruction stream defining 

entity instruction_mem is 
generic (
         DATA_WIDTH     : integer := 32; 
         ADDR_WIDTH     : integer := 8
        );
port (
      addr          : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      data_out      : out std_logic_vector(DATA_WIDTH-1 downto 0);
	   clka          : in  std_logic
     ); 
end instruction_mem ; 

architecture inferrable of instruction_mem is 

signal addr_reg		:std_logic_vector(ADDR_WIDTH-1 downto 0);
begin 

mem_read: process (clka)--add clk 
begin 
  if (clka = '1' and clka'event) then
        addr_reg          <= addr ; 
  end if;
end process; 
data_out          <=  mem(CONV_INTEGER(addr_reg)); 

end inferrable ;
