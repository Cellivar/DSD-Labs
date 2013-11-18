--*****************************************************************************
--***************************  VHDL Source Code  ******************************
--*********  Copyright 2011, Rochester Institute of Technology  ***************
--*****************************************************************************
--
--  DESIGNER NAME:  Jeanne Christman
--
--       LAB NAME:  ALU with 7-segment Display
--
--      FILE NAME:  display_tb.vhd
--
-------------------------------------------------------------------------------
--
--  DESCRIPTION
--
--    This test bench will provide input to test an eight bit binary to 
--    seven-segment display driver.  The inputs are an 8-bit binary number
--    and a selector signal that selects between hexidecimal and signed decimal 
--    display. There are three outputs which go to the 7-segment displays 
--
-------------------------------------------------------------------------------
--
--  REVISION HISTORY
--
--  _______________________________________________________________________
-- |  DATE    | USER | Ver |  Description                                  |
-- |==========+======+=====+================================================
-- |          |      |     |
-- | 10/02/13 | JWC  | 1.0 | Created
-- |          |      |     |
--
--*****************************************************************************
--*****************************************************************************

LIBRARY IEEE;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;            

ENTITY display_tb IS
END ENTITY display_tb;

ARCHITECTURE test OF display_tb IS

--the component name MUST match the entity name of the VHDL module being tested   
    COMPONENT sevenseg_out  
        PORT ( R    : 		in   STD_LOGIC_VECTOR(7 downto 0);                  --8-bit input
               S    : 	    in   STD_LOGIC;                                     --Select decimal or hexidecimal
               HEX0,HEX1,HEX2    : 	    out  STD_LOGIC_VECTOR(6 downto 0));     --ssd outputs
    END COMPONENT;


    -- testbench signals.  These do not need to be modified
    SIGNAL r_tb          : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL s_tb          : STD_LOGIC;
    --
    SIGNAL HEX0_tb          : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL HEX1_tb          : STD_LOGIC_VECTOR(6 DOWNTO 0); 
    SIGNAL HEX2_tb          : STD_LOGIC_VECTOR(6 DOWNTO 0);
    
BEGIN
--this must match component above
    UUT : sevenseg_out PORT MAP (  
        R              => r_tb,
        S              => s_tb,
        HEX0           => HEX0_tb,
        HEX1           => HEX1_tb,
        HEX2           => HEX2_tb
        );

    ---------------------------------------------------------------------------
    -- NAME: Stimulus
    --
    -- DESCRIPTION:
    --    This process will apply the stimulus to the UUT
    ---------------------------------------------------------------------------
    stimulus : PROCESS
    BEGIN
		-- create 2 loops to run through all the combinations of
		-- r numbers for each type of display
	
		FOR i IN STD_LOGIC RANGE '0' TO '1' LOOP
			s_tb <= i;
			FOR j IN 0 TO 255 LOOP
				r_tb <= std_logic_vector(to_unsigned(j,8));
				WAIT FOR 10 ns;
			END LOOP;
		END LOOP;
   

        -----------------------------------------------------------------------
        -- This last WAIT statement needs to be here to prevent the PROCESS
        -- sequence from restarting.
        -----------------------------------------------------------------------
        WAIT;
    END PROCESS stimulus;


END ARCHITECTURE test;
