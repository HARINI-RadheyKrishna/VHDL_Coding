

-- LIBRARY DECLARATION
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

--use work.tmslopkg.all

--ENTITY DECLARATION
entity issue_unit is
    generic(
      Resetb_ACTIVE_VALUE : std_logic := '0'  -- ACTIVE LOW Resetb
    );         
    port(
      Clk               :   in std_logic;
      Resetb             :   in std_logic;        

      -- ready signals from each of the queues 
      
      IssInt_Rdy      :   in std_logic;
      IssMul_Rdy      :   in std_logic;
      IssDiv_Rdy      :   in std_logic;
      IssLsb_Rdy      :   in std_logic;                    
	  
      -- signal from the division execution unit to indicate that it is currently available
      Div_ExeRdy    :   in std_logic;
      
      --issue signals as acknowledgement from issue unit to each of the queues
      Iss_Int         :   out std_logic;
      Iss_Mult        :   out std_logic; 
      Iss_Div         :   out std_logic;
      Iss_Lsb         :   out std_logic                               
    );       
        
end issue_unit;


-- ARCHITECTURE DECLARATION    
architecture Behavioral of issue_unit is

  signal CDB_Slot                         : std_logic_vector(5 downto 0); -- the CDB reservation register
  signal LRU_bit                          : std_logic;
 -- you can declare your own signals here
  
begin
   --NOTE:
   --================================================================================================================================================================================================
   -- 1. simple approach to decide priority between int type and "lw/sw" type instructions
   --   depending on the LRU bit issue the Least recently used instruction, use a LRU bit for the same which gets updated every time
   --   and instruction is issued.   
   -- FOR SIMPLICITY ASSUME 	LRU BIT WHEN AN INT TYPE INSTRUCTION IS ISSUED IS "0" AND WHEN A LW/SW TYPE INSTRUCTION IS ISSUED IS "1"
   --  PRECAUTION to be taken only issue the one whose corresponding issueque_ready signal is asserted ( = '1')
   --2. issue mult insturction when the CDB_slot (3) is free and the corresponding issueque_ready signal is asserted (= '1') --remember the 4 clock latency
   --3. issue div instruction when the Div_ExeRdy indicates that divider execution unit is ready and corresponding issueque_ready signal is asserted (= '1') -- remember the 7 clock latency  
   --4. don't forget to update the CDB register on every clock as per the required conditions.
   --==================================================================================================================================================================================================
   process(Resetb, Clk )
     -- variable CDB_slot_var   : std_logic_vector (5 downto 0);
  
     begin
      if(Resetb = '0') then
          -- TODO 1: INITIALIZE CDB and LRU Bit  
        CDB_Slot <= "000000";
        LRU_bit <= '0';

      elsif( Clk'event and Clk = '1' ) then
        CDB_slot <= CDB_slot srl 1;   -- TODO 2: COMPLETE THE SHIFT MECHANISM  
		    if(CDB_slot(0) = '0') then  --  TODO 3:  -- FILLUP THE LRU UPDATION MECHANISM WHEN ISSUING TO EITHER INT QUE OR LW/SW QUE
		                                         -- Three cases to be considered here:
												 -- Case 1: when only int type instructions get ready
												 -- Case 2: when only lw/sw type instructions get ready
												 -- Case 3: when both int type and lw/sw instructions get ready
            if (IssInt_Rdy = '1') and (IssLsb_Rdy = '0') then 
                LRU_bit <= '0';

            elsif (IssInt_Rdy = '0') and (IssLsb_Rdy = '1') then 
                LRU_bit <= '1';

            elsif (IssInt_Rdy = '1') and (IssLsb_Rdy = '1') and (LRU_bit /= 0) then
                LRU_bit <= '0';
            
            elsif (IssInt_Rdy = '1') and (IssLsb_Rdy = '1') and (LRU_bit /= 1) then
                LRU_bit <= '1';
            
            end if;
        end if;
        
		-- TODO 4: reserve CDB slot for issuing a div instruction	-- 7 CLOCK LATENCY
        -- TODO 5: reserve CDB slot for issuing a mult instruction  -- 4 CLOCK LATENCY
        if (IssDiv_Rdy = '1') then 
            CDB_Slot <= "100000";
        end if;

        if (IssMul_Rdy = '1') then
            CDB_Slot <= "000100";
        end if;

		-- NOTE: THE LATENCY CALCULATION IS INSIDE A CLOCKED PROCESS SO 1 CLOCK LATENCY WILL BE AUTOMATICALLY TAKEN CARE OF.
		--       IN OTHER WORDS YOU NEED TO FIGURE OUT THAT IF YOU NEED TO HAVE A LATENCY OF "N" WHICH CDB REGISTER NEEDS TO BE UPDATED
		--       IS IT REGISTER "N", REGISTER "N+1" OR REGISTER "N - 1 " ???? 
  
    end if;
  end process;
 
 process(LRU_bit, IssLsb_Rdy, IssInt_Rdy, IssDiv_Rdy, IssMul_Rdy, Div_ExeRdy, CDB_slot) -- TODO 6: GENERATE THE ISSUE SIGNALS 
     begin
        -- FILL UP THE CODE FOR ISSUING EITHER LW/SW OR INT TYPE INSTRUCTION DEPENDING ON LRU BIT
        -- MULTIPLE CASES NEED TO BE CONSIDERED SUCH AS WHEN ONLY ONE TYPE OF INSTRUCTION IS READY 
		-- OR WHEN BOTH TYPES OF INSTRUCTIONS ARE READY SIMULTANEOUSLY. 
        -- REFER TO THE THREE CASES MENTIONED IN  THE SECTION "TODO 3"		
		-- FILL UP THE CODE TO ISSUE A DIV TYPE INSTRUCTION
		-- FILL UP THE CODE TO ISSUE A MULT TYPE INSTRUCTION
      if (LRU_bit == '1' and (IssInt_Rdy = '1' or IssMul_Rdy = '1' or IssDiv_Rdy = '1')) then
        if (IssInt_Rdy = '1' and IssMul_Rdy = '0' and IssDiv_Rdy = '0') then 
          Iss_Int <= '1';
        
        elsif (IssInt_Rdy = '0' and IssMul_Rdy = '1' and IssDiv_Rdy = '0') then 
          Iss_Mult <= '1';

        elsif (IssInt_Rdy = '0' and IssMul_Rdy = '0' and IssDiv_Rdy = '1' and Div_ExeRdy = '1')
          Iss_Div <= '1';
        end if;

        if (IssInt_Rdy = '1' and IssMul_Rdy = '1' and IssDiv_Rdy = '0' and CDB_Slot /= "000100" or CDB_Slot /= "000010" or CDB_Slot "000001")
      end if;

      if (LRU_bit == '0') then
        if (IssLsb_Rdy = '1' and IssInt_Rdy /= '1') then 
          Iss_Lsb <= '1'; 
      end if;
end process;
     
    
end Behavioral;
        
        
        
        
        
