library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
-------------------------------------------------------------------------------------------------------------
entity register_file is
    port(
			clk_rf					: in std_logic;
			reset_rf					: in std_logic;	
			write_data_rf			: in std_logic_vector(31 downto 0);
			wen_rf					: in std_logic;
			write_addr				: in std_logic_vector(4 downto 0);
			rsaddr_rf				: in std_logic_vector(4 downto 0);
			rtaddr_rf				: in std_logic_vector(4 downto 0);
			reg_read_addr			: in std_logic_vector(4 downto 0);
			rsdata_rf				: out std_logic_vector(31 downto 0);
			rtdata_rf				: out std_logic_vector(31 downto 0);
			reg_read_data			: out std_logic_vector(31 downto 0)
		  );
end register_file;


	architecture regfile of register_file is

		
	-- Register file Declaration
	subtype reg is std_logic_vector(31 downto 0);
	type reg_file is array (0 to 31) of reg;

	signal register_r: reg_file ;

	begin
	
	reg_read_data	<= register_r(CONV_INTEGER(UNSIGNED(reg_read_addr))); 
	
	reg_file_write: process(clk_rf,reset_rf)
	begin
	-------------------------------Initialize register file contents here----------------------------------
		if reset_rf='0' then
			register_r <= (	
								 
								"00000000000000000000000000000000",		-- $0
								"00000000000000000000000000000001",		-- $1
								"00000000000000000000000000000010",		-- $2
								"00000000000000000000000000000011",		-- $3
								"00000000000000000000000000000100",		-- $4
								"00000000000000000000000000000101",		-- $5
								"00000000000000000000000000000110",		-- $6
								"00000000000000000000000000000111",		-- $7
								"00000000000000000000000000001000",		-- $8
								"00000000000000000000000000001001",		-- $9
								"00000000000000000000000000001010",		-- $10
								"00000000000000000000000000001011",		-- $11
								"00000000000000000000000000001100",		-- $12
								"00000000000000000000000000001101",		-- $13
								"00000000000000000000000000001110",		-- $14
								"00000000000000000000000000001111",		-- $15
								"00000000000000000000000000000000",		-- $16
								"00000000000000000000000000000001",		-- $17
								"00000000000000000000000000000001",		-- $18
								"00000000000000000000000000000001",		-- $19
								"00000000000000000000000000000001",		-- $20
								"00000000000000000000000000000001",		-- $21
								"00000000000000000000000000000001",		-- $22
								"00000000000000000000000000000001",		-- $23
								"00000000000000000000000000000001",		-- $24
								"00000000000000000000000000000001",		-- $25
								"00000000000000000000000000000001",		-- $26
								"00000000000000000000000000010100",		-- $27  20
								"00000000000000000000000000010000",		-- $28  16
								"00000000000000000000000000001100",		-- $29  12
								"00000000000000000000000000001000",		-- $30  8
								"00000000000000000000000000000100"	   -- $31  4
								);

		elsif(clk_rf'event and clk_rf='0') then
				if (wen_rf ='1' and write_addr /= "00000") then  -- /= means not equal to
					register_r(CONV_INTEGER(UNSIGNED(write_addr)))<= write_data_rf;
				end if;	
		end if;

	end process reg_file_write;

	reg_file_read:	process (rsaddr_rf, rtaddr_rf, register_r)
	begin
		if(rsaddr_rf = "00000") then
			rsdata_rf <= (others => '0');
		else
			rsdata_rf <= register_r (CONV_INTEGER(UNSIGNED(rsaddr_rf)));
		end if;
		if(rtaddr_rf = "00000") then
			rtdata_rf <= (others => '0');
		else
			rtdata_rf <= register_r (CONV_INTEGER(UNSIGNED(rtaddr_rf)));
		end if;
	end process reg_file_read;

end regfile;