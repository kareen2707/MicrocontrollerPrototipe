----------------------------------------------------------------------------------
-- Company: ETSIT UPM
-- Engineer: Karen Flores and Daniel Galera
-- 
-- Create Date:    13:16:35 11/29/2016 
-- Design Name:  Arithmetic Logic Unit
-- Module Name:    ALU - Behavioral 
-- Project Name: Microcontroller Prototipe (PIC)
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.PIC_pkg.all;

entity ALU is
    Port ( reset : in  STD_LOGIC; --asynchronous, active low
           clk : in  STD_LOGIC; --System clock, 20 MHz, rising_edge
           ALU_OP: in ALU_OP; -- u-instruction from CPU
			  databus : inout  STD_LOGIC_VECTOR (7 downto 0); -- system data bus
			  index_reg : out  STD_LOGIC_VECTOR(7 downto 0); --index register
           flagz : out  STD_LOGIC; -- zero flag
           flagc : out  STD_LOGIC; -- carry flag
           flagn : out  STD_LOGIC; -- nibble carry bit
           flage : out  STD_LOGIC); -- error flag
           
end ALU;

architecture Behavioral of ALU is

-- Internal signals
signal A, B: std_logic_vector(7 downto 0); -- signals for A and B operands
signal acc, index: std_logic_vector (7 downto 0); -- internal registers
signal acc_save: std_logic_vector (7 downto 0); -- Improved

-- Auxiliar signals
signal aux_fz, aux_fc, aux_fn, aux_fe: std_logic;

begin

ALU_PROCESS: process (clk, reset)

-- Auxiliar variables
variable s_add, s_sub, s_and, s_or, s_xor : std_logic_vector (7 downto 0);

begin
	if reset = '0' then -- asynchronous low active reset
		A <= (others => '0');
		B <= (others => '0');
		acc <=(others => '0');
		index <= (others => '0');
		aux_fz <='0';
		aux_fc <='0';
		aux_fn <='0';
		aux_fe <='0';
	elsif clk'event and clk='1' then
		
		case ALU_OP is
			when nop => -- no operation
				A <= A;
				B <= B;
				acc <= acc;
				index <= index;
			when op_lda => -- external value load in A
				A <= databus;
			when op_ldb => -- external value load in B
				B <= databus;
			when op_ldacc => -- external value load in acc
				acc <= databus;
			when op_ldid => -- external value load in A
				index <= databus;
			when op_mvacc2id => -- internal load: from acc to index
				index <= acc;
			when op_mvacc2a => -- internal load: from acc to A
				A <= acc;
			when op_mvacc2b => -- internal load: from acc to B
				B <= acc;
			when op_add => -- addition operation
				s_add := A + B;
				acc <= s_add;
				if s_add = X"00" then
					aux_fz <= '1';
				else 
					aux_fz <= '0';
				end if;
			when op_sub => -- substraction operation
				s_sub := A - B;
				acc <= s_sub;
				if s_sub = X"00" then
					aux_fz <= '1';
				else 
					aux_fz <= '0';
				end if;
			when op_shiftl => -- left shift
				acc (7 downto 1) <= acc (6 downto 0);
				acc(0) <='0';
			when op_shiftr => -- right shift
				acc (6 downto 0) <= acc (7 downto 1);
				acc(7) <='0';
			when op_and => -- and operation
				s_and := A and B;
				acc <= s_and;
				if s_and = X"00" then
					aux_fz <= '1';
				else 
					aux_fz <= '0';
				end if; 
			when op_or => -- or operation
				s_or := A or B;
				acc <= s_or;
				if s_or = X"00" then
					aux_fz <= '1';
				else 
					aux_fz <= '0';
				end if; 
			when op_xor => -- xor operation
				s_xor := A xor B;
				acc <= s_xor;
				if s_xor = X"00" then 
					aux_fz <= '1';
				else 
					aux_fz <= '0';
				end if; 
			when op_cmpe => -- compare operations
				if (A = B) then
					aux_fz <= '1';
				else 
					aux_fz <= '0';
				end if;
			when op_cmpl => -- compare operations
				if (A < B) then
					aux_fz <= '1';
				else 
					aux_fz <= '0';
				end if;
			when op_cmpg => -- compare operations
				if (A > B) then
					aux_fz <= '1';
				else 
					aux_fz <= '0';
				end if;
			when op_ascii2bin => -- conversion ascii to binary
			-- this operation only converts ascii characteres
			-- which represent 0-9 number value
				if ( (A >= x"30") and (A <= x"39") ) then
					acc <= A - x"30"; 
				else 
					acc <= x"FF";
				end if;
			when op_bin2ascii => -- conversion binary to ascii
			-- this operation only converts binary characteres
			-- which represent 0-9 number value
				if ( A < x"10" ) then
					acc <= A + x"30"; 
				else 
					acc <= x"FF";
				end if;
			when op_save => -- Saving acumulator
				acc_save <= acc;
			when op_restore => --Restoring acumulator
				acc <= acc_save;
			when op_oeacc => 
				
			
		end case;
	end if;
end process;

-- Output update
flagz <= aux_fz;
flagc <= aux_fc;
flagn <= aux_fn;
flage <= aux_fe;
index_reg <= index;
Databus <= acc when (ALU_OP = op_oeacc) else (others=>'Z') ;
				
end Behavioral;

