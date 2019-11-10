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

architecture rtl of spi_master is
    type state_type is (s0, s1, s2, s3);
    type reg_type is record
        enable  : std_logic;
        tx_data : std_logic_vector (7 downto 0);
        rx_data : std_logic_vector (7 downto 0);
        ready   : std_logic;
        cs      : std_logic;
        sclk    : std_logic;
        mosi    : std_logic;
        state   : state_type;
        bit_cnt : integer;
    end record;

    signal r, rin : reg_type;
begin

    sync : process (i_clk, i_reset)
    begin
        if i_reset = '1' then
            r.enable <= '0';
            r.tx_data <= (others => '0');
            r.rx_data <= (others => '0');
            r.ready <= '0';
            r.cs <= '1';
            r.sclk <= '1';
            r.mosi <= '0';
            r.state <= s0;
            r.bit_cnt <= 0;
        elsif rising_edge(i_clk) then
            r <= rin;
        end if;
    end process;

    comb : process (i_miso, i_enable, r)
        variable v : reg_type;
    begin
        v := r;

        v.enable := i_enable;

        case r.state is
            when s0 =>
                if r.enable = '1' then
                    v.cs := '0';
                    v.ready := '0';
                    v.tx_data := i_tx_data;
                    v.rx_data := (others => '0');
                    v.bit_cnt := 0;
                    v.state := s1;
                end if;
            when s1 =>
                v.sclk := '0';
                v.mosi := r.tx_data(7);
                v.tx_data(7 downto 1) := r.tx_data(6 downto 0);
                v.state := s2;
            when s2 =>
                v.sclk := '1';
                v.rx_data(7 downto 1) := r.rx_data(6 downto 0);
                v.rx_data(0) := i_miso;
                v.bit_cnt := r.bit_cnt + 1;
                if r.bit_cnt = 7 then
                    v.state := s3;
                else
                    v.state := s1;
                end if;
            when s3 =>
                v.cs := '1';
                v.sclk := '1';
                v.mosi := '0';
                v.ready := '1';
                v.state := s0;
            when others =>
                v.enable := '0';
                v.tx_data := (others => '0');
                v.rx_data := (others => '0');
                v.ready := '0';
                v.cs := '1';
                v.sclk := '1';
                v.mosi := '0';
                v.bit_cnt := 0;
                v.state := s0;
        end case;

        rin <= v;

        if r.ready = '1' then
            o_rx_data <= r.rx_data;
        else
            o_rx_data <= (others => '0');
        end if;

        o_ready <= r.ready;
        o_sclk <= r.sclk;
        o_cs <= r.cs;
        o_mosi <= r.mosi;
    end process;

end rtl;