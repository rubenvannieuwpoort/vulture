library ieee;
use ieee.std_logic_1164.all;


package types is
	type memory_clock_signals is record
		sysclk_2x: std_logic;
		sysclk_2x_180: std_logic;
		pll_ce_0: std_logic;
		pll_ce_90: std_logic;
		pll_lock: std_logic;
		mcb_drp_clk: std_logic;
	end record;

	type vga_signals is record
		hsync: std_logic;
		vsync: std_logic;
		red: std_logic_vector(2 downto 0);
		green: std_logic_vector(2 downto 0);
		blue: std_logic_vector(2 downto 1);
	end record;

	type ram_signals is record
		a: std_logic_vector(12 downto 0);
		ba: std_logic_vector(1 downto 0);
		cke: std_logic;
		ras_n: std_logic;
		cas_n: std_logic;
		we_n: std_logic;
		dm: std_logic;
		udm: std_logic;
		ck: std_logic;
		ck_n: std_logic;
	end record;

	type ram_bus_signals is record
		dq: std_logic_vector(15 downto 0);
		udqs: std_logic;
		rzq: std_logic;
		dqs: std_logic;
	end record;

	type read_cmd_signals is record 
		clk: std_logic;
		enable: std_logic;
		data_enable: std_logic;
		address: std_logic_vector(29 downto 0);
	end record;

	type read_status_signals is record
		cmd_full: std_logic;
		cmd_empty: std_logic;
		data: std_logic_vector(31 downto 0);
		data_full: std_logic;
		data_empty: std_logic;
		data_count: std_logic_vector(6 downto 0);
		error: std_logic;
		overflow: std_logic;
	end record;

	type write_cmd_signals is record
		clk: std_logic;
		enable: std_logic;
		data_enable: std_logic;
		address: std_logic_vector(29 downto 0);
		write_mask: std_logic_vector(3 downto 0);
		data: std_logic_vector(31 downto 0);
	end record;

	type write_status_signals is record
		cmd_full: std_logic;
		cmd_empty: std_logic;
		data_full: std_logic;
		data_empty: std_logic;
		data_count: std_logic_vector(6 downto 0);
		error: std_logic;
	end record;
end package;