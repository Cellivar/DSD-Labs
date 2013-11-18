LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY quad_bit_alu IS
	port(
		a: IN SIGNED (3 DOWNTO 0);
		b: IN SIGNED (3 DOWNTO 0);
		s: IN UNSIGNED (2 DOWNTO 0);
		z: OUT std_logic;
		r: OUT SIGNED (7 DOWNTO 0)
		);
END quad_bit_alu;

ARCHITECTURE alu OF quad_bit_alu IS
	SIGNAL a_pad: SIGNED (7 DOWNTO 0);
	SIGNAL b_pad: SIGNED (7 DOWNTO 0);
	SIGNAL r_buff: SIGNED (7 DOWNTO 0);
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
			WHEN "000"	=> r_buff <= (a_pad AND b_pad);
			WHEN "001" 	=> r_buff <= (a_pad OR b_pad);
			WHEN "010" 	=> r_buff <= (a_pad XOR b_pad);
			WHEN "011" 	=> r_buff <= (NOT a_pad);
			WHEN "100" 	=> r_buff <= (a_pad + b_pad);
			WHEN "101" 	=> r_buff <= (a_pad - b_pad);
			WHEN "110" 	=> r_buff <= (a * b);
			WHEN "111" 	=> r_buff <= (NOT(a_pad) + "00000001");
			WHEN OTHERS => r_buff <= "00000000";
		END CASE;
	END PROCESS op_select;
	
	-- Handle zero out condition
	zero_out:PROCESS (r_buff)
	BEGIN
		CASE r_buff IS
			WHEN "00000000" => z <= '1';
			WHEN others		 => z <= '0';
		END CASE;
		
		r <= r_buff;
	END PROCESS zero_out;
	
	
END alu;