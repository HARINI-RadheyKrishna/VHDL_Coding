-- Modified by Da Cheng in Summer 2010
-- Modified by Da Cheng, July 15th, 2013
-------------------------------------------------------------------------------
-- Description: 
-- Free register list keeps track of physical register IDs, used to solve read/write dependency.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 

--Entity declaration
entity Frl is 
generic (WIDE  : integer := 6;   DEEP  : integer:=16;    PTRWIDTH  :  integer:=5);
port (
	--Inputs
	Clk          	  		: in  std_logic;
	Resetb       		  	: in  std_logic;
	Cdb_Flush    			: in  std_logic ;
	--Interface with Rob
	Rob_CommitPrePhyAddr 	: in  std_logic_vector(WIDE-1 downto 0) ;
	Rob_Commit   			: in  std_logic ;
	Rob_CommitRegWrite 		: in std_logic;
	Cfc_FrlHeadPtr			: in  std_logic_vector(PTRWIDTH-1 downto 0) ;
	--Interface with Dis_FrlRead unit
	Frl_RdPhyAddr        	: out  std_logic_vector(WIDE-1 downto 0) ;
	Dis_FrlRead    			: in  std_logic ;
	Frl_Empty      			: out  std_logic ;
	--Interface with Previous Head Pointer Stack
	Frl_HeadPtr    			: out  std_logic_vector(PTRWIDTH-1 downto 0) 
);
end Frl;

architecture behav of Frl is
subtype freeregid is std_logic_vector(WIDE-1 downto 0);
type freeregid1 is array(0 to DEEP-1) of freeregid;
signal freereglist:freeregid1;
signal Frl_HeadPtr_temp :  std_logic_vector(PTRWIDTH-1 downto 0) ;
signal Frl_TailPtr :  std_logic_vector(PTRWIDTH-1 downto 0) ;

begin
--	Task 1:	Fill in the process with how to update FRL
--	Hint: 	Initialization of FRL contents: location 0	=physical register 32
--											location15 	=physical register 47
--			Update head pointer when dispatch and flush
--			Update tail pointer when commit
--			Free physical registers when commit
		
Process(Clk,Resetb)
variable i:integer;
begin
	if (Resetb = '0') then 
		freereglist <= ("100000", "100001", "100010", "100011", "100100", "100101", "100110", "100111", "101000", "101001", "101010", "101011", "101100", "101101", "101110", "101111");
		Frl_HeadPtr_temp <= "00000";
		Frl_TailPtr <= "10000";
	
	elsif (clk'event and clk = '0') then 
		if (Dis_FrlRead = '1') then
			Frl_HeadPtr_temp <= Frl_HeadPtr_temp + 1;
		end if;

		if (Cdb_Flush = '1') then
			Frl_TailPtr <= Frl_TailPtr - 1;
			if (Rob_CommitRegWrite) then 
				freereglist(Frl_HeadPtr_temp) <= Rob_CommitPrePhyAddr;
				Frl_HeadPtr_temp <= Frl_HeadPtr_temp + 1;
				--Cfc_FrlHeadPtr // do something with this
		end if;
		
		if (Rob_Commit) then
			Frl_TailPtr <= Frl_TailPtr + 1;
			if (Rob_CommitRegWrite) then 
				freereglist(Frl_HeadPtr_temp) <= Rob_CommitPrePhyAddr;
				Frl_HeadPtr_temp <= Frl_HeadPtr_temp + 1;
			end if;
		end if;
	end if;
end process;


--	Task 2:	generate the two signals: Frl_Empty and Frl_RdPhyAddr.

Frl_Empty <= '1' when (Frl_TailPtr = Frl_HeadPtr_temp) else '0';
			
Frl_RdPhyAddr	<= freereglist(CONV_INTEGER(UNSIGNED(Frl_HeadPtr_temp)));

Frl_HeadPtr		<=Frl_HeadPtr_temp;

end architecture behav;











