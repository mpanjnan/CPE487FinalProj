LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Generates a "wailing siren" sound by instancing a "tone" module and modulating
-- the pitch of the tone. The pitch is increased until it reaches hi_pitch and then
-- decreased until it reaches lo_pitch and then increased again, etc.
ENTITY wail IS
	PORT (
		lo_pitch : IN UNSIGNED (13 DOWNTO 0); -- lowest pitch (in units of 0.745 Hz)
		hi_pitch : IN UNSIGNED (13 DOWNTO 0); -- highest pitch (in units of 0.745 Hz)
		wspeed : IN UNSIGNED (7 DOWNTO 0); -- speed of wail in pitch units/wclk
		wclk : IN STD_LOGIC; -- wailing clock (47.6 Hz)
		kval : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		sw : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		audio_clk : IN STD_LOGIC; -- audio sampling clock (48.8 kHz)
	audio_data : OUT SIGNED (15 DOWNTO 0)); -- output audio sequence (wailing tone)
END wail;

ARCHITECTURE Behavioral OF wail IS
	COMPONENT tone IS
		PORT (
			clk : IN STD_LOGIC;
			pitch : IN UNSIGNED (13 DOWNTO 0);
			data : OUT SIGNED (15 DOWNTO 0)
		);
	END COMPONENT;
	SIGNAL curr_pitch : UNSIGNED (13 DOWNTO 0); -- current wailing pitch
	SIGNAL mult : INTEGER := 1;
BEGIN
	-- this process modulates the current pitch. It keep a variable updn to indicate
	-- whether tone is currently rising or falling. Each wclk period it increments
	-- (or decrements) the current pitch by wspeed. When it reaches hi_pitch, it
	-- starts counting down. When it reaches lo_pitch, it starts counting up
	wp : PROCESS
		VARIABLE updn : std_logic;
	BEGIN
		WAIT UNTIL rising_edge(wclk);
		
		IF sw = "00" THEN
		  mult <= 1;
		ELSIF sw = "01" THEN
		  mult <= 2;
	    ELSIF sw = "10" THEN
	      mult <= 4;
	    ELSE
	      mult <= 8;
	    END IF;
		
		
		IF kval = X"1" THEN
		  curr_pitch <= to_unsigned (148*mult, 14);
		ELSIF kval = X"2" THEN
		  curr_pitch <= to_unsigned (156*mult, 14);
	    ELSIF kval = X"3" THEN
		  curr_pitch <= to_unsigned (166*mult, 14);
		ELSIF kval = X"4" THEN
		  curr_pitch <= to_unsigned (176*mult, 14);
	    ELSIF kval = X"5" THEN
		  curr_pitch <= to_unsigned (186*mult, 14);
		ELSIF kval = X"6" THEN
		  curr_pitch <= to_unsigned (197*mult, 14);
		ELSIF kval = X"7" THEN
		  curr_pitch <= to_unsigned (209*mult, 14);
		ELSIF kval = X"8" THEN
		  curr_pitch <= to_unsigned (221*mult, 14);
		ELSIF kval = X"9" THEN
		  curr_pitch <= to_unsigned (234*mult, 14);
		ELSIF kval = X"A" THEN
		  curr_pitch <= to_unsigned (248*mult, 14);
		ELSIF kval = X"B" THEN
		  curr_pitch <= to_unsigned (263*mult, 14);
		ELSIF kval = X"C" THEN
		  curr_pitch <= to_unsigned (279*mult, 14);
		ELSE
		  curr_pitch <= to_unsigned (0, 14);
		END IF;
				
	END PROCESS;
	tgen : tone
	PORT MAP(
		clk => audio_clk, -- instance a tone module
		pitch => curr_pitch, -- use curr-pitch to modulate tone
		data => audio_data
		);
END Behavioral;
