--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   20:55:48 11/14/2016
-- Design Name:
-- Module Name:   C:/Xilinx/Proyectos/RS232_RX/tb_RS232_top.vhd
-- Project Name:  RS232_RX
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: RS232_RX
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
library ieee;
   use ieee.std_logic_1164.all;
   use ieee.numeric_std.all;
   use ieee.std_logic_arith.all;
   use ieee.std_logic_unsigned.all;
   use work.RS232_test.all;
	USE work.PIC_pkg.all;

entity RS232top_TB is
end RS232top_TB;

architecture Testbench of RS232top_TB is

  component RS232top
    port (
      Reset     : in  std_logic;
      Clk       : in  std_logic;
      Data_in   : in  std_logic_vector(7 downto 0);
      Valid_D   : in  std_logic;
      Ack_in    : out std_logic;
      TX_RDY    : out std_logic;
      TD        : out std_logic;
      RD        : in  std_logic;
      Data_out  : out std_logic_vector(7 downto 0);
      Data_read : in  std_logic;
      Full      : out std_logic;
      Empty     : out std_logic);
  end component;

  signal Reset, Clk, Valid_D, Ack_in, TX_RDY : std_logic;
  signal TD, RD, Data_read, Full, Empty : std_logic;
  signal Data_out, Data_in : std_logic_vector(7 downto 0);

begin

  UUT: RS232top
    port map (
      Reset     => Reset,
      Clk       => Clk,
      Data_in   => Data_in,
      Valid_D   => Valid_D,
      Ack_in    => Ack_in,
      TX_RDY    => TX_RDY,
      TD        => TD,
      RD        => RD,
      Data_out  => Data_out,
      Data_read => Data_read,
      Full      => Full,
      Empty     => Empty);

  Data_in <= "11100010";

  -- Clock generator
  p_clk : PROCESS
  BEGIN
     clk <= '1', '0' after 25 ns;
     wait for 50 ns;
  END PROCESS;
  -- Reset and Transmission Generator
process
	begin
	   reset <= '0', '1' after 75 ns;
		Valid_D <= '1', '0' after 110 ns,
                '1' after 400 ns;
		Data_read <= '0','1'after 88000 ns;
		RD<='1';
		wait for 10 us;
		Transmit(RD, "10101110");
		wait for 100 us;
		Transmit(RD, "11001111");
		wait for 100 us;
		Transmit(RD, "01011001");
		wait;
	end process;

end Testbench;
