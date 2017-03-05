----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:23:51 12/16/2016 
-- Design Name: 
-- Module Name:    RAM - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

ENTITY ram IS
PORT (
   Clk      : in    std_logic;
   Reset    : in    std_logic;
   write_en : in    std_logic;
   oe       : in    std_logic;
   address  : in    std_logic_vector(7 downto 0);
   databus  : inout std_logic_vector(7 downto 0);
	Switches : out std_logic_vector(7 downto 0);
	Temp_L 	: out std_logic_vector(6 downto 0);
	Temp_H	: out std_logic_vector(6 downto 0));
END ram;

ARCHITECTURE behavior OF ram IS

  SIGNAL contents_ram_ge : array8_ram(255 downto 0);
  signal contents_ram_es : array8_ram(63 downto 0);
  
  signal cs: std_logic;
  
  

BEGIN

	cs <= '0' when address < 64 else '1';
	
	
p_switches :process (contents_ram_es)
begin
	for i in 0 to 7 loop
		Switches(i) <= contents_ram_es(conv_integer(SWITCH_BASE+i))(0);
	end loop;
end process;




ram_es :process (clk, reset)
begin
	if(reset = '0') then
		--defecto
		contents_ram_es(conv_Integer(DMA_RX_BUFFER_MSB)) 	<= X"00";
		contents_ram_es(conv_Integer(DMA_RX_BUFFER_MID)) 	<= X"00";
		contents_ram_es(conv_Integer(DMA_RX_BUFFER_LSB)) 	<= X"00";
		contents_ram_es(conv_Integer(NEW_INST)) 				<= X"00";
		contents_ram_es(conv_Integer(DMA_TX_BUFFER_MSB)) 	<= X"00";
		contents_ram_es(conv_Integer(DMA_TX_BUFFER_LSB)) 	<= X"00";
		--desde 06 hasta 0F reservado para ampliacion
		contents_ram_es(conv_integer(SWITCH_BASE))			<= X"00";
		contents_ram_es(conv_integer(SWITCH_BASE+1))			<= X"00";
		contents_ram_es(conv_integer(SWITCH_BASE+2))			<= X"00";
		contents_ram_es(conv_integer(SWITCH_BASE+3))			<= X"00";
		contents_ram_es(conv_integer(SWITCH_BASE+4))			<= X"00";
		contents_ram_es(conv_integer(SWITCH_BASE+5))			<= X"00";
		contents_ram_es(conv_integer(SWITCH_BASE+6))			<= X"00";
		contents_ram_es(conv_integer(SWITCH_BASE+7))			<= X"00";
		--desde 18 hasta 1F reservado para ampliacion
		contents_ram_es(conv_integer(LEVER_BASE))				<= X"00";
		contents_ram_es(conv_integer(LEVER_BASE+1))			<= X"00";
		contents_ram_es(conv_integer(LEVER_BASE+2))			<= X"00";
		contents_ram_es(conv_integer(LEVER_BASE+3))			<= X"00";
		contents_ram_es(conv_integer(LEVER_BASE+4))			<= X"00";
		contents_ram_es(conv_integer(LEVER_BASE+5))			<= X"00";
		contents_ram_es(conv_integer(LEVER_BASE+6))			<= X"00";
		contents_ram_es(conv_integer(LEVER_BASE+7))			<= X"00";
		contents_ram_es(conv_integer(LEVER_BASE+8))			<= X"00";
		contents_ram_es(conv_integer(LEVER_BASE+9))			<= X"00";
		--desde 2A hasta 30 reservado para ampliacion
		contents_ram_es(conv_integer(T_STAT))					<= X"21"; --el valor que saldra por el lcd sera 15
		--desde 32 hasta 3F reservado para ampliacion
		
	elsif clk'event and clk = '1' then
	--escritura en memoria
		if ( write_en = '1' and cs='0' ) then
			contents_ram_es(conv_Integer(address)) <= databus;
		end if;
	end if;
end process;

databus <= contents_ram_es(conv_integer(address)) when (oe = '0' and cs = '0') else (others => 'Z');

-------------------------------------------------------------------------
-- General purpose memory
-------------------------------------------------------------------------
ram_ge : process (clk)  -- no reset
begin
  
  if clk'event and clk = '1' then
    if ( write_en = '1' and cs='1' ) then
      contents_ram_ge(conv_Integer(address)) <= databus;
    end if;
  end if;

end process;

databus <= contents_ram_ge(conv_integer(address)) when (oe = '0' and cs = '1') else (others => 'Z'); 

-------------------------------------------------------------------------
-- BCD decoder 7 segments
-------------------------------------------------------------------------
with contents_ram_es(conv_integer(T_STAT))(7 downto 4) select
Temp_H <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
    "1110111" when "1010",  -- A
    "1111100" when "1011",  -- B
    "0111001" when "1100",  -- C
    "1011110" when "1101",  -- D
    "1111001" when "1110",  -- E
    "1110001" when "1111",  -- F
    "0111111" when others;  -- 0
	 
	 
with contents_ram_es(conv_integer(T_STAT))(3 downto 0) select
Temp_L <=
    "0000110" when "0001",  -- 1
    "1011011" when "0010",  -- 2
    "1001111" when "0011",  -- 3
    "1100110" when "0100",  -- 4
    "1101101" when "0101",  -- 5
    "1111101" when "0110",  -- 6
    "0000111" when "0111",  -- 7
    "1111111" when "1000",  -- 8
    "1101111" when "1001",  -- 9
    "1110111" when "1010",  -- A
    "1111100" when "1011",  -- B
    "0111001" when "1100",  -- C
    "1011110" when "1101",  -- D
    "1111001" when "1110",  -- E
    "1110001" when "1111",  -- F
    "0111111" when others;  -- 0
-------------------------------------------------------------------------

END behavior;

