-- Copyright (c) 2011-2020 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0

------------------------------------------------------------------------------
-- ESP top-level design connecting CHIP instance with FPGA proxy for testing
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.esp_global.all;
use work.grlib_config.all;
use work.socmap.all;

entity top is
  generic (
    SIMULATION : boolean                               := false;
    CLUSTER_EN : boolean                               := true;
    JTAG_TRACE : integer range -1 to CFG_TILES_NUM - 1 := -1);
  port (
    reset             : in    std_logic;
    clk_div_noc       : out   std_logic;
    clk_div           : out   std_logic_vector(0 to CFG_TILES_NUM - 1);  -- tile clock monitor for testing purposes
    -- Ethernet signals
    reset_o2          : out   std_ulogic;
    etx_clk           : in    std_ulogic;
    erx_clk           : in    std_ulogic;
    erxd              : in    std_logic_vector(3 downto 0);
    erx_dv            : in    std_ulogic;
    erx_er            : in    std_ulogic;
    erx_col           : in    std_ulogic;
    erx_crs           : in    std_ulogic;
    etxd              : out   std_logic_vector(3 downto 0);
    etx_en            : out   std_ulogic;
    etx_er            : out   std_ulogic;
    emdc              : out   std_ulogic;
    emdio_i           : in    std_logic; --for chip with no pads to remove inouts
    emdio_o           : out   std_logic; --DO NOT USE for real ethernet implementation

    -- UART
    uart_rxd          : in    std_logic;   -- UART1_RX (u1i.rxd)
    uart_txd          : out   std_logic;   -- UART1_TX (u1o.txd)
    uart_ctsn         : in    std_logic;   -- UART1_RTSN (u1i.ctsn)
    uart_rtsn         : out   std_logic;   -- UART1_RTSN (u1o.rtsn)
    -- FPGA proxy Ethernet interface
    fpga_reset_o2     : out   std_ulogic;
    fpga_etx_clk      : in    std_ulogic;
    fpga_erx_clk      : in    std_ulogic;
    fpga_erxd         : in    std_logic_vector(3 downto 0);
    fpga_erx_dv       : in    std_ulogic;
    fpga_erx_er       : in    std_ulogic;
    fpga_erx_col      : in    std_ulogic;
    fpga_erx_crs      : in    std_ulogic;
    fpga_etxd         : out   std_logic_vector(3 downto 0);
    fpga_etx_en       : out   std_ulogic;
    fpga_etx_er       : out   std_ulogic;
    fpga_emdc         : out   std_ulogic;
    fpga_emdio        : inout std_logic;
    -- DDR0
    c0_sys_clk_p      : in    std_logic;
    c0_sys_clk_n      : in    std_logic;
    c0_ddr4_act_n     : out   std_logic;
    c0_ddr4_adr       : out   std_logic_vector(16 downto 0);
    c0_ddr4_ba        : out   std_logic_vector(1 downto 0);
    c0_ddr4_bg        : out   std_logic_vector(1 downto 0);
    c0_ddr4_cke       : out   std_logic_vector(1 downto 0);
    c0_ddr4_odt       : out   std_logic_vector(1 downto 0);
    c0_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
    c0_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
    c0_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
    c0_ddr4_reset_n   : out   std_logic;
    c0_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
    c0_ddr4_dq        : inout std_logic_vector(71 downto 0);
    c0_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
    c0_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
    c0_calib_complete : out   std_logic;
    c0_diagnostic_led : out   std_ulogic;
    -- FPGA proxy main clock
    main_clk_p        : in    std_ulogic;
    main_clk_n        : in    std_ulogic;
    -- FPGA proxy LEDs
    LED_RED           : out   std_ulogic;
    LED_GREEN         : out   std_ulogic;
    LED_BLUE          : out   std_ulogic;
    LED_YELLOW        : out   std_ulogic
    );
end;


