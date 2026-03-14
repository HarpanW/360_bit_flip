library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity KYPD_encoder is
    Port (
        clk      : in  std_logic;                      -- system clock
        reset    : in  std_logic;
        rows     : in  std_logic_vector(3 downto 0);  -- ROW1–ROW4
        cols     : out std_logic_vector(3 downto 0);  -- COL1–COL4
        key_code : out std_logic_vector(3 downto 0);  -- hex value 0–F
        key_valid: out std_logic                      -- high when a key is detected
    );
end KYPD_encoder;

architecture Behavioral of KYPD_encoder is
    type col_state_type is (C0, C1, C2, C3);
    signal col_state : col_state_type := C0;

    signal debounce_cnt : unsigned(19 downto 0) := (others => '0');
    constant debounce_max : unsigned(19 downto 0) := to_unsigned(500000, 20); -- ~10ms @ 50MHz

    signal key_detected : std_logic := '0';
    signal key_raw      : std_logic_vector(3 downto 0);
begin

    -- MUXA COLUMN SCANNING

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                col_state <= C0;
            else
                case col_state is
                    when C0 => col_state <= C1;
                    when C1 => col_state <= C2;
                    when C2 => col_state <= C3;
                    when others => col_state <= C0;
                end case;
            end if;
        end if;
    end process;

    with col_state select 
        cols <= "1110" when C0,
                "1101" when C1,
                "1011" when C2,
                "0111" when C3;

    -- Read rows and map to hex keypad value

    process(col_state, rows)
    begin
        key_raw <= "1111";  -- default = no key

        case col_state is
            when C0 =>  -- Column 0 active
                case rows is
                    when "1110" => key_raw <= "0000"; -- 0
                    when "1101" => key_raw <= "0100"; -- 4
                    when "1011" => key_raw <= "1000"; -- 8
                    when "0111" => key_raw <= "1100"; -- 12
                    when others => null;
                end case;

            when C1 =>  -- Column 1 active
                case rows is
                    when "1110" => key_raw <= "0001"; -- 1
                    when "1101" => key_raw <= "0101"; -- 5
                    when "1011" => key_raw <= "1001"; -- 9
                    when "0111" => key_raw <= "1101"; -- 13
                    when others => null;
                end case;

            when C2 =>  -- Column 2 active
                case rows is
                    when "1110" => key_raw <= "0010"; -- 2
                    when "1101" => key_raw <= "0110"; -- 6
                    when "1011" => key_raw <= "1010"; -- 10
                    when "0111" => key_raw <= "1110"; -- 14
                    when others => null;
                end case;

            when C3 =>  -- Column 3 active
                case rows is
                    when "1110" => key_raw <= "0011"; -- 3
                    when "1101" => key_raw <= "0111"; -- 7
                    when "1011" => key_raw <= "1011"; -- 11
                    when "0111" => key_raw <= "1111"; -- 15
                    when others => null;
                end case;
        end case;
    end process;


    --------------------------------------------------------------------
    -- DEBOUNCE LOGIC
    --------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                debounce_cnt <= (others => '0');
                key_detected <= '0';
            else
                if key_raw /= "1111" then
                    if debounce_cnt < debounce_max then
                        debounce_cnt <= debounce_cnt + 1;
                    else
                        key_detected <= '1';
                    end if;
                else
                    debounce_cnt <= (others => '0');
                    key_detected <= '0';
                end if;
            end if;
        end if;
    end process;

    key_code  <= key_raw;
    key_valid <= key_detected;


end Behavioral;