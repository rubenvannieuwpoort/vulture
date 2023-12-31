library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.top_level_types.all;
use work.top_level_constants.all;


entity top_level is
	port(
		clk_sys: in std_logic;

		-- VGA
		vga_hsync: out std_logic;
		vga_vsync: out std_logic;
		vga_red: out std_logic_vector(2 downto 0);
		vga_green: out std_logic_vector(2 downto 0);
		vga_blue: out std_logic_vector(2 downto 1);

		-- LEDs
		leds_out: out std_logic_vector(7 downto 0);

		-- seven segment display
		seven_segment_enable: out std_logic_vector(2 downto 0);
		seven_segment: out std_logic_vector(7 downto 0);

		-- RAM
		ram_dq: inout std_logic_vector(15 downto 0);
		ram_a: out std_logic_vector(12 downto 0);
		ram_ba: out std_logic_vector( 1 downto 0);
		ram_cke: out std_logic;
		ram_ras_n: out std_logic;
		ram_cas_n: out std_logic;
		ram_we_n: out std_logic;
		ram_dm: out std_logic;
		ram_udqs: inout std_logic;
		ram_rzq: inout std_logic;
		ram_udm: out std_logic;
		ram_dqs: inout std_logic;
		ram_ck: out std_logic;
		ram_ck_n: out std_logic
	);
end top_level;


architecture Behavioral of top_level is
	-- clocks
	signal clk_main, clk_pixel: std_logic;
	signal clk_mem: memory_clock_signals;

	-- memory
	signal memory_ready: std_logic := '0';

	signal read_write_port_s: memory_port;
	signal read_write_status_s: memory_port_status;

	--signal boot_ram_port: bram_port_32b;
	--signal boot_ram_read_data: std_logic_vector(31 downto 0);

	--signal font_ram_port: bram_port_32b;
	--signal font_ram_read_data: std_logic_vector(31 downto 0);

	--signal font_read_port: bram_port_8b;
	--signal font_read_data: std_logic_vector(7 downto 0);

	signal textbuffer_ram_port: bram_port_32b;
	signal textbuffer_ram_read_data: std_logic_vector(31 downto 0);

	signal textbuffer_read_port: bram_port_8b;
	signal textbuffer_read_data: std_logic_vector(7 downto 0);

	-- vga
	signal vga: vga_signals;

	-- ram
	signal ram: ram_signals;
	signal ram_bus: ram_bus_signals;
	
	signal dram_p0: dram_port;
	signal dram_p0_status: dram_port_status;
	
	signal dram_p1: dram_port;
	signal dram_p1_status: dram_port_status;
	
	signal calib_done: std_logic;

	component clock_generator is
		port(
			clk_in: in std_logic;
			clk_main: out std_logic;
			clk_mem: out memory_clock_signals;
			clk_pixel: out std_logic
		);
	end component;

	component core is
		port(
			clk: in std_logic;
			memory_ready_in: in std_logic;
			data_port_out: out memory_port;
			data_port_status_in: in memory_port_status;
			leds_out: out std_logic_vector(0 to 7)
		);
	end component;

	component memory_interface is
		port(
			clk: in std_logic;
			mem_p0_in: in memory_port := DEFAULT_MEMORY_PORT;
			mem_p0_status_out: out memory_port_status := DEFAULT_MEMORY_PORT_STATUS;
			dram_p0_out: out dram_port := DEFAULT_DRAM_PORT;
			dram_p0_status_in: in dram_port_status;
			--bootram_port_out: out bram_port_32b := DEFAULT_BRAM_PORT_32B;
			--bootram_data_in: in std_logic_vector(31 downto 0);
			--fontram_port_out: out bram_port_32b := DEFAULT_BRAM_PORT_32B;
			--fontram_data_in: in std_logic_vector(31 downto 0);
			textbuffer_port_out: out bram_port_32b := DEFAULT_BRAM_PORT_32B;
			textbuffer_data_in: in std_logic_vector(31 downto 0);
			calib_done_in: in std_logic;
			memory_ready_out: out std_logic
		);
	end component;

	component dram_interface is
		port(
			clks_in: in memory_clock_signals;
			p0_cmd_clk_in: in std_logic;
			p0_read_clk_in: in std_logic;
			p0_write_clk_in: in std_logic;
			p0_in: in dram_port;
			p0_status_out: out dram_port_status;
			p1_cmd_clk_in: in std_logic;
			p1_read_clk_in: in std_logic;
			p1_write_clk_in: in std_logic;
			p1_in: in dram_port;
			p1_status_out: out dram_port_status;
			ram_out: out ram_signals;
			ram_bus: inout ram_bus_signals;
			calib_done_out: out std_logic;
			reset_in: in std_logic
		);
	end component;

	--component boot_ram is
	--	port(
	--		clk_0: in std_logic;
	--		port_0: in bram_port_32b;
	--		p0_read_data: out std_logic_vector(31 downto 0);
	--		clk_1: in std_logic;
	--		port_1: in bram_port_32b;
	--		p1_read_data: out std_logic_vector(31 downto 0)
	--	);
	--end component;

	--component font_ram is
	--	port(
	--		clk_0: in std_logic;
	--		port_0: in bram_port_32b;
	--		p0_read_data: out std_logic_vector(31 downto 0);
	--		clk_1: in std_logic;
	--		port_1: in bram_port_8b;
	--		p1_read_data: out std_logic_vector(7 downto 0)
	--	);
	--end component;

	component textbuffer_ram is
		port(
			clk_0: in std_logic;
			port_0: in bram_port_32b;
			p0_read_data: out std_logic_vector(31 downto 0);
			clk_1: in std_logic;
			port_1: in bram_port_8b;
			p1_read_data: out std_logic_vector(7 downto 0)
		);
	end component;

	--component vga_generator is
	--	port(
	--		clk: in std_logic;
	--		memory_ready_in: in std_logic;
	--		vga_out: out vga_signals;
	--		dram_port_out: out dram_port;
	--		dram_port_status_in: in dram_port_status
	--	);
	--end component;

	component textmode_vga_generator is
		port(
			clk: in std_logic;
			textbuffer_read_port_out: out bram_port_8b;
			textbuffer_read_data_in: in std_logic_vector(7 downto 0);
			--font_read_port_out: out bram_port_8b;
			--font_read_data_in: in std_logic_vector(7 downto 0);
			vga_out: out vga_signals
		);
	end component;

