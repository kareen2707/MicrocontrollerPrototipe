----------------------------------------------------------------------------------
-- Company: ETSIT UPM
-- Engineer: Karen Flores and Daniel Galera
-- 
-- Create Date:    14:37:50 11/27/2016 
-- Design Name: Microcontroller Prototipe (PIC)
-- Module Name:    DMA - Behavioral 
-- Project Name: 

-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

USE work.PIC_pkg.all;

entity DMA is
    Port ( reset : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           rcvd_data : in  STD_LOGIC_VECTOR (7 downto 0);
           rx_full : in  STD_LOGIC;
			  rx_empty : in STD_LOGIC;
           data_read : out  STD_LOGIC;
           ack_out : in  STD_LOGIC;
           tx_rdy : in  STD_LOGIC;
           valid_d : out  STD_LOGIC;
           tx_data : out  STD_LOGIC_VECTOR (7 downto 0);
           address : out  STD_LOGIC_VECTOR (7 downto 0);
           databus : inout  STD_LOGIC_VECTOR (7 downto 0);
           write_en : out  STD_LOGIC;
           oe : out  STD_LOGIC;
           dma_rq : out  STD_LOGIC;
           dma_ack : in  STD_LOGIC;
           send_comm : in  STD_LOGIC;
           ready : out  STD_LOGIC;
			  int_RQ: out STD_LOGIC -- Improved
			  );
end DMA;

architecture Behavioral of DMA is

---- States Definition

type State is (Idle, wait_buses, wait_tx_ready_1, wait_tx_ready_2, 
					read_rs232, write_rs232_1, write_rs232_2, wait_ack_1, wait_ack_2,
					notify,end_tx); --- There are 12 states

signal CurrentState, NextState: State;

---- Auxiliar signals and constants 
signal cont: std_logic_vector (1 downto 0) := "00";
constant CONT_MAX : std_logic_vector (1 downto 0) :="11";
signal en_cont, rst_cont: std_logic:='0'; -- counter enable 
signal aux_data_read, aux_valid_d, aux_write_en, aux_oe, aux_dma_rq, aux_ready : std_logic;
signal aux_int_RQ : std_logic; -- Improved

begin

state_update: process (clk, reset)
	begin
		if reset = '0' then
			CurrentState <= idle;
			cont<="00";
		elsif clk'event and clk='1' then
			CurrentState <= NextState;
			-- counter?s update and reset with clk signal
			if rst_cont = '1' then 
				cont <= "00";
			elsif en_cont = '1' then
				cont <= cont + 1;
			end if;
		end if;
		
	end process;
	
rx_process: process (CurrentState, rx_empty, dma_ack, databus, send_comm, tx_rdy, ack_out, cont, rcvd_data)
	begin	
		-- Default values: doing this is really necessary to avoid LATCHES
		NextState <= CurrentState;
		rst_cont <= '0';
		en_cont<='0';
		aux_data_read <='0';
		aux_valid_d <='1';
		aux_write_en<='Z';
		aux_oe<='Z';
		aux_dma_rq <='0';
		aux_ready <='0';
		tx_data <=(others=>'Z');
		databus<=(others=>'Z');
		address<=(others =>'Z'); 
		aux_int_RQ <= '0'; -- Improved
		
		case CurrentState is
			when Idle =>
				
				aux_ready <= '1'; --this output is HIGH only in this state
				if rx_empty = '0' then
					NextState <= wait_buses;
				elsif send_comm = '1' then
					NextState <= wait_tx_ready_1;
				end if;
				
			when wait_buses =>
				aux_data_read <='1'; -- request for a new data to FIFO
				aux_dma_rq <='1'; -- request for the buses to the main processor
				if dma_ack ='1' then -- recognition and loan of busses 
					NextState <= read_rs232;
				end if;
			
			when wait_tx_ready_1 =>
				if tx_rdy = '1' then -- RS232 is aviable, so we can start to send data
					NextState <= write_rs232_1;
				end if;
				
			when wait_tx_ready_2 =>
				if tx_rdy = '1' then -- RS232 is aviable, so we can start to send data
					NextState <= write_rs232_2;
				end if;
				
			when read_rs232 => -- reading from RS232_RX and writing into RAM
				aux_dma_rq <='1'; -- to make sure we have the busses 
				databus<= rcvd_data;
				address <= DMA_RX_BUFFER_MSB + cont;
				aux_write_en <='1';
				en_cont <= '1';
				if(cont = "10") then
					NextState<=notify;
					rst_cont<= '1';
				else
					NextState<=idle;
				end if;
				
			when write_rs232_1 =>
				aux_valid_d<='0';
				aux_oe<='0';
				-- we send firstly the MSB byte
				address <= DMA_TX_BUFFER_MSB;
				tx_data <= databus;
				NextState <= wait_ack_1; -- need to receive de ACK
				
			when write_rs232_2 =>
				aux_valid_d<='0';
				aux_oe<='0';
				-- we send secondly the MSB byte
				address <= DMA_TX_BUFFER_LSB;
				tx_data <= databus;
				NextState <= wait_ack_2; -- need to receive de ACK	
				
			when wait_ack_1 =>
				aux_valid_d <= '1'; -- when this signal?s value is '1' ack_out must be '0'
				if (ack_out = '0') then
					NextState <= wait_tx_ready_2;
				end if;
				
			when wait_ack_2 =>
				aux_valid_d <= '1'; -- when this signal?s value is '1' ack_out must be '0'
				if (ack_out = '0') then
					NextState <= end_tx;
				end if;
										
			when notify => -- when DMA receives a complete comand from RS232_RX it writes the xFF value into NEW_INSTDMA
--				aux_dma_rq <='1';
--				databus <= x"FF";
--				address <= NEW_INST;
--				aux_write_en <='1';
				aux_int_RQ <= '1'; -- Interruption activated
				NextState <= idle;
				
--			when free_buses =>
--				aux_dma_rq <= '0'; -- we notify to the main controller we?ve finish data reading, so we don?t need the busses
--				if dma_ack ='1' then 
--					NextState <= Idle;
--				end if;
				
			when end_tx =>
				if send_comm = '0' then
					NextState <= Idle;
				end if;
			
				
			end case;
	end process;
	
-- Output?s update
data_read <= aux_data_read;
valid_d <= aux_valid_d;
write_en <=	aux_write_en;
oe <=	aux_oe;
dma_rq <= aux_dma_rq;
ready	<=	aux_ready ;
int_RQ <= aux_int_RQ; --Improved

end Behavioral;