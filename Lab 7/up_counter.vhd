-- 8 bit up counter with parallel load
-- (c) Cliff Chapman 2013

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY up_counter IS
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
END up_counter;

ARCHITECTURE counter OF up_counter IS
	SIGNAL reg_count : STD_LOGIC_VECTOR (7 DOWNTO 0);
BEGIN
	
	-- Count up on rising clock while running
	counter : PROCESS (clk, run, load, rst, reg_count) BEGIN
		IF (rst = '1') THEN
			reg_count <= "00000000";
		ELSIF (run = '0') THEN
			reg_count <= load;
		ELSIF (rising_edge(clk)) THEN
			IF (run = '1') THEN
				-- Regular run
				reg_count <= reg_count + 1;
			END IF;
		ELSE
			reg_count <= reg_count;
		END IF;
	END PROCESS counter;
	
	v <= reg_count;
END ARCHITECTURE;