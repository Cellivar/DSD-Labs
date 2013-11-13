-- FPGA reaction time tester for Altera DE-2 board
-- Cliff Chapman
-- 10/27/2013
--
-- Lab 8 - Digital Systems Design

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY reaction IS 
	PORT (
		-- Reset system
		rst	: IN STD_LOGIC;
		-- Set time interval
		set	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		-- Trigger button
		trig	: IN STD_LOGIC;
		-- 50 Mhz external clock
		clk	: IN STD_LOGIC;
		
		-- Sevenseg displays
		HEX0	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX1	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX2	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX3	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		
		-- Trigger light
		ledr0	: OUT STD_LOGIC
	);
END reaction;

ARCHITECTURE rtl OF reaction IS
	COMPONENT sevenseg_bcd_display
		PORT (
			r						: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			s						: IN STD_LOGIC := '1'; -- Select tied to '1' by default to show numeric values
			HEX0, HEX1, HEX2	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
	
	-- This feels like a GREAT way to screw yourself over with
	-- overloading common names. Maybe that's just me.
	-- Either way that's why we have the _s hungarian postfix on these.
	TYPE state_type IS (idle_s, wait_s, run_s, hold_s)
	SIGNAL state : state_type;
	
	SIGNAL clock_1 : STD_LOGIC;
	
	SIGNAL mil_clk	: STD_LOGIC_VECTOR (15 DOWNTO 0) := "0000000000000000";
	ALIAS mil_high : STD_LOGIC_VECTOR (7 DOWNTO 0) IS mil_clk (15 DOWNTO 8);
	ALIAS mil_low	: STD_LOGIC_VECTOR (7 DOWNTO 0) IS mil_clk (7 DOWNTO 0);
BEGIN

	-- Enter into waiting state 
	PROCESS (rst, state)
	BEGIN
		IF (rst = '0' AND state = idle_s) THEN
			state <= wait_s;
		ELSE
			state <= idle_s;
		END IF;
	END PROCESS;
	
	-- Clock divider for millisecond from 50Mhz
	clock_div: PROCESS (clk)
		VARIABLE cnt_div :STD_LOGIC_VECTOR (15 DOWNTO 0) := "0000000000000000";
	BEGIN
		IF (rst = '0') THEN
			cnt_div := "0000000000000000";
		ELSIF (rising_edge(clk) AND rst = '1') THEN
			IF (cnt_div >= "0110000110100111") THEN
				cnt_div := "0000000000000000";
				clock_1 <= NOT clock_1;
			ELSE
				cnt_div := cnt_div + '1';
			END IF;
		ELSE
			cnt_div := cnt_div;
		END IF;
	END PROCESS clock_div;
	
	-- Counter for milliseconds timer
	mill_clock : PROCESS (clock_1, cnt_rst, state)
		VARIABLE cnt : STD_LOGIC_VECTOR (15 DOWNTO 0) := "0000000000000000";
	BEGIN
		IF (cnt_rst = '0') THEN
			cnt := "0000000000000000";
		ELSIF (rising_edge(clock_1) AND cnt_rst = '1') THEN
			IF (cnt >= "1111111111111111") THEN
				cnt := "0000000000000000";
			ELSE
				cnt := cnt + '1';
			END IF;
		ELSE
			cnt := cnt;
		END IF;
		mil_cnt <= cnt;
	END PROCESS mill_clock;
	
END ARCHITECTURE;