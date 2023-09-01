-- Libraries and use clauses

library ieee;  --Template
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity divider is 

    port (x_in, y_in: IN std_logic_vector(3 downto 0);
        q, r: OUT std_logic_vector(3 downto 0);
        start, resetb, clk, ack: IN std_logic;
        done: OUT std_logic;
        Qi, Qc, Qd: OUT std_logic
    );

end divider;

architecture divider_RTL of divider is

type state_type is (INITIAL_STATE, COMPUTE_STATE, DONE_STATE);

signal state: state_type;
signal x, y, q_in: std_logic_vector(3 downto 0);

begin
    done <= '1' when (state = DONE_STATE) else '0';
    q <= q_in;
    r <= x_in;
    Qi <= '1' when (state = INITIAL_STATE) else '0';
    Qc <= '1' when (state = COMPUTE_STATE) else '0';
    Qd <= '1' when (state = DONE_STATE) else '0';


    CU_DPU: process (clk, resetb)

    begin

        if (resetb == '0') then
            x <= (others => 'X'); -- why are we updating the values of x, y here? Why not in the 
                                  -- concurrent signal assignment block
            y <= (others => 'X');
            q_in <= (others => '0000');
            state <= INITIAL_STATE;
            
        elif (clk'event and clk='1') then
            case (state) is

                when INITIAL_STATE =>  --why not 'then' statement here 
                    if (start == '1') then 
                        state <= COMPUTE_STATE;

                    end if;

                    x <= x_in;
                    y <= y_in;
                    q <= '0000';  -- why not use '' instead of ""?

                when COMPUTE_STATE =>
                    if (x >= y) then 
                        x <=x - y;
                        q_in <= q_in + 1;
                        state <= COMPUTE_STATE;

                    else 
                        state <= DONE_STATE;
                    end if;

                when DONE_STATE =>
                    if (ack== '1') then 
                        state <= INITIAL_STATE;

                    end if;
            end case;
        end if;
    end process CU_DPU;
end divider_RTL;