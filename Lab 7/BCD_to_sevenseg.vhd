-- BCD display for hex displays
-- (c) Cliff Chapman 2013

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;

-- Seven segment display output
-- 
ENTITY sevenseg_bcd_display IS
	port (
		-- Input value to display
		R 		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		-- Hex/Dec display select
		S 		: IN STD_LOGIC;
		-- sevenseg outputs
		HEX0	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0) := "1111111";
		HEX1	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0) := "1111111";
		HEX2	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0) := "1111111"
	);
END sevenseg_bcd_display;

ARCHITECTURE display OF sevenseg_bcd_display IS
		-- Hex output displays, customized for Altera DE2 board. May require
		-- redefinition for different board setups.
		CONSTANT hex_blk	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "1111111";
		CONSTANT hex_neg	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0111111";
		CONSTANT hex_zer	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "1000000";
		CONSTANT hex_one	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "1111001";
		CONSTANT hex_two	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0100100";
		CONSTANT hex_thr	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0110000";
		CONSTANT hex_fou	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0011001";
		CONSTANT hex_fiv	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0010010";
		CONSTANT hex_six	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0000010";
		CONSTANT hex_sev	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "1111000";
		CONSTANT hex_eig	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0000000";
		CONSTANT hex_nin	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0011000";
		CONSTANT hex_0xa	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0001000";
		CONSTANT hex_0xb	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0000011";
		CONSTANT hex_0xc	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "1000110";
		CONSTANT hex_0xd	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0100001";
		CONSTANT hex_0xe	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0000110";
		CONSTANT hex_0xf	: STD_LOGIC_VECTOR (6 DOWNTO 0) := "0001110";
		
		-- Internal buffer signals for display select
		SIGNAL HEX0_buff_hex : STD_LOGIC_VECTOR (6 DOWNTO 0);
		SIGNAL HEX1_buff_hex : STD_LOGIC_VECTOR (6 DOWNTO 0);
		SIGNAL HEX2_buff_hex : STD_LOGIC_VECTOR (6 DOWNTO 0);
		
		SIGNAL HEX0_buff_dec : STD_LOGIC_VECTOR (6 DOWNTO 0);
		SIGNAL HEX1_buff_dec : STD_LOGIC_VECTOR (6 DOWNTO 0);
		SIGNAL HEX2_buff_dec : STD_LOGIC_VECTOR (6 DOWNTO 0);
	BEGIN
	
	-- Generate a hex display
	display_hex : PROCESS (R)
		ALIAS high_bit	: STD_LOGIC_VECTOR (3 DOWNTO 0) IS R (7 DOWNTO 4);
		ALIAS low_bit	: STD_LOGIC_VECTOR (3 DOWNTO 0) IS R (3 DOWNTO 0);
	BEGIN
		CASE high_bit IS
			WHEN "0000" => HEX1_buff_hex <= hex_zer;
			WHEN "0001" => HEX1_buff_hex <= hex_one;
			WHEN "0010" => HEX1_buff_hex <= hex_two;
			WHEN "0011" => HEX1_buff_hex <= hex_thr;
			WHEN "0100" => HEX1_buff_hex <= hex_fou;
			WHEN "0101" => HEX1_buff_hex <= hex_fiv;
			WHEN "0110" => HEX1_buff_hex <= hex_six;
			WHEN "0111" => HEX1_buff_hex <= hex_sev;
			WHEN "1000" => HEX1_buff_hex <= hex_eig;
			WHEN "1001" => HEX1_buff_hex <= hex_nin;
			WHEN "1010" => HEX1_buff_hex <= hex_0xa;
			WHEN "1011" => HEX1_buff_hex <= hex_0xb;
			WHEN "1100" => HEX1_buff_hex <= hex_0xc;
			WHEN "1101" => HEX1_buff_hex <= hex_0xd;
			WHEN "1110" => HEX1_buff_hex <= hex_0xe;
			WHEN "1111" => HEX1_buff_hex <= hex_0xf;
			WHEN OTHERS => HEX1_buff_hex <= hex_blk;
		END CASE;
		CASE low_bit IS
			WHEN "0000" => HEX2_buff_hex <= hex_zer;
			WHEN "0001" => HEX2_buff_hex <= hex_one;
			WHEN "0010" => HEX2_buff_hex <= hex_two;
			WHEN "0011" => HEX2_buff_hex <= hex_thr;
			WHEN "0100" => HEX2_buff_hex <= hex_fou;
			WHEN "0101" => HEX2_buff_hex <= hex_fiv;
			WHEN "0110" => HEX2_buff_hex <= hex_six;
			WHEN "0111" => HEX2_buff_hex <= hex_sev;
			WHEN "1000" => HEX2_buff_hex <= hex_eig;
			WHEN "1001" => HEX2_buff_hex <= hex_nin;
			WHEN "1010" => HEX2_buff_hex <= hex_0xa;
			WHEN "1011" => HEX2_buff_hex <= hex_0xb;
			WHEN "1100" => HEX2_buff_hex <= hex_0xc;
			WHEN "1101" => HEX2_buff_hex <= hex_0xd;
			WHEN "1110" => HEX2_buff_hex <= hex_0xe;
			WHEN "1111" => HEX2_buff_hex <= hex_0xf;
			WHEN OTHERS => HEX2_buff_hex <= hex_blk;
		END CASE;
	END PROCESS display_hex;
	
	-- Generate a decimal display
	display_dec: PROCESS (R)
		ALIAS sign_bit	: STD_LOGIC IS R (7);
		VARIABLE r_lower: STD_LOGIC_VECTOR (7 DOWNTO 0);
		VARIABLE r_buff	: STD_LOGIC_VECTOR (7 DOWNTO 0);
	BEGIN
		-- Select value to work off of
		IF (sign_bit='1') THEN
			HEX0_buff_dec <= hex_neg;
			r_buff := (NOT(R) + "00000001");
		ELSIF (sign_bit='0') THEN
			HEX0_buff_dec <= hex_blk;
			r_buff := R;
		ELSE
			HEX0_buff_dec <= hex_blk;
			r_buff := "00000000";
		END IF;
		
		-- Display higher digit
		IF (r_buff >= "00001010" AND r_buff < "00010100") THEN -- Within 10-19
			HEX1_buff_dec <= hex_one;
			r_lower := r_buff - "00001010";
		ELSIF (r_buff >= "00010100" AND r_buff < "00011110") THEN -- Within 20-29
			HEX1_buff_dec <= hex_two;
			r_lower := r_buff - "00010100";
		ELSIF (r_buff >= "00011110" AND r_buff < "00101000") THEN -- Within 30-39
			HEX1_buff_dec <= hex_thr;
			r_lower := r_buff - "00011110";
		ELSIF (r_buff >= "00101000" AND r_buff < "00110010") THEN -- Within 40-49
			HEX1_buff_dec <= hex_fou;
			r_lower := r_buff - "00101000";
		ELSIF (r_buff >= "00110010" AND r_buff < "00111100") THEN -- Within 50-59
			HEX1_buff_dec <= hex_fiv;
			r_lower := r_buff - "00110010";
		ELSIF (r_buff >= "00111100" AND r_buff < "01000110") THEN -- Within 60-69
			HEX1_buff_dec <= hex_six;
			r_lower := r_buff - "00111100";
		ELSIF (r_buff >= "01000110" AND r_buff < "01010000") THEN -- Within 70-79
			HEX1_buff_dec <= hex_sev;
			r_lower := r_buff - "01000110";
		ELSIF (r_buff >= "01010000" AND r_buff < "01011010") THEN -- Within 80-89
			HEX1_buff_dec <= hex_eig;
			r_lower := r_buff - "01010000";
		ELSIF (r_buff >= "01011010" AND r_buff < "01100100") THEN -- Within 90-99
			HEX1_buff_dec <= hex_nin;
			r_lower := r_buff - "01011010";
		ELSE	-- 99 is the highest value we can reliably display.
			HEX1_buff_dec <= hex_zer;
			r_lower := r_buff;
		END IF;
			
		-- Display lower digit
		CASE r_lower IS
			WHEN "00000000" => HEX2_buff_dec <= hex_zer;
			WHEN "00000001" => HEX2_buff_dec <= hex_one;
			WHEN "00000010" => HEX2_buff_dec <= hex_two;
			WHEN "00000011" => HEX2_buff_dec <= hex_thr;
			WHEN "00000100" => HEX2_buff_dec <= hex_fou;
			WHEN "00000101" => HEX2_buff_dec <= hex_fiv;
			WHEN "00000110" => HEX2_buff_dec <= hex_six;
			WHEN "00000111" => HEX2_buff_dec <= hex_sev;
			WHEN "00001000" => HEX2_buff_dec <= hex_eig;
			WHEN "00001001" => HEX2_buff_dec <= hex_nin;
			WHEN OTHERS => HEX2_buff_dec <= hex_zer;
		END CASE;
	END PROCESS display_dec;
	
	-- Select display type for output
	select_display : PROCESS (S, HEX0_buff_hex, HEX1_buff_hex, HEX2_buff_hex, HEX0_buff_dec, HEX1_buff_dec, HEX2_buff_dec)
	BEGIN
		IF (s = '0') THEN
			HEX2 <= hex_blk;
			HEX1 <= HEX1_buff_hex;
			HEX0 <= HEX2_buff_hex;
		ELSIF (s = '1') THEN
			HEX2 <= HEX0_buff_dec;
			HEX1 <= HEX1_buff_dec;
			HEX0 <= HEX2_buff_dec;
		ELSE
			HEX2 <= hex_blk;
			HEX1 <= hex_blk;
			HEX0 <= hex_blk;
		END IF;
	END PROCESS select_display;
END display;