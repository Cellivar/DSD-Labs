-- FPGA Traffic Light Controller for Altera DE-2 board
-- Cliff Chapman
-- 11/04/2013
--
-- Lab 9 - Digital Systems Design

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY tlc IS
	PORT(
		-- 50 mhz clock signal
		clk		: IN STD_LOGIC;
		-- Reset signal
		rst		: IN STD_LOGIC;
		
		-- Car occupancy sensor for side road
		s_car		: IN STD_LOGIC;
		
		-- Main road lights, RED YELLOW GREEN m to l
		m_light	: OUT STD_LOGIC_VECTOR (2 DOWNTO 0) := "100";
		-- Side road lights, RED YELLOW GREEN m to l
		s_light	: OUT STD_LOGIC_VECTOR (2 DOWNTO 0) := "001";
		
		-- Delay time display
		d_hex0	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		d_hex1	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		
	);
END tlc;

ARCHITECTURE rtl OF tlc IS
	COMPONENT sevenseg_bcd_display
		PORT (
			r						: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			s						: IN STD_LOGIC := '1'; -- Select tied to '1' by default to show numeric values
			HEX0, HEX1, HEX2	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
	
	-- State for main light loops
	TYPE state_type IS 
		(m_row_s, m_row_lock_s, s_row_s
		, main2side_s, side2main_s
		);
	SIGNAL state: state_type;
	
	-- State for light transition
	TYPE light_state_type IS 
		(main_g_side_r_s, main_r_side_g_s
		, main_r_side_ry_s, main_ry_side_r_s
		, main_y_side_r_s, main_r_side_y_s
		);
	SIGNAL state_light: light_state_type;
	
	-- Timer display output
	SIGNAL d_timer : STD_LOGIC_VECTOR (7 DOWNTO 0);
	-- Target for timeout
	SIGNAL timeout_limit : STD_LOGIC_VECTOR (7 DOWNTO 0);
	
	-- Count for the clock divider
	SIGNAL cnt: STD_LOGIC_VECTOR (26 DOWNTO 0) := "000000000000000000000000000";
	
	-- 1 second clock
	SIGNAL clock_1 : STD_LOGIC;
	
	-- Timeout state for count timers
	SIGNAL timeout : STD_LOGIC;
BEGIN

	disp : sevenseg_bcd_display PORT MAP (
		r => d_timer,
		s => '1',
		HEX2 => OPEN,
		HEX1 => d_hex1,
		HEX0 => d_hex0
	);

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
	

	state_monitor : PROCESS (state, clk, rst)
	BEGIN
		IF (rst = '0') THEN
			state <= m_row_s;
		ELSIF (rising_edge(clk) AND rst = '1') THEN
			CASE state IS
				WHEN m_row_s =>
					IF (s_car = '1') THEN
						state <= main2side_s;
					ELSE
						state <= m_row_s;
					END IF;
				WHEN main2side_s =>
					IF (state_light = main_r_side_g_s) THEN
						state <= s_row_s;
					ELSE
						state <= main2side_s;
					END IF;
				WHEN s_row_s =>
					IF (timeout = '1') THEN
						state <= side2main_s;
					ELSE
						state <= s_row_s;
					END IF;
				WHEN side2main_s =>
					IF (state_light = main_g_side_r_s) THEN
						state <= m_row_lock_s;
					ELSE
						state <= side2main_s;
					END IF;
				WHEN m_row_lock_s =>
					IF (timeout = '1') THEN
						state <= m_row_s;
					ELSE
						state <= m_row_lock_s;
					END IF;
				WHEN OTHERS =>
					state <= m_row_s;
			END CASE;
		END IF;
	END PROCESS state_monitor;
	
	light_state_monitor : PROCESS (state, state_light, timeout, rst, clk)
	BEGIN
		IF (rst = '0') THEN
			state_light <= main_g_side_r_s;
			timeout_limit <= "00000000";
		ELSIF (rising_edge(clk) AND rst = '1') THEN
			IF (state = main2side_s) THEN
				CASE state_light IS
					WHEN main_g_side_r_s =>
						state_light <= main_y_side_r_s;
					WHEN main_y_side_r_s =>
						timeout_limit <= "00001000";
						IF (timeout = '1') THEN
							timeout_limit <= "00001010";
							state_light <= main_r_side_ry_s;
						ELSE
							state_light <= main_y_side_r_s;
						END IF;
					WHEN main_r_side_ry_s =>
						IF (timeout = '1') THEN
							state_light <= main_r_side_g_s;
						ELSE
							state_light <= main_r_side_ry_s;
						END IF;
					WHEN OTHERS =>
						timeout_limit <= "ZZZZZZZZ";
				END CASE;
			ELSIF (state = side2main_s) THEN
				CASE state_light IS
					WHEN main_r_side_g_s =>
						state_light <= main_r_side_y_s;
						timeout_limit <= "00100110";
					WHEN main_r_side_y_s =>
						IF (timeout = '1') THEN
							timeout_limit <= "00101000";
							state_light <= main_ry_side_r_s;
						ELSE
							state_light <= main_r_side_y_s;
						END IF;
					WHEN main_ry_side_r_s =>
						IF (timeout = '1') THEN
							state_light <= main_g_side_r_s;
						ELSE
							state_light <= main_ry_side_r_s;
						END IF;
					WHEN OTHERS =>
						timeout_limit <= "ZZZZZZZZ";
				END CASE;
			END IF;
		END IF;
	END PROCESS light_state_monitor;
	
	timeout_counter : PROCESS (timeout_limit, clk, clock_1, rst, d_timer)
	BEGIN
		IF (timeout_limit = "00000000" OR rst = '0') THEN
			d_timer <= "00000000";
		ELSIF (rst = '1' AND timeout_limit /= "00000000" AND rising_edge(clock_1)) THEN
			d_timer <= d_timer + '1';
		ELSE
			d_timer <= d_timer;
		END IF;
	END PROCESS timeout_counter;
	
	timeout_monitor : PROCESS (d_timer, timeout_limit, rst)
	BEGIN
		IF (timeout_limit /= "00000000" AND rst = '1' AND d_timer >= timeout_limit) THEN
			timeout <= '1';
		ELSE
			timeout <= '0';
		END IF;
	END PROCESS timeout_monitor;
	
	output_monitor : PROCESS (state, state_light, rst)
	BEGIN
		IF (rst = '0') THEN
			timeout_limit <= "00000000";
			m_light <= "100";
			s_light <= "001";
		ELSE
			CASE state IS
				WHEN m_row_s => 
					timeout_limit <= "00000000";
				WHEN main2side_s =>
					timeout_limit <= "ZZZZZZZZ";
				WHEN s_row_s =>
					timeout_limit <= "00011110";
				WHEN side2main_s =>
					timeout_limit <= "ZZZZZZZZ";
				WHEN m_row_lock_s =>
					timeout_limit <= "01000110";
				WHEN OTHERS =>
					timeout_limit <= "ZZZZZZZZ";
			END CASE;
			CASE state_light IS
				WHEN main_g_side_r_s =>
					m_light <= "100";
					s_light <= "001";
				WHEN main_y_side_r_s =>
					m_light <= "010";
					s_light <= "001";
				WHEN main_r_side_g_s =>
					m_light <= "001";
					s_light <= "100";
				WHEN main_r_side_ry_s =>
					m_light <= "001";
					s_light <= "011";
				WHEN main_r_side_y_s =>
					m_light <= "001";
					s_light <= "010";
				WHEN main_ry_side_r_s =>
					m_light <= "011";
					s_light <= "001";
				WHEN OTHERS =>
					m_light <= "001";
					s_light <= "001";
			END CASE;
		END IF;
	END PROCESS output_monitor;
END ARCHITECTURE;