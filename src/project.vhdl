library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tt_um_aromo613harwo861hamse755arvno337 is
    port (
        ui_in   : in  std_logic_vector(7 downto 0); -- 3 till 0 minsta är kypd_rows
        uo_out  : out std_logic_vector(7 downto 0); -- bit 6 är display_data, bit 5 är display_cs, bit 4 är display_clk, 3 till 0 minsta är kypd_cols
        uio_in  : in  std_logic_vector(7 downto 0);
        uio_out : out std_logic_vector(7 downto 0);
        uio_oe  : out std_logic_vector(7 downto 0);

        ena     : in  std_logic;
        clk     : in  std_logic;
        rst_n   : in  std_logic
    );
end tt_um_aromo613harwo861hamse755arvno337;

architecture Behavioral of tt_um_aromo613harwo861hamse755arvno337 is


component drawer
    port (
        clk : in std_logic;
        data_in : in std_logic_vector(15 downto 0);
        rst_n : in std_logic;
        data_out : out std_logic;
        cs : out std_logic
    );
end component;

component PmodKYPD
    port (
        clk      : in  std_logic;                      -- system clock
        rst    : in  std_logic;
        row     : in  std_logic_vector(3 downto 0);  -- ROW1–ROW4
        col     : out std_logic_vector(3 downto 0);  -- COL1–COL4
        key : out std_logic_vector(3 downto 0);  -- hex value 0–F
        strobe : out std_logic                      -- high when a key is
    );
end component;

    signal input : std_logic_vector(3 downto 0);
    signal strobe : std_logic := '0';
    signal prev_strobe : std_logic;
    signal grid : std_logic_vector(15 downto 0) := "0110011001100110";

begin
    uo_out(4) <= clk;
    main_drawer : drawer
        port map (
            clk => clk,
            data_in => grid,
            rst_n => rst_n,
            data_out => uo_out(6),
            cs => uo_out(5)
        );
    
    main_KYPD_encoder : PmodKYPD
        port map (
            clk => clk,
            rst => rst_n,
            row => ui_in(3 downto 0),
            col => uo_out(3 downto 0),
            key => input,
            strobe => strobe
        );

    process(clk, rst_n)
    begin
        if rst_n = '1' then
            grid <= (others => '0');
        elsif rising_edge(clk) then
            prev_strobe <= strobe;

            if strobe = '1' and prev_strobe = '0' then
                case input is
                    
                    -- 1st row
                    when "0000" => grid <= grid xor (
                        "1100" &
                        "1100" &
                        "0000" &
                        "0000"  
                    );
                    when "0001" => grid <= grid xor (
                        "1110" &
                        "1110" &
                        "0000" &
                        "0000"  
                    );
                    when "0010"  => grid <= grid xor (
                        "0111" &
                        "0111" &
                        "0000" &
                        "0000"  
                    );
                    when "0011" => grid <= grid xor (
                        "0011" &
                        "0011" &
                        "0000" &
                        "0000"  
                    );

                    -- 2nd row
                    when "0100" => grid <= grid xor (
                        "1100" &
                        "1100" &
                        "1100" &
                        "0000"  
                    );
                    when "0101" => grid <= grid xor (
                        "1110" &
                        "1110" &
                        "1110" &
                        "0000"  
                    );
                    when "0110" => grid <= grid xor (
                        "0111" &
                        "0111" &
                        "0111" &
                        "0000"  
                    );
                    when "0111" => grid <= grid xor (
                        "0011" &
                        "0011" &
                        "0011" &
                        "0000"  
                    );

                    -- 3rd row
                    when "1000" => grid <= grid xor (
                        "0000" &
                        "1100" &
                        "1100" &
                        "1100"  
                    );
                    when "1001" => grid <= grid xor (
                        "0000" &
                        "1110" &
                        "1110" &
                        "1110"  
                    );
                    when "1010" => grid <= grid xor (
                        "0000" &
                        "0111" &
                        "0111" &
                        "0111"  
                    );
                    when "1011" => grid <= grid xor (
                        "0000" &
                        "0011" &
                        "0011" &
                        "0011"  
                    );

                    -- 4th row
                    when "1100" => grid <= grid xor (
                        "0000" &
                        "0000" &
                        "1100" &
                        "1100"  
                    );
                    when "1101" => grid <= grid xor (
                        "0000" &
                        "0000" &
                        "1110" &
                        "1110"  
                    );
                    when "1110" => grid <= grid xor (
                        "0000" &
                        "0000" &
                        "0111" &
                        "0111"  
                    );
                    when "1111" => grid <= grid xor (
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