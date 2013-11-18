--*****************************************************************************
--***************************  VHDL Source Code  ******************************
--*********  Copyright 2011, Rochester Institute of Technology  ***************
--*****************************************************************************
--
--  DESIGNER NAME:  Jeanne Christman
--
--       LAB NAME:  ALU
--
--      FILE NAME:  ALU_tb.vhd
--
-------------------------------------------------------------------------------
--
--  DESCRIPTION
--
--    This test bench will provide input to test an eight function ALU.
--    The ALU function will accept two 4-bit numbers and a 3-bit selection
--    signal that will enable the operations in the table below.  The outputs R
--    is the 8 bit result and Z is one bit indicating that the result is 0 
--
-------------------------------------------------------------------------------
--
--  REVISION HISTORY
--
--  _______________________________________________________________________
-- |  DATE    | USER | Ver |  Description                                  |
-- |==========+======+=====+================================================
-- |          |      |     |
-- | 9/23/13  | JWC  | 1.0 | Created
-- |          |      |     |
--
--*****************************************************************************
--*****************************************************************************

LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;            

ENTITY alu_tb IS
END ENTITY alu_tb;

ARCHITECTURE test OF alu_tb IS

--the component name MUST match the entity name of the VHDL module being tested   
    COMPONENT quad_bit_alu  
        PORT ( a    : 		in   SIGNED(3 downto 0);                  --A input
			   b    : 		in   SIGNED(3 downto 0);                  --B input
               s    : 	    in   UNSIGNED(2 downto 0);                 --Selects operation
               z    :    	out  STD_LOGIC;                                      --Zero indicator   
               r    : 	    out  SIGNED(7 downto 0)                 --result  
             );
    END COMPONENT;


    -- testbench signals.  These do not need to be modified
    SIGNAL a_tb          : SIGNED(3 DOWNTO 0);
    SIGNAL b_tb          : SIGNED(3 DOWNTO 0);
    SIGNAL Sel_tb        : UNSIGNED(2 downto 0);
    --
    SIGNAL R_tb          : SIGNED(7 DOWNTO 0);
    SIGNAL Z_tb          : std_logic;

    
BEGIN
--this must match component above
    UUT : quad_bit_alu PORT MAP (  
        a           => a_tb,
        b           => b_tb,
        s           => sel_tb,
        z           => z_tb,
        r           => R_tb
        );

    ---------------------------------------------------------------------------
    -- NAME: Stimulus
    --
    -- DESCRIPTION:
    --    This process will apply the stimulus to the UUT
    ---------------------------------------------------------------------------
    stimulus : PROCESS
    BEGIN
            -- create 3 loops to run through all the combinations of
            -- a and b numbers for each operation
        FOR k in 0 to 7 Loop
			sel_tb <= UNSIGNED(to_unsigned(k,3));
			FOR i IN 0 TO 15 LOOP
				a_tb <= SIGNED(to_unsigned(i,4));
                FOR j IN 0 TO 15 LOOP
                    b_tb <= SIGNED(to_unsigned(j,4));
                    WAIT FOR 10 ns;
                END LOOP;
            END LOOP;
        END LOOP;

        -----------------------------------------------------------------------
        -- This last WAIT statement needs to be here to prevent the PROCESS
        -- sequence from restarting.
        -----------------------------------------------------------------------
        WAIT;
    END PROCESS stimulus;


END ARCHITECTURE test;
