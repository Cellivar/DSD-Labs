-- FPGA Clock Circuit for Altera DE-2 board
-- 24 hour clock implementation
-- Cliff Chapman
-- 10/16/2013
--
-- Lab 7 - Digital Systems Design

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY clock IS
	PORT (
		-- Run/Set. Running when high, Set from select pins when low
		run_set	: IN STD_LOGIC;
		-- 50hz clock
		clk: IN STD_LOGIC;
		-- Reset to 0
		rst		: IN STD_LOGIC;
		-- Set inputs
		set		: IN STD_LOGIC_VECTOR (16 DOWNTO 0);
		
		-- Test second pin
		clock_1hz: OUT STD_LOGIC;
		
		-- Hour hex displays
		hr_1	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		hr_0	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		-- Minute hex displays
		mn_1	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		mn_0	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		-- Second hex displays
		sd_1	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		sd_0	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	);
END ENTITY;
		
		
ARCHITECTURE time OF clock IS
	COMPONENT up_counter
		PORT (
			-- Load. When run is low used for parallel load
			load	:	IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			-- Clock Input
			clk	:	IN STD_LOGIC;
			-- Run/Set. High to run, low to set from load input
			run	:	IN STD_LOGIC;
			-- Async reset.
			rst	:	IN STD_LOGIC := '0';
			-- Output value
			v		:	OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT sevenseg_bcd_display
		PORT (
			r						: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			s						: IN STD_LOGIC;
			HEX0, HEX1, HEX2	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
	
	-- Aliases for setting values
	ALIAS set_hr : STD_LOGIC_VECTOR (4 DOWNTO 0) IS set (16 DOWNTO 12);
	ALIAS set_mn : STD_LOGIC_VECTOR (5 DOWNTO 0) IS set (11 DOWNTO 6);
	ALIAS set_sd : STD_LOGIC_VECTOR (5 DOWNTO 0) IS set (5 DOWNTO 0);
	
	-- Internal clock values
	SIGNAL clock_1			: STD_LOGIC := '1';
	SIGNAL clock_sd_rst	: STD_LOGIC := '0';
	SIGNAL clock_mn_rst	: STD_LOGIC := '0';
	SIGNAL clock_hr_rst	: STD_LOGIC := '0';
	
	-- Hex display signals
	SIGNAL disp_sd			: STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";
	SIGNAL disp_mn			: STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";
	SIGNAL disp_hr			: STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";
		-- Signals for setting/limiting clocks
	SIGNAL clock_sd_set	: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL clock_mn_set	: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL clock_hr_set	: STD_LOGIC_VECTOR (7 DOWNTO 0);
	
	SIGNAL run				: STD_LOGIC := '0';
	
	SIGNAL cnt: STD_LOGIC_VECTOR (26 DOWNTO 0) := "000000000000000000000000000";
BEGIN
	
	-- Clock divider
	clock_div: PROCESS (clk, cnt)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (cnt >= "001111110000011110101111101") THEN
				cnt <= "000000000000000000000000000";
				clock_1 <= NOT clock_1;
			ELSE
				cnt <= cnt + '1';
			END IF;
		END IF;
	END PROCESS clock_div;
	
	upcnt_sd : up_counter PORT MAP (
		load => clock_sd_set,
		clk => clock_1,
		run => run,
		rst => clock_sd_rst,
		v => disp_sd
	);
	
	PROCESS (disp_sd, run) BEGIN
		IF (run = '1') THEN
			IF (disp_sd >= "00111100") THEN
				clock_sd_rst <= '1';
			ELSE
				clock_sd_rst <= '0';
			END IF;
		ELSE
			clock_sd_rst <= '0';
		END IF;
	END PROCESS;
	
	upcnt_mn : up_counter PORT MAP (
		load => clock_mn_set,
		clk => clock_sd_rst,
		run => run,
		rst => clock_mn_rst,
		v => disp_mn
	);
	
	PROCESS (disp_mn, run) BEGIN
		IF (run = '1') THEN
			IF (disp_mn >= "00111100") THEN
				clock_mn_rst <= '1';
			ELSE
				clock_mn_rst <= '0';
			END IF;
		ELSE
			clock_mn_rst <= '0';
		END IF;
	END PROCESS;
	
	upcnt_hr : up_counter PORT MAP (
		load => clock_hr_set,
		clk => clock_mn_rst,
		run => run,
		rst => clock_hr_rst,
		v => disp_hr
	);
	
	PROCESS (disp_hr, run) BEGIN
		IF (run = '1') THEN
			IF (disp_hr >= "00011000") THEN
				clock_hr_rst <= '1';
			ELSE
				clock_hr_rst <= '0';
			END IF;
		ELSE
			clock_hr_rst <= '0';
		END IF;
	END PROCESS;
	
	
	-- Second display
	display_sd : sevenseg_bcd_display port map(
		r => disp_sd,
		s => '1',
		HEX2 => OPEN,
		HEX1 => sd_1,
		HEX0 => sd_0
	);
	
	-- Minute display
	display_mn : sevenseg_bcd_display PORT MAP(
		r => disp_mn,
		s => '1',
		HEX2 => OPEN,
		HEX1 => mn_1,
		HEX0 => mn_0
	);
	
	-- Hour display
	display_hr : sevenseg_bcd_display PORT MAP(
		r => disp_hr,
		s => '1',
		HEX2 => OPEN,
		HEX1 => hr_1,
		HEX0 => hr_0
	);
		
	
	-- Async Reset
	-- (Doesn't actually reset, just goes into set mode)
	PROCESS (run_set, rst) 
		VARIABLE derp : STD_LOGIC_VECTOR (1 DOWNTO 0);
	BEGIN
		derp := run_set & rst;
		
		CASE derp IS
			WHEN "00" => run <= '0';
			WHEN "01" => run <= '0';
			WHEN "10" => run <= '0';
			WHEN "11" => run <= '1';
			WHEN OTHERS => run <= '0';
		END CASE;
	END PROCESS;
	
	-- Set current clock
	clock_1hz <= clock_1;
	clock_sd_set <= "00" & set_sd; 
	clock_mn_set <= "00" & set_mn;
	clock_hr_set <= "000" & set_hr;
END ARCHITECTURE;