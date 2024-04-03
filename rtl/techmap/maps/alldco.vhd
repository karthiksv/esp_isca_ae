-- Copyright (c) 2011-2021 Columbia University, System Level Design Group
-- SPDX-License-Identifier: Apache-2.0
library ieee;
use ieee.std_logic_1164.all;

package alldco is

  component behav_dco is
    port (
      RSTN     : in  std_ulogic;
      EXT_CLK  : in  std_logic;
      EN       : in  std_ulogic;
      CLK_SEL  : in  std_ulogic;
      CC_SEL   : in  std_logic_vector(5 downto 0);
      FC_SEL   : in  std_logic_vector(5 downto 0);
      DIV_SEL  : in  std_logic_vector(2 downto 0);
      FREQ_SEL : in  std_logic_vector(1 downto 0);
      CLK      : out std_logic;
      CLK_DIV  : out std_logic);
  end component behav_dco;

end package alldco;