begin
	-- disable seven segment display to prevent ghosting
	seven_segment_enable <= "000";
	seven_segment <= "11111111";

	clock_generator_inst: clock_generator port map(
		clk_in => clk_sys,
		clk_main => clk_main,
		clk_mem => clk_mem,
		clk_pixel => clk_pixel
	);

	core_inst: core port map(
		clk => clk_main,
		memory_ready_in => memory_ready,
		data_port_out => read_write_port_s,
		data_port_status_in => read_write_status_s,
		leds_out => leds_out
	);

	memory_interface_inst: memory_interface port map(
		clk => clk_main,
		mem_p0_in => read_write_port_s,
		mem_p0_status_out => read_write_status_s,
		dram_p0_out => dram_p0,
		dram_p0_status_in => dram_p0_status,
		--bootram_port_out => boot_ram_port,
		--bootram_data_in => boot_ram_read_data,
		--fontram_port_out => font_ram_port,
		--fontram_data_in => font_ram_read_data,
		textbuffer_port_out => textbuffer_ram_port,
		textbuffer_data_in => textbuffer_ram_read_data,
		calib_done_in => calib_done,
		memory_ready_out => memory_ready
	);
	
	dram_interface_inst: dram_interface port map(
		clks_in => clk_mem,
		p0_cmd_clk_in => clk_main,
		p0_read_clk_in => clk_main,
		p0_write_clk_in => clk_main,
		p0_in => dram_p0,
		p0_status_out => dram_p0_status,
		p1_cmd_clk_in => clk_pixel,
		p1_read_clk_in => clk_pixel,
		p1_write_clk_in => clk_pixel,
		p1_in => dram_p1,
		p1_status_out => dram_p1_status,
		ram_out => ram,
		ram_bus => ram_bus,
		calib_done_out => calib_done,
		reset_in => '0'
	);	

	--boot_ram_inst: boot_ram port map(
	--	clk_0 => clk_main,
	--	port_0 => boot_ram_port,
	--	p0_read_data => boot_ram_read_data,
	--	clk_1 => '0',
	--	port_1 => DEFAULT_BRAM_PORT_32B,
	--	p1_read_data => open
	--);

	--font_ram_inst: font_ram port map(
	--	clk_0 => clk_main,
	--	port_0 => font_ram_port,
	--	p0_read_data => font_ram_read_data,
	--	clk_1 => clk_pixel,
	--	port_1 => font_read_port,
	--	p1_read_data => font_read_data
	--);

	textbuffer_ram_inst: textbuffer_ram port map(
		clk_0 => clk_main,
		port_0 => textbuffer_ram_port,
		p0_read_data => textbuffer_ram_read_data,
		clk_1 => clk_pixel,
		port_1 => textbuffer_read_port,
		p1_read_data => textbuffer_read_data
	);

	--vga_generator_inst: vga_generator port map(
	--	clk => clk_pixel,
	--	memory_ready_in => memory_ready,
	--	vga_out => vga,
	--	dram_port_out => dram_p1,
	--	dram_port_status_in => dram_p1_status
	--);

	textmode_vga_generator_inst: textmode_vga_generator port map(
		clk => clk_pixel,
		textbuffer_read_port_out => textbuffer_read_port,
		textbuffer_read_data_in => textbuffer_read_data,
		--font_read_port_out => font_read_port,
		--font_read_data_in => font_read_data,
		vga_out => vga
	);

	vga_hsync <= vga.hsync;
	vga_vsync <= vga.vsync;
	vga_red <= vga.red;
	vga_green <= vga.green;
	vga_blue <= vga.blue;

	--leds_out <= read_status.overflow & read_status.error & read_write_status_s.read_overflow & read_write_status_s.read_error & read_write_status_s.write_underrun & read_write_status_s.write_error & "00";

	ram_a <= ram.a;
	ram_ba <= ram.ba;
	ram_cke <= ram.cke;
	ram_ras_n <= ram.ras_n;
	ram_cas_n <= ram.cas_n;
	ram_we_n <= ram.we_n;
	ram_dm <= ram.dm;
	ram_udm <= ram.udm;
	ram_ck <= ram.ck;
	ram_ck_n <= ram.ck_n;
	ram_dq <= ram_bus.dq;
	ram_udqs <= ram_bus.udqs;
	ram_dqs <= ram_bus.dqs;
	ram_rzq <= ram_bus.rzq;
end Behavioral;
