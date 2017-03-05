----------------------------------------------------------------------------------
--- Company: ETSIT UPM
--- Engineer: Karen Flores and Daniel Galera
--- 
--- Create Date:    17:35:12 11/21/2016 
--- Design Name: RAM 
--- Module Name:    RAM - Behavioral 
--- Project Name: Microcontroller Prototipe (PIC)
--- Description: 
--- Revision: 
--- Revision 0.01 - File Created
--- Additional Comments: 
---
---------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

USE work.PIC_pkg.all;
 
ENTITY tb_RAM IS
END tb_RAM;
 
ARCHITECTURE behavior OF tb_RAM IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ram
    PORT(
         Clk : IN  std_logic;
         Reset : IN  std_logic;
         write_en : IN  std_logic;
         oe : IN  std_logic;
         address : IN  std_logic_vector(7 downto 0);
         databus : INOUT  std_logic_vector(7 downto 0);
         Switches : OUT  std_logic_vector(7 downto 0);
         Temp_L : OUT  std_logic_vector(6 downto 0);
         Temp_H : OUT  std_logic_vector(6 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal Clk : std_logic;
   signal Reset : std_logic;
   signal write_en : std_logic;
   signal oe : std_logic;
   signal address : std_logic_vector(7 downto 0);

	--BiDirs
   signal databus : std_logic_vector(7 downto 0);

 	--Outputs
   signal Switches : std_logic_vector(7 downto 0);
   signal Temp_L : std_logic_vector(6 downto 0);
   signal Temp_H : std_logic_vector(6 downto 0);

   -- Clock period definitions
   constant Clk_period : time := 50 ns;
	
	constant zz : std_logic_vector(7 downto 0) := (others =>'Z');
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ram PORT MAP (
          Clk => Clk,
          Reset => Reset,
          write_en => write_en,
          oe => oe,
          address => address,
          databus => databus,
          Switches => Switches,
          Temp_L => Temp_L,
          Temp_H => Temp_H
        );

   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 

   Reset <= '0', '1' after 80 ns;
	
	write_en <= '0', '1' after 210 ns, '0' after 260 ns, '1' after 480 ns, '0' after 530 ns;
	
	oe <= '1', '0' after 110 ns, '1' after 160 ns, '0' after 310 ns, '1' after 360 ns ;
	
	databus <= zz, X"FA" after 210 ns, zz after 260 ns, X"01" after 480 ns, zz after 530 ns;
	
	address <= T_STAT, GP_RAM_BASE after 210 ns, SWITCH_BASE after 480 ns;

END;