architecture rtl of top is

  -----------------------------------------------------------------------------
  -- ESP chip specific instance
  -----------------------------------------------------------------------------
  component ASIC_3x3_TOP is
    generic (
      CLUSTER_EN : boolean;
      SIMULATION : boolean);
    port (
      reset           : in    std_logic;
      ext_clk_noc     : in    std_logic;
      ext_clk_io      : in    std_logic;
      ext_clk_cpu     : in    std_logic;
      ext_clk_mem     : in    std_logic;
      clk_div_noc     : out   std_logic;
      clk_div_io      : out   std_logic;
      clk_div_cpu     : out   std_logic;
      clk_div_mem     : out   std_logic;
      fpga_data       : inout std_logic_vector(64 - 1 downto 0);
      fpga_valid_in   : in    std_logic_vector(0 downto 0);
      fpga_valid_out  : out   std_logic_vector(0 downto 0);
      fpga_clk_in     : in    std_logic_vector(0 downto 0);
      fpga_clk_out    : out   std_logic_vector(0 downto 0);
      fpga_credit_in  : in    std_logic_vector(0 downto 0);
      fpga_credit_out : out   std_logic_vector(0 downto 0);
      tdi_cpu         : in    std_logic;
      tdi_io          : in    std_logic;
      tdi_mem         : in    std_logic;
      tdo_cpu         : out   std_logic;
      tdo_io          : out   std_logic;
      tdo_mem         : out   std_logic;
      tms             : in    std_logic;
      tclk            : in    std_logic;
      reset_o2        : out   std_ulogic;
      etx_clk         : in    std_ulogic;
      erx_clk         : in    std_ulogic;
      erxd            : in    std_logic_vector(3 downto 0);
      erx_dv          : in    std_ulogic;
      erx_er          : in    std_ulogic;
      erx_col         : in    std_ulogic;
      erx_crs         : in    std_ulogic;
      etxd            : out   std_logic_vector(3 downto 0);
      etx_en          : out   std_ulogic;
      etx_er          : out   std_ulogic;
      emdc            : out   std_ulogic;
      emdio_i           : in std_logic;      
      emdio_o           : out std_logic;
      uart_rxd        : in    std_logic;
      uart_txd        : out   std_logic;
      uart_ctsn       : in    std_logic;
      uart_rtsn       : out   std_logic;
      ivr_pmb_dat     : in    std_ulogic;
      ivr_pmb_clk     : in    std_ulogic;
      ivr_avs_clk     : in    std_ulogic;
      ivr_avs_dat     : in    std_ulogic;
      ivr_avs_sdat    : in    std_ulogic;
      ivr_control     : in    std_ulogic;
      ivr_gpio        : in    std_logic_vector(3 downto 0);
      unused          : in    std_ulogic
      );
  end component ASIC_3x3_TOP;

  component fpga_proxy_top is
    generic (
      SIMULATION : boolean;
      JTAG_TRACE : integer range -1 to CFG_TILES_NUM - 1);
    port (
      reset             : in    std_ulogic;
      ext_clk_noc       : out   std_logic;
      ext_clk           : out   std_logic_vector(0 to CFG_TILES_NUM - 1);
      main_clk_p        : in    std_ulogic;
      main_clk_n        : in    std_ulogic;
      fpga_data         : inout std_logic_vector(CFG_NMEM_TILE * (ARCH_BITS) - 1 downto 0);
      fpga_valid_in     : out   std_logic_vector(0 to CFG_NMEM_TILE - 1);
      fpga_valid_out    : in    std_logic_vector(0 to CFG_NMEM_TILE - 1);
      fpga_clk_in       : out   std_logic_vector(0 to CFG_NMEM_TILE - 1);
      fpga_clk_out      : in    std_logic_vector(0 to CFG_NMEM_TILE - 1);
      fpga_credit_in    : out   std_logic_vector(0 to CFG_NMEM_TILE - 1);
      fpga_credit_out   : in    std_logic_vector(0 to CFG_NMEM_TILE - 1);
      tdi               : out   std_logic_vector(0 to CFG_TILES_NUM - 1);
      tdo               : in    std_logic_vector(0 to CFG_TILES_NUM - 1);
      tms               : out   std_logic;
      tclk              : out   std_logic;
      reset_o2          : out   std_ulogic;
      etx_clk           : in    std_ulogic;
      erx_clk           : in    std_ulogic;
      erxd              : in    std_logic_vector(3 downto 0);
      erx_dv            : in    std_ulogic;
      erx_er            : in    std_ulogic;
      erx_col           : in    std_ulogic;
      erx_crs           : in    std_ulogic;
      etxd              : out   std_logic_vector(3 downto 0);
      etx_en            : out   std_ulogic;
      etx_er            : out   std_ulogic;
      emdc              : out   std_ulogic;
      emdio             : inout std_logic;
      c0_sys_clk_p      : in    std_logic;
      c0_sys_clk_n      : in    std_logic;
      c0_ddr4_act_n     : out   std_logic;
      c0_ddr4_adr       : out   std_logic_vector(16 downto 0);
      c0_ddr4_ba        : out   std_logic_vector(1 downto 0);
      c0_ddr4_bg        : out   std_logic_vector(1 downto 0);
      c0_ddr4_cke       : out   std_logic_vector(1 downto 0);
      c0_ddr4_odt       : out   std_logic_vector(1 downto 0);
      c0_ddr4_cs_n      : out   std_logic_vector(1 downto 0);
      c0_ddr4_ck_t      : out   std_logic_vector(0 downto 0);
      c0_ddr4_ck_c      : out   std_logic_vector(0 downto 0);
      c0_ddr4_reset_n   : out   std_logic;
      c0_ddr4_dm_dbi_n  : inout std_logic_vector(8 downto 0);
      c0_ddr4_dq        : inout std_logic_vector(71 downto 0);
      c0_ddr4_dqs_c     : inout std_logic_vector(8 downto 0);
      c0_ddr4_dqs_t     : inout std_logic_vector(8 downto 0);
      c0_calib_complete : out   std_logic;
      c0_diagnostic_led : out   std_ulogic;
      LED_RED           : out   std_ulogic;
      LED_GREEN         : out   std_ulogic;
      LED_BLUE          : out   std_ulogic;
      LED_YELLOW        : out   std_ulogic);
  end component fpga_proxy_top;

  -- FPGA proxy memory link
  signal fpga_data       : std_logic_vector(CFG_NMEM_TILE * (ARCH_BITS) - 1 downto 0);
  signal fpga_valid_in   : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_valid_out  : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_clk_in     : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_clk_out    : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_credit_in  : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  signal fpga_credit_out : std_logic_vector(CFG_NMEM_TILE - 1 downto 0);
  -- Test interface
  signal tdi             : std_logic_vector(0 to CFG_TILES_NUM - 1);
  signal tdo             : std_logic_vector(0 to CFG_TILES_NUM - 1);
  signal tms             : std_logic;
  signal tclk            : std_logic;

  -- FPGA-genertated backup external clocks
  signal ext_clk_noc : std_logic;
  signal ext_clk     : std_logic_vector(0 to CFG_TILES_NUM - 1);  -- backup tile clock

  constant CPU_FREQ : integer := 78125;  -- cpu frequency in KHz
                                         -- (TODO: change for device tree)
