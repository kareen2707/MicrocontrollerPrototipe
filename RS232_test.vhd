
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

PACKAGE RS232_test IS

-------------------------------------------------------------------------------
-- Procedure for sending one byte over the RS232 serial input
-------------------------------------------------------------------------------
      procedure Transmit (
        signal   TX   : out std_logic;      -- serial line
        constant DATA : in  std_logic_vector(7 downto 0)); -- byte to be sent

-------------------------------------------------------------------------------
-- Procedure for receiving one byte from the RS232 serial output
-------------------------------------------------------------------------------
      procedure Receive (
        signal RX   : in  std_logic;      -- serial line
        signal DATA : out std_logic_vector(7 downto 0)); -- byte to be received

END RS232_test;

PACKAGE BODY RS232_test IS

-----------------------------------------------------------------------------
-- Procedure for sending one byte over the RS232 serial input
-----------------------------------------------------------------------------     
           procedure Transmit (
             signal   TX   : out std_logic;  -- serial output
             constant DATA : in  std_logic_vector(7 downto 0)) is
           begin
       
             TX <= '0';
             wait for 8680.6 ns;  -- about to send byte

             for i in 0 to 7 loop
               TX <= DATA(i);
               wait for 8680.6 ns;
             end loop;  -- i

             TX <= '1';
             wait for 8680.6 ns;

             TX <= '1';

           end Transmit;

-------------------------------------------------------------------------------
-- Procedure for receiving one byte from the RS232 serial output
-------------------------------------------------------------------------------
           procedure Receive (
             signal RX   : in  std_logic;      -- serial line
             signal DATA : out std_logic_vector(7 downto 0)) is

             variable tmp : std_logic_vector(7 downto 0);
           begin
             while TRUE loop
					
                 wait until RX='0';
                 wait for 13021 ns;
       
                 for i in 0 to 7 loop
                   tmp(i) := RX;
                   wait for 8680.6 ns;
                 end loop;

                 --wait for 4340.3 ns;
                 DATA <= tmp;

             end loop;
           end Receive;

END RS232_test;
