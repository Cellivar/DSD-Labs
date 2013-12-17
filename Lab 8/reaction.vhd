-- FPGA reaction time tester for Altera DE-2 board
-- Cliff Chapman
-- 10/27/2013
--
-- Lab 8 - Digital Systems Design

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;

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
		d_HEX0	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		d_HEX1	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		d_HEX2	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		d_HEX3	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		
		-- Trigger light
		LEDR	: OUT STD_LOGIC
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
	TYPE state_type IS (idle_s, wait_s, runprep_s, run_s, hold_s);
	SIGNAL state : state_type;
	
	SIGNAL clock_1 : STD_LOGIC := '0';
	SIGNAL cnt_rst : STD_LOGIC;
	
	SIGNAL disp_buf: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0000";
	SIGNAL mil_cnt	: STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0000";
	SIGNAL cnt : STD_LOGIC_VECTOR (15 DOWNTO 0) := x"0000";
	SIGNAL cnt_div :STD_LOGIC_VECTOR (31 DOWNTO 0) := x"00000000";
BEGIN
	-- Milliseconds elapsed display
	disp_low: sevenseg_bcd_display PORT MAP (
		r => disp_buf (15 DOWNTO 8),
		s => '0',
		HEX2 => OPEN,
		HEX1 => d_hex3,
		HEX0 => d_hex2
	);
	disp_high: sevenseg_bcd_display PORT MAP (
		r => disp_buf (7 DOWNTO 0),
		s => '0',
		HEX2 => OPEN,
		HEX1 => d_hex1,
		HEX0 => d_hex0
	);
	
	-- Clock divider for millisecond from 50Mhz
	clock_div: PROCESS (clk, rst)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (cnt_div >= x"61A7") THEN
				cnt_div <= x"00000000";
				clock_1 <= NOT clock_1;
			ELSE
				cnt_div <= cnt_div+1;
			END IF;
		END IF;
	END PROCESS clock_div;
	
	-- Counter for milliseconds timer
	mil_clock : PROCESS (clock_1, cnt_rst, state, cnt)
	BEGIN
		IF (cnt_rst = '0') THEN
			cnt <= x"0000";
		ELSIF (rising_edge(clock_1) AND cnt_rst = '1') THEN
			cnt <= cnt + '1';
		ELSE
			cnt <= cnt;
		END IF;
		mil_cnt <= cnt;
	END PROCESS mil_clock;
	
	state_monitor: PROCESS (state, clk, rst)
	BEGIN
		IF (rst = '0') THEN
			state <= idle_s;
		ELSIF (rising_edge(clk) AND rst = '1') THEN
			CASE state IS
				 WHEN idle_s =>
					IF (trig = '0') THEN
						state <= wait_s;
					ELSE
						state <= idle_s;
					END IF;
				 WHEN wait_s =>
					IF (mil_cnt >= ((x"00" & set) * x"3E8")) THEN
						state <= runprep_s;
					ELSE
						state <= wait_s;
					END IF;
				 WHEN runprep_s =>
					IF (mil_cnt = x"0000") THEN
						state <= run_s;
					ELSE
						state <= runprep_s;
					END IF;
				 WHEN run_s =>
					IF (trig = '0') THEN
						state <= hold_s;
					ELSE
						state <= run_s;
					END IF;
				 WHEN hold_s =>
					state <= hold_s;
				 WHEN OTHERS =>
					state <= idle_s;
			END CASE;
		END IF;
	END PROCESS state_monitor;
	
	output_monitor: PROCESS (state, clk, rst, mil_cnt)
	BEGIN
		IF (rst = '0') THEN
			cnt_rst <= '0';
			LEDR <= '0';
			disp_buf <= x"0000";
		ELSIF (rst = '1' AND rising_edge(clk)) THEN
			CASE (state) IS
				WHEN idle_s =>
					LEDR <= '0';
					cnt_rst <= '0';
					disp_buf <= x"0000";
				WHEN wait_s =>
					LEDR <= '1';
					cnt_rst <= '1';
					disp_buf <= x"0000";
				WHEN runprep_s =>
					LEDR <= '1';
					cnt_rst <= '0';
					disp_buf <= x"0000";
				WHEN run_s =>
					LEDR <= '0';
					cnt_rst <= '1';
					disp_buf <= mil_cnt;
				WHEN hold_s =>
					LEDR <= '0';
					cnt_rst <= '1';
					disp_buf <= disp_buf;
				WHEN OTHERS =>
					cnt_rst <= '0';
					LEDR <= '0';
					disp_buf <= x"0000";
			END CASE;
		END IF;
	END PROCESS output_monitor;
END ARCHITECTURE;