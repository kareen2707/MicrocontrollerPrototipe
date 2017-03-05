
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RS232_RX is
    Port ( Clk : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           LineRD_in : in  STD_LOGIC;
           Valid_out : out  STD_LOGIC;
           Code_out : out  STD_LOGIC;
           Store_out : out  STD_LOGIC);
end RS232_RX;

architecture Behavioral of RS232_RX is

	--- State´s definition

	type state is (idle, startbit, rcvdata, stopbit);
	signal CurrentState, NextState : state;

---- Auxiliar signals and constants

	signal en_halfbit, enable_bitcounter, enable_datacount: std_logic;
	signal bit_counter: integer range 0 to 255 :=0;
	signal cnt_halfbit: integer range 0 to 127 :=0;
	signal data_count: integer range 0 to 15	:=0;
  signal aux_store_out, aux_valid_out : std_logic;
	constant max_halfbitcnt : integer:= 86;
	constant bitendofcount : integer:= 173;

begin

--- Register?s Update

NextState_process:	process(clk, reset)
begin
		if reset = '0' then
			CurrentState<=idle;
		elsif clk'event and clk='1' then
			CurrentState <= NextState;
			if en_halfbit='1' then
				cnt_halfbit <= cnt_halfbit + 1 ;
			else
				cnt_halfbit <= 0;
			end if;
			if cnt_halfbit = max_halfbitcnt then
				cnt_halfbit <= 0;
			end if;
			if enable_bitcounter='1' then
				bit_counter <= bit_counter + 1;
			else
				bit_counter <= 0;
			end if;
			if bit_counter = bitendofcount then
				bit_counter <= 0;
				if enable_datacount='1' then
					data_count <= data_count + 1;
				else
					data_count <= 0;
				end if;
			end if;

			if enable_datacount='0' then
				data_count<=0;
			end if;

		end if;

	end process;

---- Next State Logic

FFs_process:	process(CurrentState, LineRD_in, bit_counter, cnt_halfbit, data_count)
begin
		NextState<=CurrentState;
		aux_store_out <= '0';
		aux_valid_out <= '0';
		en_halfbit <= '0';
		enable_bitcounter <= '0';
		enable_datacount <= '0';

		case CurrentState is

			when idle=>
				if LineRD_in = '0' then
					NextState <= startbit;
				end if;

			when startbit=>
				en_halfbit <= '1';
				if cnt_halfbit = max_halfbitcnt then
					NextState<=rcvdata;
				end if;


			when rcvdata=>
				en_halfbit <= '0';
				enable_bitcounter <= '1';
				enable_datacount<='1';
				if data_count = 8 then
					NextState<=stopbit;
					aux_valid_out <= '0';
				elsif bit_counter = bitendofcount then
					aux_valid_out <= '1';
				else
					aux_valid_out <= '0';
				end if;

			when stopbit=>
				enable_bitcounter <= '1';
				if bit_counter = bitendofcount then
					NextState<=idle;
					if LineRD_in = '1' then
						aux_store_out<='1';
					end if;
				end if;
		end case;
	end process;

	Code_out<=LineRD_in;
  Store_out<=aux_store_out;
	Valid_out<=aux_valid_out;


end Behavioral;
