
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

USE work.PIC_pkg.all;

entity PICtop is
  port (
    Reset    : in  std_logic;           -- Asynchronous, active low
    Clk      : in  std_logic;           -- System clock, 20 MHz, rising_edge
    RS232_RX : in  std_logic;           -- RS232 RX line
    RS232_TX : out std_logic;           -- RS232 TX line
    switches : out std_logic_vector(7 downto 0);  -- Switch status bargraph
    Temp_L   : out std_logic_vector(6 downto 0);  -- Less significant figure of T_STAT
    Temp_H   : out std_logic_vector(6 downto 0));  -- Most significant figure of T_STAT
end PICtop;

architecture behavior of PICtop is
	
	component CPU
   port ( 
			Reset : in  STD_LOGIC;
         Clk : in  STD_LOGIC;
         ROM_Data : in  STD_LOGIC_VECTOR (11 downto 0);
         ROM_Addr : out  STD_LOGIC_VECTOR (11 downto 0);
         RAM_Addr : out  STD_LOGIC_VECTOR (7 downto 0);
         RAM_Write : out  STD_LOGIC;
         RAM_OE : out  STD_LOGIC;
         Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
         DMA_RQ : in  STD_LOGIC;
         DMA_ACK : out  STD_LOGIC;
         SEND_comm : out  STD_LOGIC;
         DMA_READY : in  STD_LOGIC;
         Alu_op : out  alu_op;
         Index_Reg : in  STD_LOGIC_VECTOR (7 downto 0);
         FlagZ : in  STD_LOGIC;
         FlagC : in  STD_LOGIC;
         FlagN : in  STD_LOGIC;
         FlagE : in  STD_LOGIC;
			int_RQ : in STD_LOGIC -- Improved
			);
	end component;
	
	component ALU
   Port ( 
			Reset : in  STD_LOGIC;
         Clk : in  STD_LOGIC;
         Alu_op : in  alu_op;
         Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
         Index_Reg : out  STD_LOGIC_VECTOR (7 downto 0);
         FlagZ : out  STD_LOGIC;
         FlagC : out  STD_LOGIC;
         FlagN : out  STD_LOGIC;
         FlagE : out  STD_LOGIC
			);
	end component;
	
	component ROM
	port (
			Instruction     : out std_logic_vector(11 downto 0);  -- Instruction bus
			Program_counter : in  std_logic_vector(11 downto 0)
			);
	end component;
	
	component ram
	port (
			Clk      : in    std_logic;
			Reset    : in    std_logic;
			write_en : in    std_logic;
			oe       : in    std_logic;
			address  : in    std_logic_vector(7 downto 0);
			databus  : inout std_logic_vector(7 downto 0);
			Switches : out std_logic_vector(7 downto 0);
			Temp_L 	: out std_logic_vector(6 downto 0);
			Temp_H	: out std_logic_vector(6 downto 0)
			);
	end component;
	
	component DMA
   port ( 
			Reset : in  STD_LOGIC;
         Clk : in  STD_LOGIC;
         RCVD_Data : in  STD_LOGIC_VECTOR (7 downto 0);
         RX_Full : in  STD_LOGIC;
         RX_Empty : in  STD_LOGIC;
         ACK_out : in  STD_LOGIC;
         TX_RDY : in  STD_LOGIC;
         DMA_ACK : in  STD_LOGIC;
         Send_comm : in  STD_LOGIC;
         Databus : inout  STD_LOGIC_VECTOR (7 downto 0);
         Data_Read : out  STD_LOGIC;									
         Valid_D : out  STD_LOGIC;
         TX_Data : out  STD_LOGIC_VECTOR (7 downto 0);
         Address : out  STD_LOGIC_VECTOR (7 downto 0);
         Write_en : out  STD_LOGIC;
         OE : out  STD_LOGIC;
         DMA_RQ : out  STD_LOGIC;
         READY : out  STD_LOGIC;
			int_RQ: out STD_LOGIC --Improved
			);
	end component;
	
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
	
	--BiDirs
	signal Databus : std_logic_vector(7 downto 0);
	signal Address : std_logic_vector(7 downto 0);
	
	--Internal
	signal TX_Data, RCVD_Data, Index_Reg : std_logic_vector (7 downto 0);
	signal Valid_D, Ack_out, TX_RDY, Data_read, RX_Full, RX_Empty, DMA_ACK, Send_comm, Write_en, OE, DMA_RQ, DMA_READY, Flag_Z, Flag_C, Flag_N, Flag_E	: std_logic;
	signal ROM_Data, ROM_Addr : STD_LOGIC_VECTOR (11 downto 0);
	signal Alu_op : alu_op;
	signal int_RQ: std_logic; --improved
	

begin  -- behavior

	RS232_PHY: RS232top
		port map (
        Reset     => Reset,
        Clk       => Clk,
        Data_in   => TX_Data,
        Valid_D   => Valid_D,
        Ack_in    => Ack_out,
        TX_RDY    => TX_RDY,
        TD        => RS232_TX,
        RD        => RS232_RX,
        Data_out  => RCVD_Data,
        Data_read => Data_read,
        Full      => RX_Full,
        Empty     => RX_Empty
		  );
		  
	DMA_PHY: DMA
		port map ( 
			Reset		=> Reset,
         Clk		=> Clk,
         RCVD_Data => RCVD_Data,
         RX_Full	=> RX_Full,
         RX_Empty	=> RX_Empty,
         ACK_out	=> Ack_out,
         TX_RDY	=> TX_RDY,
         DMA_ACK	=> DMA_ACK,
         Send_comm => Send_comm,
         Databus => Databus,
         Data_Read => Data_Read,									
         Valid_D	=> Valid_D,
         TX_Data => TX_Data,
         Address => Address,
         Write_en => Write_en,
         OE 		=> OE,
         DMA_RQ	=> DMA_RQ,
         READY 	=> DMA_READY,
			int_RQ => int_RQ --Improved
			);
			
	RAM_PHY: ram
		port map (
			Clk      	=> Clk,
			Reset    	=> Reset,
			write_en 	=> Write_en,
			oe       	=> OE,
			address  	=> Address,
			databus  	=> Databus,
			Switches 	=> Switches,
			Temp_L 		=> Temp_L,
			Temp_H		=> Temp_H
			);
	
	CPU_PHY: CPU
		port map ( 
			Reset 	=> Reset,
         Clk		=> Clk,
         ROM_Data => ROM_Data,
         ROM_Addr => ROM_Addr,
         RAM_Addr => Address,
         RAM_Write => Write_en,
         RAM_OE 	=> OE,
         Databus	=> Databus,
         DMA_RQ 	=> DMA_RQ,
         DMA_ACK	=> DMA_ACK,
         SEND_comm => Send_comm,
         DMA_READY => DMA_READY,
         Alu_op	=> Alu_op,
         Index_Reg => Index_Reg,
         FlagZ 	=> Flag_Z,
         FlagC		=> Flag_C,
         FlagN		=> Flag_N,
         FlagE		=> Flag_E,
			int_RQ => int_RQ --Improved
			);
			
	ALU_PHY: ALU
		port map ( 
			Reset		=> Reset,
         Clk		=> Clk,
         Alu_op	=> Alu_op,
         Databus	=> Databus,
         Index_Reg => Index_Reg,
         FlagZ 	=> Flag_Z,
         FlagC		=> Flag_C,
         FlagN		=> Flag_N,
         FlagE		=> Flag_E
			);
			
	ROM_PHY: ROM
		port map (
			Instruction     => ROM_Data,
			Program_counter => ROM_Addr
			);

end behavior;
