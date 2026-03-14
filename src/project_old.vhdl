library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tt_um_example is
    port (
        output_grid  : out std_logic_vector(15 downto 0);
        col     : out std_logic_vector(3 downto 0);
        row     : in std_logic_vector(3 downto 0);
        clk     : in  std_logic;
        rst_n   : in  std_logic
    );
end tt_um_example;

architecture Behavioral of tt_um_example is

signal col_counter_count : unsigned(17 downto 0) := 0; -- 1ms x 100MHz = 0.1M < 2^18
signal col_counter : unsigned(1 downto 0) := 0;
signal col_signal : std_logic_vector(3 downto 0) := (others => '0'); 

signal pressed : std_logic := '0';

signal grid : std_logic_vector(15 downto 0) := (others => '0');


begin
    output_grid <= grid;
    col <= col_signal;

    with col_counter select
            col_signal <= "1000" when "00",
                        "0100" when "01",
                        "0010" when "10",
                        "0001" when others;

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            grid <= (others => '0');
            pressed <= '0';
        elsif rising_edge(clk) then
            col_counter_count <= col_counter_count + 1;
            if col_counter_count > 100000 then -- ~1ms
                col_counter <= col_counter + 1;
                col_counter_count <= 0;
            end if;
            
            if row = "0000" then
                pressed <= '0'; 
            elsif pressed = '0' then -- (else?)
                case row & col_signal is
                    
                    -- 1st row
                    when "1000" & "1000" => grid <= grid xor (
                        "1100" &
                        "1100" &
                        "0000" &
                        "0000"  
                    );
                    when "1000" & "0100" => grid <= grid xor (
                        "1110" &
                        "1110" &
                        "0000" &
                        "0000"  
                    );
                    when "1000" & "0010" => grid <= grid xor (
                        "0111" &
                        "0111" &
                        "0000" &
                        "0000"  
                    );
                    when "1000" & "0001" => grid <= grid xor (
                        "0011" &
                        "0011" &
                        "0000" &
                        "0000"  
                    );

                    -- 2nd row
                    when "0100" & "1000" => grid <= grid xor (
                        "1100" &
                        "1100" &
                        "1100" &
                        "0000"  
                    );
                    when "0100" & "0100" => grid <= grid xor (
                        "1110" &
                        "1110" &
                        "1110" &
                        "0000"  
                    );
                    when "0100" & "0010" => grid <= grid xor (
                        "0111" &
                        "0111" &
                        "0111" &
                        "0000"  
                    );
                    when "0100" & "0001" => grid <= grid xor (
                        "0011" &
                        "0011" &
                        "0011" &
                        "0000"  
                    );

                    -- 3rd row
                    when "0010" & "1000" => grid <= grid xor (
                        "0000" &
                        "1100" &
                        "1100" &
                        "1100"  
                    );
                    when "0010" & "0100" => grid <= grid xor (
                        "0000" &
                        "1110" &
                        "1110" &
                        "1110"  
                    );
                    when "0010" & "0010" => grid <= grid xor (
                        "0000" &
                        "0111" &
                        "0111" &
                        "0111"  
                    );
                    when "0010" & "0001" => grid <= grid xor (
                        "0000" &
                        "0011" &
                        "0011" &
                        "0011"  
                    );

                    -- 4th row
                    when "0001" & "1000" => grid <= grid xor (
                        "0000" &
                        "0000" &
                        "1100" &
                        "1100"  
                    );
                    when "0001" & "0100" => grid <= grid xor (
                        "0000" &
                        "0000" &
                        "1110" &
                        "1110"  
                    );
                    when "0001" & "0010" => grid <= grid xor (
                        "0000" &
                        "0000" &
                        "0111" &
                        "0111"  
                    );
                    when "0001" & "0001" => grid <= grid xor (
                        "0000" &
                        "0000" &
                        "0011" &
                        "0011"  
                    );

                    when others => null;
                end case;
            end if;
        end if;
    end process;

end Behavioral;