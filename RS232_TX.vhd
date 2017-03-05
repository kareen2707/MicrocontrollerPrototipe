----------------------------------------------------------------------------------
-- Company: ETSIT UPM
-- Engineers: Karen Flores Yanez y Daniel Galera Nebot
--
-- Create Date:    09:42:24 10/31/2016
-- Design Name: RS232
-- Module Name:    RS232_TX
-- Project Name:  Microcontroller Prototipe (PIC)

-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity RS232_TX is


    Port ( Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           Start : in  STD_LOGIC;
           Data : in  STD_LOGIC_VECTOR (7 downto 0);
           EOT : out  STD_LOGIC;
           TX : out  STD_LOGIC);
end RS232_TX;

architecture Behavioral of RS232_TX is

--- State?s definition

type state is ( Idle, StartBit, sendata, stopbit);
signal CurrentState, NextState : state;

---- Auxiliar signals and constants

signal data_count: integer range 0 to 15 := 0; --- bit counter
signal bit_counter: integer range 0 to 255 :=0; --- clk counter acording to bit rate
signal aux_eot, aux_tx: STD_LOGIC;
signal enable_datacount, enable_bitcounter: STD_LOGIC :='0'; --- synchronous high active signals
constant BitEndOfCount : integer:=173; --- bit generated length acording to clk frequency and bit rate

begin


--- Pulse width and bit counter
counter: process(clk, reset)
begin
		if reset = '0' then
			CurrentState <= Idle;
	  elsif Clk'event and Clk='1' then
			CurrentState <= NextState; --- state?s update
		 if ( enable_bitcounter = '1') then
			bit_counter <= bit_counter + 1;
		 else
			bit_counter <= 0;
		 end if;
		 if ( bit_counter >= BitEndOfCount ) then
			bit_counter <= 0;
			if ( enable_datacount = '1') then --- each time a bit time has ended if we are sending data we add one to data_count
			data_count <= data_count + 1;
			else
			data_count <= 0;
		 end if;
	  end if;
	end if;
end process;

---- Next State Logic
Next_state: process(start, bit_counter, data_count, CurrentState, Data)
begin
	NextState <= CurrentState;
	aux_eot <= '1'; --- notify the end of trama
	aux_tx <= '1'; --- to detect in TX transition from Idle to StartBit
	enable_datacount <= '0';
	enable_bitcounter <= '0';

		case CurrentState is
			when Idle =>
				aux_eot <= '1'; --- notify the end of trama
				aux_tx <= '1'; --- to detect in TX transition from Idle to StartBit
				if start = '1' then
					NextState <= StartBit;
					aux_eot <= '0'; --- starts the trama
				else
					NextState <= Idle;
				end if;

			when StartBit =>
				aux_tx <= '0'; --- 1 bit of start of trama
				aux_eot <= '0';
				enable_bitcounter <= '1';
				if(bit_counter >= BitEndOfCount) then
					NextState <= sendata;
				end if;

			when sendata =>
				aux_eot <= '0';
				enable_bitcounter <= '1';
				if(data_count<8) then
					aux_tx <= data(data_count);
					enable_datacount <= '1';
				end if;
				if data_count >= 8 then --- 7 bits of data
					NextState <= stopbit;
					enable_datacount <= '0';
				end if;

			when stopbit =>
				aux_tx <= '1';
				aux_eot <= '0';
				enable_bitcounter <= '1';
				if bit_counter >= BitEndOfCount then
					NextState <= Idle;
				end if;

			end case;

end process;

tx <= aux_tx;
eot <= aux_eot;

end Behavioral;
