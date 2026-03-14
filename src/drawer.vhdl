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
    signal row : unsigned (1 downto 0);
    signal cnt : unsigned (3 downto 0);
    signal curr_word : std_logic_vector (15 downto 0);
    signal get_word : std_logic := '1';
    signal init     : unsigned (2 downto 0) := "100";



begin
    -- Game loop
    -- Get output (fixa alla 16 bitar direkt)
    -- Skifta ut dem 
    -- Skicka CS
    -- repeat

        

    process(clk, rst_n)
    begin
    if rst_n = '1' then
        curr_word <= (others => '0');
        cnt <= (others => '0');
        get_word <= '1';
        cs <= '1'; 
        row <= "00";
        init <= "100";
        data_out <= '0';

    end if;
    if rising_edge(clk) then
        
        if get_word = '1' then
            cs <= '0';
            get_word <= '0';
            cnt <= (others => '0');
            -- ONLY RUNS WHEN INITIALISING THE SCREEN
            if init = 4 then 
                curr_word <= x"0C01"; -- Slå på kretsen
                init <= init - 1;
            elsif init = 3 then 
                curr_word <= x"0B07"; -- Ange att 8 siffror används
                init <= init - 1;
            elsif init = 2 then
                curr_word <= x"0900"; -- Vi anger varje pixel manuellt (Oklart)
                init <= init - 1;
            elsif init = 1 then 
                curr_word <= x"0A0F"; -- Maximal ljusstyrka
                init <= init - 1;
            
            -- Normal game loop, above is init
            else  
                curr_word <= "0000" & std_logic_vector(row + 2)(3 downto 0) & "00" & data_in(row*4 + 3 downto row*4) & "00"; -- pro
                row <= row + 1; -- Overflows
            end if;
        else
            -- Skiftregister
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