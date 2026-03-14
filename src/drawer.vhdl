library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity drawer is
    port (
        data_in     : in  std_logic_vector(15 downto 0); -- Game logic vector (spelbrädet av 4x4 bitar)
        clk         : in std_logic;     
        rst_n         : in std_logic;
        data_out       : out std_logic; -- Seriellt, men ska skickas i paket av 16
        cs          : out std_logic     -- För att säga att vi har skickat 16 bitar (Aktivt låg ?Kanske?)
    );
end drawer;

architecture Behavioral of drawer is
    signal row : std_logic_vector (1 downto 0);
    signal cnt : std_logic_vector (3 downto 0);
    signal curr_word : std_logic_vector (15 downto 0);
    signal get_word : std_logic;
begin
    -- Game loop
    -- Get output (fixa alla 16 bitar direkt)
    -- Skifta ut dem 
    -- Skicka CS
    -- repeat
    process(clk)
    begin
    if rising_edge(clk) then
        if rst_n = '1' then
            curr_word <= (others => '0');
            cnt <= (others => '0');
            get_word <= '1';
            cs <= '1';
        elsif get_word = '1' then
            curr_word <= "0000" & std_logic_vector(unsigned(row) + 2)(3 downto 0) & "00" & data_in(unsigned(row)*4 + 3 downto unsigned(row)*4) & "00"; -- pro
            row <= row + 1; -- Overflows
            cs <= '0';
            get_word <= '0';
        else
            if cnt = 15 then
                get_word <= '1';
            end if;
            cnt <= cnt + 1; -- Overflows
            cs <= '1';

            -- Skifta ut MSB
            data_out <= curr_word(15);
            curr_word <= curr_word(14 downto 0) & '0';
        end if;
    end if;
    end process;

   
end Behavioral;