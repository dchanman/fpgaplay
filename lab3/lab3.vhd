library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
	port(CLOCK_50						: in	std_logic;
			 KEY								 : in	std_logic_vector(3 downto 0);
			 SW									: in	std_logic_vector(17 downto 0);
			 LEDG : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  -- ledg
			 LEDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);  -- ledr
			 VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);	-- The outs go to VGA controller
			 VGA_HS							: out std_logic;
			 VGA_VS							: out std_logic;
			 VGA_BLANK					 : out std_logic;
			 VGA_SYNC						: out std_logic;
			 VGA_CLK						 : out std_logic);
end lab3;

architecture rtl of lab3 is

 --Component from the Verilog file: vga_adapter.v

	component vga_adapter
		generic(RESOLUTION : string);
		port (resetn																			 : in	std_logic;
					clock																				: in	std_logic;
					colour																			 : in	std_logic_vector(2 downto 0);
					x																						: in	std_logic_vector(7 downto 0);
					y																						: in	std_logic_vector(6 downto 0);
					plot																				 : in	std_logic;
					VGA_R, VGA_G, VGA_B													: out std_logic_vector(9 downto 0);
					VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
	end component;
	
	component lab3_clear_screen is
	port(
		CLOCK	: in	std_logic;
		RESET : in	std_logic;
		START : in	std_logic;
		X : out std_logic_vector(7 downto 0);
		Y : out std_logic_vector(6 downto 0);
		PLOT	: out std_logic;
		DONE	: out std_logic);
	end component;
	
	component lab3_draw_line is
	port(
    CLOCK  : in  std_logic;
    RESET : in  std_logic;
    START : in  std_logic;
    X0  : in  unsigned(7 downto 0);
    X1  : in  unsigned(7 downto 0);
    Y0  : in  unsigned(7 downto 0);
    Y1  : in  unsigned(7 downto 0);
    X : out unsigned(7 downto 0);
    Y : out unsigned(7 downto 0);
    PLOT  : out std_logic;
    DONE  : out std_logic);
	end component;
	
	--type MY_STATES is (STATE_0_INITIALIZE, STATE_1_CLEAR_SCREEN, STATE_2_WAIT_1, STATE_COMPLETE);
	type MY_STATES is (STATE_0_INITIALIZE, STATE_0_WAIT_1, STATE_1_CLEAR_SCREEN, STATE_2_WAIT_1, STATE_COMPLETE);

	signal x			: std_logic_vector(7 downto 0);
	signal y			: std_logic_vector(6 downto 0);
	signal plot	 : std_logic;
	signal colour	:	std_logic_vector(2 downto 0);
	
	signal x0	:	unsigned(7 downto 0);
	signal x1	:	unsigned(7 downto 0);
	signal y0	:	unsigned(7 downto 0);
	signal y1	:	unsigned(7 downto 0);
	
	signal clear_x			: std_logic_vector(7 downto 0);
	signal clear_y			: std_logic_vector(6 downto 0);
	signal clear_plot	 : std_logic;
	signal clear_start	 : std_logic := '1';
	signal clear_done	 : std_logic;
	signal clear_reset : std_logic := '0';
	
	signal line_x			: unsigned(7 downto 0);
	signal line_y			: unsigned(7 downto 0);
	signal line_plot	 : std_logic;
	signal line_start	 : std_logic := '1';
	signal line_done	 : std_logic;
	signal line_reset : std_logic := '0';

begin

	-- includes the vga adapter, which should be in your project 

	vga_u0 : vga_adapter
		generic map(RESOLUTION => "160x120") 
		port map(resetn		=> KEY(3),
						 clock		 => CLOCK_50,
						 colour		=> colour,
						 x				 => x,
						 y				 => y,
						 plot			=> plot,
						 VGA_R		 => VGA_R,
						 VGA_G		 => VGA_G,
						 VGA_B		 => VGA_B,
						 VGA_HS		=> VGA_HS,
						 VGA_VS		=> VGA_VS,
						 VGA_BLANK => VGA_BLANK,
						 VGA_SYNC	=> VGA_SYNC,
						 VGA_CLK	 => VGA_CLK);
						 
	lab3_clear_screen_u1 : lab3_clear_screen
		port map(
			CLOCK	=> CLOCK_50,
			RESET => clear_reset,
			START => clear_start,
			X => clear_x,
			Y => clear_y,
			PLOT => clear_plot,
			DONE => clear_done);
			
	lab3_draw_line_u1 : lab3_draw_line
		port map(
			CLOCK => CLOCK_50,
			RESET => SW(0),
			START => SW(1),
			X0 => x0,
			Y0 => y0,
			X1 => x1,
			Y1 => y1,
			X => line_x,
			Y => line_y,
			PLOT => plot,
			DONE => LEDG(3));
	
	x0 <= to_unsigned(50,8);
	y0 <= to_unsigned(50,8);
	x1 <= unsigned(SW(17 downto 10));
	y1 <= unsigned("0" & SW(9 downto 3));
	x <= std_logic_vector(line_x);
	y <= std_logic_vector(line_y(6 downto 0));
	
	colour <= SW(2 downto 0);
			
end RTL;


