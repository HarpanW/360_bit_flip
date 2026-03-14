-- PmodKYPD
-- Decoder for hex keyboard, with strobe output.
-- Board: Nexys3 @ 100MHz
-- Description: Key value and strobe is generated every 5 ms.
-- 	During the first 4 ms keypad is scanned.
-- Author: andni65
-- Date: 2022-05-27

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PmodKYPD is
	port(
		clk : in std_logic;
		rst	: in std_logic;
		row : in std_logic_vector(3 downto 0);
		col : out std_logic_vector(3 downto 0);
		key : out std_logic_vector(3 downto 0);
		strobe : out std_logic
		);
end;

architecture func of PmodKYPD is
	
	signal timer : unsigned(19 downto 0);
	constant time1 : unsigned(19 downto 0) := "00011000011010100000";	-- 1 ms
	constant time2 : unsigned(19 downto 0) := "00110000110101000000";	-- 2 ms
	constant time3 : unsigned(19 downto 0) := "01001001001111100000";	-- 3 ms
	constant time4 : unsigned(19 downto 0) := "01100001101010000000";	-- 4 ms
	constant time5 : unsigned(19 downto 0) := "01111010000100100000";	-- 5 ms
	constant delay : unsigned(19 downto 0) := "00000000000001100100";	-- 1 us

	signal scan : std_logic;
	signal col_i : std_logic_vector(3 downto 0);
	signal key_i : std_logic_vector(4 downto 0);	-- key_i(4) indicates key pressed during scan
		
begin

	-- timer 
	process(clk)
	begin
		if rising_edge(clk) then
			if ((rst = '1') or (timer = time5 + delay)) then
				timer <= (others => '0');
			else
				timer <= timer + 1;
			end if;
		end if;
	end process;
		
	-- col
	process(clk)
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				col_i <= "1111";
			else
				if (timer = time1) then
					col_i <= "0111";
				elsif (timer = time2) then
					col_i <= "1011";
				elsif (timer = time3) then
					col_i <= "1101";
				elsif (timer = time4) then
					col_i <= "1110";
				elsif (timer = time5) then
					col_i <= "1111";
				end if;
			end if;
		end if;
	end process;

	col <= col_i;
		
	-- scan
	scan <= '1' when ((timer = time1 + delay) or
					  (timer = time2 + delay) or
					  (timer = time3 + delay) or
					  (timer = time4 + delay) or
					  (timer = time5 + delay)) else
			'0';
		
	-- key and strobe
	process(clk)
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				key_i <= "00000";
				strobe <= '0';
			else
				if (scan = '1') then
					if (col_i = "0111") then		-- col 1
						if (row = "0111") then		-- row 1
							key_i <= "10001";				-- key 1
						elsif (row = "1011") then	-- row 2
							key_i <= "10100";				-- key 4
						elsif (row = "1101") then	-- row 3
							key_i <= "10111";				-- key 7
						elsif (row = "1110") then	-- row 4
							key_i <= "10000";				-- key 0
						end if;
					elsif (col_i = "1011") then	-- col 2
						if (row = "0111") then		-- row 1
							key_i <= "10010";				-- key 2
						elsif (row = "1011") then	-- row 2
							key_i <= "10101";				-- key 5
						elsif (row = "1101") then	-- row 3
							key_i <= "11000";				-- key 8
						elsif (row = "1110") then	-- row 4
							key_i <= "11111";				-- key F
						end if;
					elsif (col_i = "1101") then	-- col 3
						if (row = "0111") then		-- row 1
							key_i <= "10011";				-- key 3
						elsif (row = "1011") then	-- row 2
							key_i <= "10110";				-- key 6
						elsif (row = "1101") then	-- row 3
							key_i <= "11001";				-- key 9
						elsif (row = "1110") then	-- row 4
							key_i <= "11110";				-- key E
						end if;
					elsif (col_i = "1110") then	-- col 4
						if (row = "0111") then		-- row 1
							key_i <= "11010";				-- key A
						elsif (row = "1011") then	-- row 2
							key_i <= "11011";				-- key B
						elsif (row = "1101") then	-- row 3
							key_i <= "11100";				-- key C
						elsif (row = "1110") then	-- row 4
							key_i <= "11101";				-- key D
						end if;
					elsif (col_i = "1111") then	-- no column
						if (key_i(4) = '1') then	-- key pressed during scan?
							strobe <= '1';
						else
							strobe <= '0';
						end if;
						key <= key_i(3 downto 0);	-- output key value
						key_i(4) <= '0';			-- clear key pressed
					end if;
				end if;
			end if;
		end if;
	end process;
	
end;