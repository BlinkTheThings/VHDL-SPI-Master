library ieee;
use ieee.std_logic_1164.all;

entity spi_master is
    port (
        i_clk       : in    std_logic;
        i_reset     : in    std_logic;

        i_enable    : in    std_logic;
        i_tx_data   : in    std_logic_vector (7 downto 0);
        o_rx_data   : out   std_logic_vector (7 downto 0);
        o_ready     : out   std_logic;

        o_cs        : out   std_logic;
        o_sclk      : out   std_logic;
        o_mosi      : out   std_logic;
        i_miso      : in    std_logic
    );
end spi_master;

architecture behavior of spi_master is
    type state_type is (s0, s1, s2, s3, s4);

    signal r_ps, r_ns : state_type;

    signal r_tx_data : std_logic_vector (7 downto 0);
    signal r_rx_data : std_logic_vector (7 downto 0);
    signal r_bit_cnt : integer;

    signal r_tx_data_in : std_logic_vector (7 downto 0);
    signal r_rx_data_in : std_logic_vector (7 downto 0);
    signal r_bit_cnt_in : integer;
begin

    process (i_clk, i_reset, r_ns)
    begin
        if i_reset = '1' then
            r_ps <= s0;
        elsif rising_edge(i_clk) or falling_edge(i_clk) then
            r_ps <= r_ns;

            r_tx_data <= r_tx_data_in;
            r_rx_data <= r_rx_data_in;
            r_bit_cnt <= r_bit_cnt_in;
        end if;
    end process;

    process (r_ps, i_enable)
    begin
        case r_ps is
            when s0 =>
                o_cs <= '1';
                o_sclk <= '1';
                o_mosi <= '0';
                o_ready <= '0';
                o_rx_data <= (others => '0');
                r_ns <= s1;
            when s1 =>
                if i_enable = '1' then
                    o_cs <= '0';
                    o_ready <= '0';
                    r_ns <= s2;

                    r_tx_data_in <= i_tx_data;
                    r_rx_data_in <= (others => '0');
                    r_bit_cnt_in <= 0;
                end if;
            when s2 =>
                    o_sclk <= '0';
                    o_mosi <= r_tx_data(7);
                    r_ns <= s3;

                    r_tx_data_in(7 downto 1) <= r_tx_data(6 downto 0);
            when s3 =>
                    o_sclk <= '1';

                    if r_bit_cnt_in = 7 then
                        r_ns <= s4;
                    else
                        r_ns <= s2;
                    end if;

                    r_rx_data_in(7 downto 1) <= r_rx_data(6 downto 0);
                    r_rx_data_in(0) <= i_miso;
                    r_bit_cnt_in <= r_bit_cnt + 1;
            when s4 =>
                    o_cs <= '1';
                    o_sclk <= '1';
                    o_mosi <= '0';
                    o_rx_data <= r_rx_data;
                    o_ready <= '1';
                    r_ns <= s1;
            when others =>
                    r_ns <= s0;
        end case;
    end process;

end behavior;