LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY quad_bit_alu IS
	port(
		a: IN SIGNED (3 DOWNTO 0); -- Arith input A
		b: IN SIGNED (3 DOWNTO 0); -- Arith input B
		s: IN UNSIGNED (2 DOWNTO 0); -- Arith Op Select
		HEX0	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX1	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX2	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
END quad_bit_alu;

ARCHITECTURE alu OF quad_bit_alu IS
		-- Hex display constants
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
		
		-- HEX buffers for hex displays
		SIGNAL HEX0_buff_hex : STD_LOGIC_VECTOR (6 DOWNTO 0);
		SIGNAL HEX1_buff_hex : STD_LOGIC_VECTOR (6 DOWNTO 0);
		SIGNAL HEX2_buff_hex : STD_LOGIC_VECTOR (6 DOWNTO 0);
		
		-- DEC buffers for hex displays
		SIGNAL HEX0_buff_dec : STD_LOGIC_VECTOR (6 DOWNTO 0);
		SIGNAL HEX1_buff_dec : STD_LOGIC_VECTOR (6 DOWNTO 0);
		SIGNAL HEX2_buff_dec : STD_LOGIC_VECTOR (6 DOWNTO 0);
		
		-- Padded variables
		SIGNAL a_pad: SIGNED (7 DOWNTO 0);
		SIGNAL b_pad: SIGNED (7 DOWNTO 0);
		
		-- Temp buffer for result value
		SIGNAL r_buff: STD_LOGIC_VECTOR (7 DOWNTO 0);
BEGIN

	-- Pad A
	pad_a: PROCESS(a)
		VARIABLE sign : std_logic;
	BEGIN
		sign:= a(3);
		
		IF (sign = '0') THEN
			a_pad <= ("0000" & a);
		ELSIF (sign = '1') THEN
			a_pad <= ("1111" & a);
		ELSE
			a_pad <= "00000000";
		END IF;
	END PROCESS pad_a;
	
	-- Pad B
	pad_b: PROCESS(b)
		VARIABLE sign : std_logic;
	BEGIN
		sign:= b(3);
		
		IF (sign = '0') THEN
			b_pad <= ("0000" & b);
		ELSIF (sign = '1') THEN
			b_pad <= ("1111" & b);
		ELSE
			b_pad <= "00000000";
		END IF;
	END PROCESS pad_b;
	
	-- Main ALU process
	op_select: PROCESS(s, a_pad, b_pad, a, b)
	BEGIN
		CASE s IS
			WHEN "000"	=> r_buff <= STD_LOGIC_VECTOR(a_pad AND b_pad);
			WHEN "001" 	=> r_buff <= STD_LOGIC_VECTOR(a_pad OR b_pad);
			WHEN "010" 	=> r_buff <= STD_LOGIC_VECTOR(a_pad XOR b_pad);
			WHEN "011" 	=> r_buff <= STD_LOGIC_VECTOR(NOT a_pad);
			WHEN "100" 	=> r_buff <= STD_LOGIC_VECTOR(a_pad + b_pad);
			WHEN "101" 	=> r_buff <= STD_LOGIC_VECTOR(a_pad - b_pad);
			WHEN "110" 	=> r_buff <= STD_LOGIC_VECTOR(a * b);
			WHEN "111" 	=> r_buff <= STD_LOGIC_VECTOR(NOT(a_pad) + "00000001");
			WHEN OTHERS => r_buff <= "00000000";
		END CASE;
	END PROCESS op_select;
	
	-- Generate a hex display
	display_hex : PROCESS (r_buff)
		ALIAS high_bit	: STD_LOGIC_VECTOR (3 DOWNTO 0) IS r_buff (7 DOWNTO 4);
		ALIAS low_bit	: STD_LOGIC_VECTOR (3 DOWNTO 0) IS r_buff (3 DOWNTO 0);
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
	display_dec: PROCESS (r_buff)
		ALIAS sign_bit	: STD_LOGIC IS r_buff (7);
		VARIABLE r_lower: STD_LOGIC_VECTOR (7 DOWNTO 0);
		VARIABLE r_buff_int	: STD_LOGIC_VECTOR (7 DOWNTO 0);
	BEGIN
		-- Select value to work off of
		IF (sign_bit='1') THEN
			HEX0_buff_dec <= hex_neg;
			r_buff_int := (NOT(r_buff) + "00000001");
		ELSIF (sign_bit='0') THEN
			HEX0_buff_dec <= hex_blk;
			r_buff_int := r_buff;
		ELSE
			HEX0_buff_dec <= hex_blk;
			r_buff_int := "00000000";
		END IF;
		
		-- Display higher digit
		IF (r_buff_int >= "00001010" AND r_buff_int < "00010100") THEN -- Within 10-19
			HEX1_buff_dec <= hex_one;
			r_lower := r_buff_int - "00001010";
		ELSIF (r_buff_int >= "00010100" AND r_buff_int < "00011110") THEN -- Within 20-29
			HEX1_buff_dec <= hex_two;
			r_lower := r_buff_int - "00010100";
		ELSIF (r_buff_int >= "00011110" AND r_buff_int < "00101000") THEN -- Within 30-39
			HEX1_buff_dec <= hex_thr;
			r_lower := r_buff_int - "00011110";
		ELSIF (r_buff_int >= "00101000" AND r_buff_int < "00110010") THEN -- Within 40-49
			HEX1_buff_dec <= hex_fou;
			r_lower := r_buff_int - "00101000";
		ELSIF (r_buff_int >= "00110010" AND r_buff_int < "00111100") THEN -- Within 50-59
			HEX1_buff_dec <= hex_fiv;
			r_lower := r_buff_int - "00110010";
		ELSIF (r_buff_int >= "00111100" AND r_buff_int < "01000110") THEN -- Within 60-69
			HEX1_buff_dec <= hex_six;
			r_lower := r_buff_int - "00111100";
		ELSE	-- We can't have any higher values from our ALU, everything else must be zero.
			HEX1_buff_dec <= hex_zer;
			r_lower := r_buff_int;
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
	select_display : PROCESS (s, HEX0_buff_hex, HEX1_buff_hex, HEX2_buff_hex, HEX0_buff_dec, HEX1_buff_dec, HEX2_buff_dec)
	BEGIN
		IF (s <= "011") THEN
			HEX0 <= hex_blk;
			HEX1 <= HEX1_buff_hex;
			HEX2 <= HEX2_buff_hex;
		ELSE
			HEX0 <= HEX0_buff_dec;
			HEX1 <= HEX1_buff_dec;
			HEX2 <= HEX2_buff_dec;
		END IF;
	END PROCESS select_display;
	
	
END alu;