begin

  -----------------------------------------------------------------------------
  -- Control FPGA
  -----------------------------------------------------------------------------

  fpga_proxy_top_i : fpga_proxy_top
    generic map (
      SIMULATION => SIMULATION,
      JTAG_TRACE => JTAG_TRACE)
    port map (
      reset             => reset,
      ext_clk_noc       => ext_clk_noc,
      ext_clk           => ext_clk,
      main_clk_p        => main_clk_p,
      main_clk_n        => main_clk_n,
      fpga_data         => fpga_data,
      fpga_valid_in     => fpga_valid_in,
      fpga_valid_out    => fpga_valid_out,
      fpga_clk_in       => fpga_clk_in,
      fpga_clk_out      => fpga_clk_out,
      fpga_credit_in    => fpga_credit_in,
      fpga_credit_out   => fpga_credit_out,
      tdi               => tdi,
      tdo               => tdo,
      tms               => tms,
      tclk              => tclk,
      reset_o2          => fpga_reset_o2,
      etx_clk           => fpga_etx_clk,
      erx_clk           => fpga_erx_clk,
      erxd              => fpga_erxd,
      erx_dv            => fpga_erx_dv,
      erx_er            => fpga_erx_er,
      erx_col           => fpga_erx_col,
      erx_crs           => fpga_erx_crs,
      etxd              => fpga_etxd,
      etx_en            => fpga_etx_en,
      etx_er            => fpga_etx_er,
      emdc              => fpga_emdc,
      emdio             => fpga_emdio,
      c0_sys_clk_p      => c0_sys_clk_p,
      c0_sys_clk_n      => c0_sys_clk_n,
      c0_ddr4_act_n     => c0_ddr4_act_n,
      c0_ddr4_adr       => c0_ddr4_adr,
      c0_ddr4_ba        => c0_ddr4_ba,
      c0_ddr4_bg        => c0_ddr4_bg,
      c0_ddr4_cke       => c0_ddr4_cke,
      c0_ddr4_odt       => c0_ddr4_odt,
      c0_ddr4_cs_n      => c0_ddr4_cs_n,
      c0_ddr4_ck_t      => c0_ddr4_ck_t,
      c0_ddr4_ck_c      => c0_ddr4_ck_c,
      c0_ddr4_reset_n   => c0_ddr4_reset_n,
      c0_ddr4_dm_dbi_n  => c0_ddr4_dm_dbi_n,
      c0_ddr4_dq        => c0_ddr4_dq,
      c0_ddr4_dqs_c     => c0_ddr4_dqs_c,
      c0_ddr4_dqs_t     => c0_ddr4_dqs_t,
      c0_calib_complete => c0_calib_complete,
      c0_diagnostic_led => c0_diagnostic_led,
      LED_RED           => LED_RED,
      LED_GREEN         => LED_GREEN,
      LED_BLUE          => LED_BLUE,
      LED_YELLOW        => LED_YELLOW);


  -----------------------------------------------------------------------------
  -- ESP chip
  -----------------------------------------------------------------------------

  -- Drive unused clock monitors and JTAG output pins
  unused_interface_gen : for i in 0 to CFG_TILES_NUM - 1 generate
    unused_ext_clk_io_gen : if i /= cpu_tile_id(0) and i /= io_tile_id and i /= mem_tile_id(0) generate
      clk_div(i) <= '0';
    end generate unused_ext_clk_io_gen;
    unused_td_io_gen : if i /= cpu_tile_id(0) and i /= io_tile_id and i /= mem_tile_id(0) generate
      tdo(i) <= '0';
    end generate unused_td_io_gen;
  end generate unused_interface_gen;

  chip_i : ASIC_3x3_TOP
    generic map (
      CLUSTER_EN => CLUSTER_EN,
      SIMULATION => SIMULATION)
    port map (
      reset           => reset,
      ext_clk_noc     => ext_clk_noc,
      ext_clk_io      => ext_clk(io_tile_id),
      ext_clk_cpu     => ext_clk(cpu_tile_id(0)),
      ext_clk_mem     => ext_clk(mem_tile_id(0)),
      clk_div_noc     => clk_div_noc,
      clk_div_io      => clk_div(io_tile_id),
      clk_div_cpu     => clk_div(cpu_tile_id(0)),
      clk_div_mem     => clk_div(mem_tile_id(0)),
      fpga_data       => fpga_data,
      fpga_valid_in   => fpga_valid_in,
      fpga_valid_out  => fpga_valid_out,
      fpga_clk_in     => fpga_clk_in,
      fpga_clk_out    => fpga_clk_out,
      fpga_credit_in  => fpga_credit_in,
      fpga_credit_out => fpga_credit_out,
      tdi_cpu         => tdi(cpu_tile_id(0)),
      tdi_io          => tdi(io_tile_id),
      tdi_mem         => tdi(mem_tile_id(0)),
      tdo_cpu         => tdo(cpu_tile_id(0)),
      tdo_io          => tdo(io_tile_id),
      tdo_mem         => tdo(mem_tile_id(0)),
      tms             => tms,
      tclk            => tclk,
      reset_o2        => reset_o2,
      etx_clk         => etx_clk,
      erx_clk         => erx_clk,
      erxd            => erxd,
      erx_dv          => erx_dv,
      erx_er          => erx_er,
      erx_col         => erx_col,
      erx_crs         => erx_crs,
      etxd            => etxd,
      etx_en          => etx_en,
      etx_er          => etx_er,
      emdc            => emdc,
      emdio_i         => emdio_i,
      emdio_o         => emdio_o,
      uart_rxd        => uart_rxd,
      uart_txd        => uart_txd,
      uart_ctsn       => uart_ctsn,
      uart_rtsn       => uart_rtsn,
      ivr_pmb_dat     => '0',
      ivr_pmb_clk     => '0',
      ivr_avs_clk     => '0',
      ivr_avs_dat     => '0',
      ivr_avs_sdat    => '0',
      ivr_control     => '0',
      ivr_gpio        => (others => '0'),
      unused          => '0'
      );

end;
