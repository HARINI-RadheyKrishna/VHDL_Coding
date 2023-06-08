------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

------------------------------------------------------------------------------

entity ALU is
port (
		alu_in1		: in std_logic_vector(31 downto 0);
		alu_in2		: in std_logic_vector(31 downto 0);
		alu_op		: in std_logic_vector(2 downto 0);
		alu_out		: out std_logic_vector(31 downto 0)
		);
end ALU;

architecture comput of ALU is

begin

	ALU_COMPUT: process (alu_in1, alu_in2, alu_op)
	begin
		
		case alu_op is
		when "000" =>
			alu_out <= alu_in1 + alu_in2;
		when "001" =>
			alu_out <= alu_in1 - alu_in2;
		when "010" =>
			alu_out <= alu_in1 and alu_in2;
		when "011" => 
			alu_out <= alu_in1 or alu_in2;
		when "100" =>
			alu_out(31 downto 1) <= (others => '0');
			
			if alu_in1 < alu_in2 then
				alu_out(0) <= '1';
			else
				alu_out(0) <= '0';
			end if;
		when others => 
			alu_out <= (others => '-');
			
		end case;
		
	end process ALU_COMPUT;

end architecture comput;