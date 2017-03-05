----------------------------------------------------------------------------------
-- Company: ETSIT UPM
-- Engineers: Karen Flores Y?nez y Daniel Galera Nebot
-- 
-- Create Date:    09:42:24 10/31/2016 
-- Design Name: Shift Register: Serial In - Parallel Out
-- Module Name:    ShiftRegister - Behavioral 
-- Project Name:  Controlador para puerto serie RS232
 
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ShiftRegister is
    Port ( Reset : in  STD_LOGIC;
           Clk : in  STD_LOGIC;
           Enable : in  STD_LOGIC;
           D : in  STD_LOGIC;
           Q : out  STD_LOGIC_VECTOR (7 downto 0));
end ShiftRegister;

architecture Behavioral of ShiftRegister is
	
	signal aux: STD_LOGIC_VECTOR (7 downto 0);
	
begin

process (Reset, Clk, enable)
	
	begin
	
		if reset = '0' then	-- asynchronous low active reset				
			aux <= (others => '0');
		
		elsif clk'event and clk = '1' and enable = '1' then
			--right shift, because the first bit we receive is the LSB,
			-- at the end of the 8 right shift we?ll obtain the MSB in
			-- its correct place aux(7)
			aux (6 downto 0 ) <= aux (7 downto 1); 
			aux (7) <= D;	
		end if;
	
	end process;
	
	Q <= aux;

end Behavioral;

