
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;
use work.RS232_test.all;
USE work.PIC_pkg.all;

entity PICtop_tb is
end PICtop_tb;

architecture TestBench of PICtop_tb is

  component PICtop
    port (
      Reset    : in  std_logic;
      Clk      : in  std_logic;
      RS232_RX : in  std_logic;
      RS232_TX : out std_logic;
      switches : out std_logic_vector(7 downto 0);
      Temp_L   : out std_logic_vector(6 downto 0);
      Temp_H   : out std_logic_vector(6 downto 0));
  end component;

-----------------------------------------------------------------------------
-- Internal signals
-----------------------------------------------------------------------------

  signal Reset    : std_logic;
  signal Clk      : std_logic;
  signal RS232_RX : std_logic;
  signal RS232_TX : std_logic;
  signal switches : std_logic_vector(7 downto 0);
  signal Temp_L   : std_logic_vector(6 downto 0);
  signal Temp_H   : std_logic_vector(6 downto 0);
  signal data_aux : std_logic_vector(7 downto 0);

begin  -- TestBench

  UUT: PICtop
    port map (
        Reset    => Reset,
        Clk      => Clk,
        RS232_RX => RS232_RX,
        RS232_TX => RS232_TX,
        switches => switches,
        Temp_L   => Temp_L,
        Temp_H   => Temp_H);

-----------------------------------------------------------------------------
-- Reset & clock generator
-----------------------------------------------------------------------------

  Reset <= '0', '1' after 75 ns;

  p_clk : PROCESS
  BEGIN
     clk <= '1', '0' after 25 ns;
     wait for 50 ns;
  END PROCESS;

-------------------------------------------------------------------------------
-- Sending some stuff through RS232 port
-------------------------------------------------------------------------------
rx_process: process
		begin
		data_aux <= (others =>'0');
		Receive(rs232_TX, data_aux);
		wait;
		end process;
	
  SEND_STUFF : process
  begin
     RS232_RX <= '1';
     wait for 40 us;
	  --  I (X"49") p1(0-7) p2(0-1) select switch 4 and turn on ('1')
     Transmit(RS232_RX, X"49");
     wait for 80 us;
     Transmit(RS232_RX, X"33");
     wait for 120 us;
     Transmit(RS232_RX, X"31");
     wait for 160 us;
	  --  A (X"41") p1(0-9) p2(0-9)	select actuator 1 and put 5 value
	  Transmit(RS232_RX, X"41");
	  wait for 200 us;
	  Transmit(RS232_RX, X"30");
	  wait for 240 us;
	  Transmit(RS232_RX, X"32");
	  wait for 300 us;
	  --  T (X"54") p1(1-2) p2(0-9)	termostate value = 10 ?C
	  Transmit(RS232_RX, X"54");
	  wait for 350 us;
	  Transmit(RS232_RX, X"31");
	  wait for 400 us;
	  Transmit(RS232_RX, X"30");
	  --  S (X"53") p1(IAT) p2(0-9) switch 4 state request, its value must be '1'
	  wait for 600 us;
	  Transmit(RS232_RX, X"53");
	  wait for 650 us;
	  Transmit(RS232_RX, X"49");
	  wait for 700 us;
	  Transmit(RS232_RX, X"34");
	  wait for 750 us;
	  --  S (X"53") p1(IAT) p2(0-9) actuator 0 state request, its value must be '2'
	  Transmit(RS232_RX, X"53");
	  wait for 800 us;
	  Transmit(RS232_RX, X"41");
	  wait for 850 us;
	  Transmit(RS232_RX, X"30");
	  wait for 900 us;
	  --  S (X"53") p1(IAT) p2(0-9) temp_X state request, its value must be '2'
	  Transmit(RS232_RX, X"53");
	  wait for 950 us;
	  Transmit(RS232_RX, X"54");
	  wait for 1000 us;
	  Transmit(RS232_RX, X"31");
	  wait;
	  
  end process SEND_STUFF;
  
  --  Command Types
--  I (X"49") p1(0-7) p2(0-1) select a switch and turn on/down it
--  A (X"41") p1(0-9) p2(0-9)	select an actuator and assign a value to it
--  T (X"54") p1(1-2) p2(0-9)	change termostate value
--  S (X"53") p1(IAT) p2(0-9) request information 
   
end TestBench;

