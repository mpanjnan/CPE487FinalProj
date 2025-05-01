library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY siren IS
	PORT (
		clk_50MHz : IN STD_LOGIC; -- system clock (50 MHz)
		dac_MCLK : OUT STD_LOGIC; -- outputs to PMODI2L DAC
		dac_LRCK : OUT STD_LOGIC;
		dac_SCLK : OUT STD_LOGIC;
		dac_SDIN : OUT STD_LOGIC;
		KBR_col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1);
		KBR_row : IN STD_LOGIC_VECTOR (4 DOWNTO 1);
		KBL_col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1);
		KBL_row : IN STD_LOGIC_VECTOR (4 DOWNTO 1);
		SWL : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		SWR : IN STD_LOGIC_VECTOR (1 DOWNTO 0)
	);
END siren;

ARCHITECTURE Behavioral OF siren IS
	CONSTANT lo_tone : UNSIGNED (13 DOWNTO 0) := to_unsigned (344, 14); -- lower limit of siren = 256 Hz
	CONSTANT hi_tone : UNSIGNED (13 DOWNTO 0) := to_unsigned (687, 14); -- upper limit of siren = 512 Hz
	CONSTANT wail_speed : UNSIGNED (7 DOWNTO 0) := to_unsigned (8, 8); -- sets wailing speed
	
	COMPONENT keypad IS
		PORT (
			samp_ck : IN STD_LOGIC;
			col : OUT STD_LOGIC_VECTOR (4 DOWNTO 1);
			row : IN STD_LOGIC_VECTOR (4 DOWNTO 1);
			value : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			hit : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT dac_if IS
		PORT (
			SCLK : IN STD_LOGIC;
			L_start : IN STD_LOGIC;
			R_start : IN STD_LOGIC;
			L_data : IN signed (15 DOWNTO 0);
			R_data : IN signed (15 DOWNTO 0);
			SDATA : OUT STD_LOGIC
		);
	END COMPONENT;
	COMPONENT wail IS
		PORT (
			lo_pitch : IN UNSIGNED (13 DOWNTO 0);
			hi_pitch : IN UNSIGNED (13 DOWNTO 0);
			wspeed : IN UNSIGNED (7 DOWNTO 0);
			wclk : IN STD_LOGIC;
			kval : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			audio_clk : IN STD_LOGIC;
			audio_data : OUT SIGNED (15 DOWNTO 0);
			sw : IN STD_LOGIC_VECTOR (1 DOWNTO 0)
		);
	END COMPONENT;
	SIGNAL tcount : unsigned (19 DOWNTO 0) := (OTHERS => '0'); -- timing counter
	SIGNAL data_L, data_R : SIGNED (15 DOWNTO 0); -- 16-bit signed audio data
	SIGNAL dac_load_L, dac_load_R : STD_LOGIC; -- timing pulses to load DAC shift reg.
	SIGNAL slo_clk, sclk, audio_CLK : STD_LOGIC;

	SIGNAL kp_clk, kpr_hit, kpl_hit : std_logic;
	SIGNAL kpr_value, kpl_value : std_logic_vector (3 DOWNTO 0);
	
BEGIN
	-- this process sets up a 20 bit binary counter clocked at 50MHz. This is used
	-- to generate all necessary timing signals. dac_load_L and dac_load_R are pulses
	-- sent to dac_if to load parallel data into shift register for serial clocking
	-- out to DAC
	
	tim_pr : PROCESS
	BEGIN
		WAIT UNTIL rising_edge(clk_50MHz);
		IF (tcount(9 DOWNTO 0) >= X"00F") AND (tcount(9 DOWNTO 0) < X"02E") THEN
			dac_load_L <= '1';
		ELSE
			dac_load_L <= '0';
		END IF;
		IF (tcount(9 DOWNTO 0) >= X"20F") AND (tcount(9 DOWNTO 0) < X"22E") THEN
			dac_load_R <= '1';
		ELSE dac_load_R <= '0';
		END IF;
		tcount <= tcount + 1;
	END PROCESS;
	
	kp_clk <= tcount(15);
	
	kpr : keypad
	PORT MAP(
		samp_ck => kp_clk, col => KBR_col, 
		row => KBR_row, value => kpr_value, hit => kpr_hit
	);
	kpl : keypad
	PORT MAP(
	    samp_ck => kp_clk, col => KBL_col, 
		row => KBL_row, value => kpl_value, hit => kpl_hit
	);
	
	dac_MCLK <= NOT tcount(1); -- DAC master clock (12.5 MHz)
	audio_CLK <= tcount(9); -- audio sampling rate (48.8 kHz)
	dac_LRCK <= audio_CLK; -- also sent to DAC as left/right clock
	sclk <= tcount(4); -- serial data clock (1.56 MHz)
	dac_SCLK <= sclk; -- also sent to DAC as SCLK
	slo_clk <= tcount(19); -- clock to control wailing of tone (47.6 Hz)
	dac : dac_if
	PORT MAP(
		SCLK => sclk, -- instantiate parallel to serial DAC interface
		L_start => dac_load_L, 
		R_start => dac_load_R, 
		L_data => data_L, 
		R_data => data_R, 
		SDATA => dac_SDIN 
		);
		w1 : wail
		PORT MAP(
			lo_pitch => lo_tone, -- instantiate wailing siren
			hi_pitch => hi_tone, 
			wspeed => wail_speed, 
			wclk => slo_clk,
			kval => kpr_value, 
			sw => SWR,
			audio_clk => audio_clk, 
			audio_data => data_R
		);
		w2 : wail
		PORT MAP(
			lo_pitch => lo_tone, -- instantiate wailing siren
			hi_pitch => hi_tone, 
			wspeed => wail_speed, 
			wclk => slo_clk,
			kval => kpl_value, 
			sw => SWL,
			audio_clk => audio_clk, 
			audio_data => data_L
		);
END Behavioral;
