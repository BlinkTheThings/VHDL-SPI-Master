library ieee;
use ieee.std_logic_1164.all;

entity spi_master_tb is
end spi_master_tb;

architecture tb of spi_master_tb is
    component spi_master
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
    end component;

    signal i_clk        : std_logic;
    signal i_reset      : std_logic;

    signal i_enable     : std_logic;
    signal i_tx_data    : std_logic_vector (7 downto 0);
    signal o_rx_data    : std_logic_vector (7 downto 0);
    signal o_ready      : std_logic;

    signal o_cs         : std_logic;
    signal o_sclk       : std_logic;
    signal o_mosi       : std_logic;
    signal i_miso       : std_logic;

    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

    constant TbPeriod : time := 1000 ns;
begin
    dut : spi_master
    port map (
        i_clk       => i_clk,
        i_reset     => i_reset,
        i_enable    => i_enable,
        i_tx_data   => i_tx_data,
        o_rx_data   => o_rx_data,
        o_ready     => o_ready,
        o_cs        => o_cs,
        o_sclk      => o_sclk,
        o_mosi      => o_mosi,
        i_miso      => i_miso
    );

    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    i_clk <= TbClock;

    process
    begin
        i_miso <= '1';
        i_tx_data <= x"A5";

        i_reset <= '1';
        wait for 2 * TbPeriod;
        i_reset <= '0';

        i_enable <= '0';
        wait for 2 * TbPeriod;
        i_enable <= '1';
        wait for TbPeriod;
        i_enable <= '0';

        wait for 100 * TbPeriod;

        TbSimEnded <= '1';
        wait;
    end process;

end tb;