------------------------------------------------------------------------------
--
-- Design           : Branch Predicton Buffer
-- Project          : Tomasulo Processor 
-- Entity           : bpb
-- Author           : kapil 
-- Company          : University of Southern California 
-- Last Updated     : June 24, 2010, 6/10/2022
-- Last Updated by	: Waleed Dweik, Ruchit Ketanbhai Sheth <ruchitke@usc.edu>, Gandhi Puvvada <gandhi@usc.edu>
-- Modification		: 1. Modify the branch prediction to use the most well-known state machine of the 2-bit saturating counter
--					  2. Update old comments	3. Simplify coding
-------------------------------------------------------------------------------
--
-- Description :    2 - bit wide / 8 deep 
--                  each 2 bit location is a state machine
--                  2 bit saturating counter   
--                   00 strongly nottaken
--                   01 weakly nottaken
--                   10 weakly taken
--                   11 strongly taken 
--                    
-------------------------------------------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-------------------------------------------------------------------------------------------------------------
entity bpb is
   port (
         Clk                  : in std_logic;
         Resetb               : in std_logic; 
         ---- Interaction with Cdb -------------------
            Dis_CdbUpdBranch         : in  std_logic; -- indicates that a branch appears on Cdb(wen to bpb)
            Dis_CdbUpdBranchAddr     : in std_logic_vector(2 downto 0);-- indicates the last 3 bit addr of the branch on the Cdb
            Dis_CdbBranchOutcome     : in std_logic; -- indiacates the outocome of the branch to the bpb: 0 means nottaken and 1 means taken 
			
         ---- Interaction with dispatch --------------
            Bpb_BranchPrediction        : out std_logic;  --This bit tells the dispatch what the prediction is (based on bpb state-mc)
            Dis_BpbBranchPCBits         : in std_logic_vector(2 downto 0) ;--indicates the 3 least sig bits of the current instr being dispatched
            Dis_BpbBranch               : in std_logic -- indicates that there is a branch instr in the dispatch (ren to the bpb)
         );
end bpb;



architecture behv of bpb is

   subtype sat_counters is std_logic_vector(1 downto 0);
   type bpb_array is array (0 to 7) of sat_counters ;
   signal bpb_array_r: bpb_array ;						-- An array of 8 2-bit saturating counters represents 8 location bpb.
   signal Bpb_read_status,Bpb_write_status : std_logic_vector(1 downto 0);
   

begin
--Task 1:- This process is used to read two sets of 2-bit values from BPB 
--Use appropriate signals to index BPB. 
-- The CONV_INTEGER function as shown below is necessary to convert from std_logic_vector to an integer

--Indexing BPB while dispatching an instruction for the purpose of predicting the branch
Bpb_read_status <= bpb_array_r (CONV_INTEGER(Dis_BpbBranchPCBits));  -- give prediction to dispatch
--Indexing BPB while a branch instruction is on CDB. We need to get the current 2-bit value to update it 
-- updating = based on the branch outcome, incrementing it or decrementing it if it is not already at "11" or "00" respectively  
Bpb_write_status <= bpb_array_r (CONV_INTEGER(Dis_CdbUpdBranchAddr));  -- read status for updating -- produce write_data_bpb from it and write it back to BPB




-- Task 2:- This process is used to update the Bpb entry indexed by the PC[4:2] of the branch instruction appearing on Cdb.
-- The update process is based on the State machine for a 2-bit saturating counter which is given in the slide set.
bpb_write: process (Clk,Resetb)

variable write_data_bpb: std_logic_vector(1 downto 0);

begin
    if (Resetb = '0') then
   -- Initialize register file contents(!! weakly taken, weakly not taken alternatvely!!). 
   -- This initialization helps our students to look at both taken and not taken branch predictions.
   -- In real processors, probably they initialize all entries to "weakly not taken" and let the BPB "learn" during run time.   

       bpb_array_r <= ( 
                      "01",            -- $0
                      "10",            -- $1
                      "01",            -- $2
                      "10",            -- $3
                      "01",            -- $4
                      "10",            -- $5
                      "01",            -- $6
                      "10"             -- $7
                      
                      );
                      
	elsif(Clk'event and Clk='1') then
       


		-- determine the next state (new 2-bit value "write_data_bpb") 
		     -- based on the current state (current 2-bit value, "Bpb_write_status") and "Dis_CdbBranchOutcome".
        -- Use the 2-bit fsm where states are Strongly not taken, Not taken, Taken, Strongly Taken 
		-- Notice that write_data_bpb was declared as a variable. Similar to variable usage in the Special counter lab, 
		--   here you may want to start with the default assignment  
		      -- write_data_bpb := Bpb_write_status;
			  -- and selectively increment it if the branch outcome is taken and you are not already at "11"
			  --              or decrement it if the branch outcome is not-taken and you are not already at "00"
			  -- You can choose to use a "case" statement for the 4 states or four independent "if" statements (or one long nested "if" statement).
			  -- Remember, a later assignment to the same variable (or signal) overrides an earlier assignment to the same variable (or signal).
			  -- Note: Is it OK to write   + 1   or   + '1'    or + "01"  for incrementation?
			  --	   Is it OK to write   - 1   or   - '1'    or - "01"  for decrementation? 
			  --       Yes, because  you have the following two lines at the top!
			  --       use IEEE.STD_LOGIC_ARITH.ALL;
			  --       use IEEE.STD_LOGIC_UNSIGNED.ALL;
			  --	   Explore and learn!
			  --       https://cseweb.ucsd.edu//~hepeng/cse143-w08/labs/VHDLReference/ab.pdf

		write_data_bpb := Bpb_write_status
      if  (Dis_CdbUpdBranch = '1') then
         if (Bpb_write_status = "00") then
            if (Dis_CdbBranchOutcome /= '0') then
               write_data_bpb := write_data_bpb + 1;
            else 
               write_data_bpb := write_data_bpb - 1;
            end if;
         end if;

         if (Bpb_write_status = "01") then
            if (Dis_CdbBranchOutcome /= '0') then
               write_data_bpb := write_data_bpb + 1;
            else 
               write_data_bpb := write_data_bpb - 1;
            end if;           
         end if;

         if (Bpb_write_status = "10") 
            if (Dis_CdbBranchOutcome /= '0') then
               write_data_bpb := write_data_bpb + 1;
            else
               write_data_bpb := write_data_bpb - 1;
            end if;
         end if;

         if (Bpb_write_status = "11") 
            if  (Dis_CdbBranchOutcome /= '0') then
               write_data_bpb := write_data_bpb + 1;
            else
               write_data_bpb := write_data_bpb - 1;
            end if;
         end if;
      end if;
	end if;
   bpb_array_r(CONV_INTEGER(Dis_CdbUpdBranchAddr)) <= write_data_bpb;
end process bpb_write;


-- Prediction Process
-- This process generates Bpb_BranchPrediction signal which indicates the prediction for branch instruction
-- The signal is always set to '0' except when there is a branch instruction in dispatch 
--                                              and the prediction is either Strongly Taken or Taken.
bpb_predict : process(Bpb_read_status ,Dis_BpbBranch )
begin
    Bpb_BranchPrediction<= '0';
    if (Bpb_read_status(1) = '0' ) then 
        Bpb_BranchPrediction<= '0';
    else
       Bpb_BranchPrediction<= '1' and Dis_BpbBranch;
	end if ;
   
end process;
    

   
end behv;


   
                      
	
