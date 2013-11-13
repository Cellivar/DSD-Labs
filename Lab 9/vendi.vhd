-- FPGA Clock Circuit for Altera DE-2 board
-- Cliff Chapman
-- 11/04/2013
--
-- Lab 9 - Digital Systems Design

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_signed.ALL;

ENTITY vendi IS
	PORT (
		-- Coins input
		nickel_in 	: IN STD_LOGIC;
		dime_in		: IN STD_LOGIC;
		quarter_in	: IN STD_LOGIC;
		
		-- User actions
		dispense		: IN STD_LOGIC;
		coin_return	: IN STD_LOGIC;
		
		-- Machine data
		clk			: IN STD_LOGIC;
		rst			: IN STD_LOGIC := '1';
	
		-- LED dispense status
		change_back	: OUT STD_LOGIC;
		red_bull		: OUT STD_LOGIC;
		
		-- Coin amount displays
		HEX0_disp	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX1_disp	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	);
END vendi;

ARCHITECTURE a OF vendi IS
	COMPONENT sevenseg_bcd_display
		PORT (
			r						: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			s						: IN STD_LOGIC := '1'; -- Select tied to '1' by default to show numeric values
			HEX0, HEX1, HEX2	: OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
	
	SIGNAL coin_val : STD_LOGIC_VECTOR (7 DOWNTO 0);

	-- Build an enumerated type for the state machine
	-- This feels like a GREAT way to screw yourself over with
	-- overloading common names. Maybe that's just me.
	-- Either way that's why we have the _s hungarian postfix on these.
	TYPE state_type IS 
		( idle_s, nickle_s, dime_s, quarter_s
		, enough_s, excess_s, vend_s, change_s
		);
	
	-- Register to hold the current state
	SIGNAL state : state_type;
BEGIN
	-- Display output of current coin value
	display : sevenseg_bcd_display PORT MAP (
		r => coin_val,
		s => '1',
		HEX2 => OPEN,
		HEX1 => HEX1_disp,
		HEX0 => HEX0_disp
	);


	state_monitor : PROCESS (rst, clk)
	BEGIN
		IF (rst = '0') THEN
			state <= idle_s;
		ELSIF (rising_edge(clk)) THEN
			CASE state IS
			-- IDLE STATE
				WHEN idle_s =>
					IF (nickel_in = '1') THEN
						state <= nickle_s;
					ELSIF (dime_in = '1') THEN
						state <= dime_s;
					ELSIF (quarter_in = '1') THEN
						state <= quarter_s;
					ELSIF (coin_val >= "01001011") THEN
						state <= enough_s;
					ELSE
						state <= idle_s;
					END IF;
			-- Coins states
				WHEN nickle_s =>
					IF (coin_val >= "01001011") THEN
						state <= enough_s;
					ELSE	
						state <= idle_s;
					END IF;
				WHEN dime_s =>
					IF (coin_val >= "01001011") THEN
						state <= enough_s;
					ELSE	
						state <= idle_s;
					END IF;
				WHEN quarter_s =>
					IF (coin_val >= "01001011") THEN
						state <= enough_s;
					ELSE	
						state <= idle_s;
					END IF;
			-- Enough money
				WHEN enough_s =>
					IF (coin_return = '1') THEN
						state <= change_s;
					ELSIF (dispense = '1') THEN
						state <= vend_s;
					ELSIF (nickel_in = '1') THEN
						state <= excess_s;
					ELSIF (dime_in = '1') THEN
						state <= excess_s;
					ELSIF (quarter_in = '1') THEN
						state <= excess_s;
					ELSE
						state <= enough_s;
					END IF;
			-- Too much money (Display may overload, can store up to 255 cents)
			-- TODO: add auto-return dump for values over 2 dollars?
				WHEN excess_s =>
					IF (coin_return = '1') THEN
						state <= change_s;
					ELSIF (dispense = '1') THEN
						state <= vend_s;
					-- Coin block again
					ELSIF (nickel_in = '1') THEN
						state <= excess_s;
					ELSIF (dime_in = '1') THEN
						state <= excess_s;
					ELSIF (quarter_in = '1') THEN
						state <= excess_s;
					ELSE
						state <= excess_s;
					END IF;
				WHEN vend_s =>
					IF (coin_val = "00000000") THEN
						state <= idle_s;
					ELSIF (coin_val > "00000000") THEN
						state <= change_s;
					END IF;
				WHEN OTHERS =>
					state <= idle_s;
			END CASE;
		END IF;
	END PROCESS state_monitor;
	
	PROCESS (state)
	BEGIN
		IF (state = vend_s) THEN
			red_bull <= '1';
		ELSE
			red_bull <= '0';
		END IF;
		IF  (state = change_s) THEN
			change_back <= '1';
		ELSIF (state = excess_s) THEN
			change_back <= '1';
		ELSE 
			change_back <= '0';
		END IF;
	END PROCESS;
	
	
	state_output : PROCESS (state, clk, rst)
		VARIABLE coin_cnt : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";
	BEGIN
		IF (rst = '0') THEN
			coin_cnt := "00000000";
		ELSIF (rising_edge(clk) AND rst = '1') THEN
			CASE state IS
				WHEN nickle_s	=> coin_cnt := coin_cnt + "00000101";
				WHEN dime_s		=> coin_cnt := coin_cnt + "00001010";
				WHEN quarter_s	=> coin_cnt := coin_cnt + "00011001";
				WHEN vend_s		=> coin_cnt := coin_cnt - "01001011";
				WHEN change_s	=> coin_cnt := "00000000";
				WHEN OTHERS		=> coin_cnt := coin_cnt;
			END CASE;
		ELSE
			coin_cnt := coin_cnt;
		END IF;
		
		coin_val <= coin_cnt;
	END PROCESS state_output;
	
END ARCHITECTURE;