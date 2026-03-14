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
    signal init     : std_logic_vector (1 downto 0) := "11";


    procedure shift_data(
        signal   counter   : inout integer;
        signal   word      : inout std_logic_vector(15 downto 0);
        signal   data_bit  : out   std_logic;
        signal   get_next  : out   std_logic
    ) is
    begin
        if counter = 15 then
            get_next <= '1';
        end if;
        counter <= counter + 1; -- Overflows
        cs <= '1';

        -- Skifta ut MSB
        data_bit <= word(15);
        word <= word(14 downto 0) & '0';
    end procedure;

begin
    -- Game loop
    -- Get output (fixa alla 16 bitar direkt)
    -- Skifta ut dem 
    -- Skicka CS
    -- repeat

        

    process(clk)
    begin
    if rst_n = '1' then
        curr_word <= (others => '0');
        cnt <= (others => '0');
        get_word <= '1';
        cs <= '1';
        init <= "11";
    end if;
    if rising_edge(clk) then
        if init = 3 then -- Subrutin för att slå på kretsen
            if cnt = 0 then
                curr_word <= x"0C01"; -- Slå på kretsen
            end if;
            shift_data(cnt, curr_word, data_out, init);

        
        elsif get_word = '1' then
            curr_word <= "0000" & std_logic_vector(unsigned(row) + 2)(3 downto 0) & "00" & data_in(unsigned(row)*4 + 3 downto unsigned(row)*4) & "00"; -- pro
            row <= row + 1; -- Overflows
            cs <= '0';
            get_word <= '0';
        else
            shift_data(cnt, curr_word, data_out, get_word);
        end if;
    end if;
    end process;

   
end Behavioral;