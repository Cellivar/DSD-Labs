LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY name_detector IS
	PORT (
	b6, a, b, c, d, e: IN STD_LOGIC;
	first_cond, last_cond, first_sel, last_sel: OUT STD_LOGIC);
END name_detector;

ARCHITECTURE selective_name OF name_detector IS
	SIGNAL inputs: STD_LOGIC_VECTOR (5 DOWNTO 0);
	BEGIN
		inputs <= b6 & a & b & c & d & e;
		WITH inputs SELECT
			first_sel <=	'1' WHEN "100011" | "100110" | "101100" | "101001",
								'0' WHEN OTHERS;
		WITH inputs SELECT
			last_sel <=	'1' WHEN "100001" | "100011" | "101101" | "101110" | "101000" | "110000",
							'0' WHEN OTHERS;
							
		first_cond <=	'1'	WHEN inputs = "100011" ELSE
							'1'	WHEN inputs = "100110" ELSE
							'1'	WHEN inputs = "101100" ELSE
							'1'	WHEN inputs = "101001" ELSE
							'0';
								
		last_cond <= 	'1'	WHEN inputs = "100001" ELSE
							'1'	WHEN inputs = "100011" ELSE
							'1'	WHEN inputs = "101101" ELSE
							'1'	WHEN inputs = "101110" ELSE
							'1'   WHEN inputs = "101000" ELSE
							'1'	WHEN inputs = "110000" ELSE
							'0';
END selective_name;