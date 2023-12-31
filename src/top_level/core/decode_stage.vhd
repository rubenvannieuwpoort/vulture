library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.core_types.all;
use work.core_constants.all;


entity decode_stage is
	port(
		clk: in std_logic;
		stall_in: in std_logic;
		input: in fetch_output_type;

		stall_out: out std_logic := '0';
		output: out decode_output_type := DEFAULT_DECODE_OUTPUT
	);
end decode_stage;


architecture Behavioral of decode_stage is
	signal buffered_input: fetch_output_type := DEFAULT_FETCH_OUTPUT;
begin
	stall_out <= buffered_input.valid;

	process(clk)
		variable v_input: fetch_output_type;
		variable v_output: decode_output_type;
	begin
		if rising_edge(clk) then
			-- select input
			if buffered_input.valid = '1' then
				v_input := buffered_input;
			else
				v_input := input;
			end if;

			if stall_in = '0' then
				-- output generation
				if v_input.valid = '1' then
					if v_input.opcode(31 downto 8) = "111111111111111111111111" then
						-- custom instruction (LEDs on)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_immediate := "000000000000000000000000" & v_input.opcode(7 downto 0);
						v_output.operand_1_register := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_LEDS;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(31 downto 8) = "111111111111111111111110" then
						-- custom instruction (LEDs on)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_1_register := v_input.opcode(4 downto 0);
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_LEDS;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110111" then
						-- LUI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_immediate := v_input.opcode(31 downto 12) & "000000000000";
						v_output.operand_1_register := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010111" then
						-- AUIPC (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := v_input.pc;
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := v_input.opcode(31 downto 12) & "000000000000";
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1101111" then
						-- JAL (done)
						-- puts pc in op1, offset in op2, and pc_next in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := v_input.pc;
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31) & v_input.opcode(19 downto 12) & v_input.opcode(20) & v_input.opcode(20) & v_input.opcode(30 downto 21) & "0"), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := v_input.pc_next;
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_JAL;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100111" and v_input.opcode(14 downto 12) = "000" then
						-- JALR (done)
						-- puts rs1 in op1, offset in op2, and pc_next in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := v_input.pc_next;
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_JAL;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input.opcode(14 downto 12) = "000" then
						-- BEQ (done)
						-- puts rs1 in op1, rs2 in op2, and pc + offset in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(signed(v_input.pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_BEQ;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input.opcode(14 downto 12) = "001" then
						-- BNE (done)
						-- puts rs1 in op1, rs2 in op2, and pc + offset in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(signed(v_input.pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_BNE;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input.opcode(14 downto 12) = "100" then
						-- BLT (done)
						-- puts rs1 in op1, rs2 in op2, and pc + offset in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(signed(v_input.pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_BLT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input.opcode(14 downto 12) = "101" then
						-- BGE (done)
						-- puts rs1 in op1, rs2 in op2, and pc + offset in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(signed(v_input.pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_BGE;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input.opcode(14 downto 12) = "110" then
						-- BLTU (done)
						-- puts rs1 in op1, rs2 in op2, and pc + offset in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(signed(v_input.pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_BLTU;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1100011" and v_input.opcode(14 downto 12) = "111" then
						-- BGEU (done)
						-- puts rs1 in op1, rs2 in op2, and pc + offset in op3
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(signed(v_input.pc) + signed(v_input.opcode(31) & v_input.opcode(7) & v_input.opcode(30 downto 25) & v_input.opcode(11 downto 8) & "0"));
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_BGEU;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					-- TODO (MEMORY STUFF)
					elsif v_input.opcode(6 downto 0) = "0000011" and v_input.opcode(14 downto 12) = "000" then
						-- LB (done)
						-- sign extends byte at address rs1 + immediate and loads into destination
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_LOAD_BYTE;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0000011" and v_input.opcode(14 downto 12) = "001" then
						-- LH (done)
						-- sign extends halfword at address rs1 + immediate and loads into destination
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_LOAD_HALFWORD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0000011" and v_input.opcode(14 downto 12) = "010" then
						-- LW (done)
						-- take word at address rs1 + immediate and loads into destination
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_LOAD_WORD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0000011" and v_input.opcode(14 downto 12) = "100" then
						-- LBU (done)
						-- take byte at address rs1 + immediate and loads into destination
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_LOAD_BYTE_UNSIGNED;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0000011" and v_input.opcode(14 downto 12) = "101" then
						-- LHU (TODO)
						-- take halfword at address rs1 + immediate and loads into destination
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_LOAD_HALFWORD_UNSIGNED;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0100011" and v_input.opcode(14 downto 12) = "000" then
						-- SB (done)
						-- stores low bits in rs2 at address rs1 + immediate
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 25) & v_input.opcode(11 downto 7)), 32));
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_STORE_BYTE;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0100011" and v_input.opcode(14 downto 12) = "001" then
						-- SH (done)
						-- stores low bits in rs2 at address rs1 + immediate
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 25) & v_input.opcode(11 downto 7)), 32));
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_STORE_HALFWORD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0100011" and v_input.opcode(14 downto 12) = "010" then
						-- SW (done)
						-- stores rs2 at address rs1 + immediate
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 25) & v_input.opcode(11 downto 7)), 32));
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_STORE_WORD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "000" then
						-- ADDI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "010" then
						-- SLTI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SLT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "011" then
						-- SLTIU (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SLTU;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "100" then
						-- XORI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_XOR;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "110" then
						-- ORI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_OR;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "111" then
						-- ANDI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(signed(v_input.opcode(31 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_AND;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "001" and v_input.opcode(31 downto 25) = "0000000" then
						-- SLLI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(unsigned(v_input.opcode(24 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SHIFT_LEFT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "101" and v_input.opcode(31 downto 25) = "0000000" then
						-- SRLI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(unsigned(v_input.opcode(24 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SHIFT_RIGHT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0010011" and v_input.opcode(14 downto 12) = "101" and v_input.opcode(31 downto 25) = "0100000" then
						-- SRAI (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := std_logic_vector(resize(unsigned(v_input.opcode(24 downto 20)), 32));
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ARITHMETIC_SHIFT_RIGHT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "000" and v_input.opcode(31 downto 25) = "0000000" then
						-- ADD (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "000" and v_input.opcode(31 downto 25) = "0100000" then
						-- SUB (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SUB;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "001" and v_input.opcode(31 downto 25) = "0000000" then
						-- SLL (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SHIFT_LEFT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "010" and v_input.opcode(31 downto 25) = "0000000" then
						-- SLT (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SLT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "011" and v_input.opcode(31 downto 25) = "0000000" then
						-- SLTU (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SLTU;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "100" and v_input.opcode(31 downto 25) = "0000000" then
						-- XOR (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_XOR;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "101" and v_input.opcode(31 downto 25) = "0000000" then
						-- SRL (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_SHIFT_RIGHT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "101" and v_input.opcode(31 downto 25) = "0100000" then
						-- SRA (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ARITHMETIC_SHIFT_RIGHT;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "110" and v_input.opcode(31 downto 25) = "0000000" then
						-- OR (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_OR;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0110011" and v_input.opcode(14 downto 12) = "111" and v_input.opcode(31 downto 25) = "0000000" then
						-- AND (done)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_REGISTER;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := v_input.opcode(24 downto 20);
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_AND;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "0001111" and v_input.opcode(14 downto 12) = "000" then
						-- FENCE (implemented as NOP)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(31 downto 0) = "00000000000000000000000001110011" then
						-- ECALL (implemented as NOP)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(31 downto 0) = "00000000000100000000000001110011" then
						-- EBREAK (implemented as NOP)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1110011" and v_input.opcode(14 downto 12) = "001" then
						-- CSRRW
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := v_input.opcode(31 downto 20);
						v_output.alu_function := ALU_FUNCTION_CSRRW;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1110011" and v_input.opcode(14 downto 12) = "101" then
						-- CSRRWI
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := "000000000000000000000000000" & v_input.opcode(19 downto 15);
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := v_input.opcode(31 downto 20);
						v_output.alu_function := ALU_FUNCTION_CSRRW;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1110011" and v_input.opcode(14 downto 12) = "010" then
						-- CSRRS
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := v_input.opcode(31 downto 20);
						v_output.alu_function := ALU_FUNCTION_CSRRS;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1110011" and v_input.opcode(14 downto 12) = "110" then
						-- CSRRSI
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := "000000000000000000000000000" & v_input.opcode(19 downto 15);
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := v_input.opcode(31 downto 20);
						v_output.alu_function := ALU_FUNCTION_CSRRS;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1110011" and v_input.opcode(14 downto 12) = "011" then
						-- CSRRC
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_REGISTER;
						v_output.operand_1_register := v_input.opcode(19 downto 15);
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := v_input.opcode(31 downto 20);
						v_output.alu_function := ALU_FUNCTION_CSRRC;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(6 downto 0) = "1110011" and v_input.opcode(14 downto 12) = "111" then
						-- CSRRCI
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := "000000000000000000000000000" & v_input.opcode(19 downto 15);
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := v_input.opcode(11 downto 7);
						v_output.csr_register := v_input.opcode(31 downto 20);
						v_output.alu_function := ALU_FUNCTION_CSRRC;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					elsif v_input.opcode(31 downto 0) = "00110000001000000000000001110011" then
						-- TODO: MRET
					elsif v_input.opcode(31 downto 0) = "00010000010100000000000001110011" then
						-- WFI (implemented as NOP)
						v_output.valid := '1';
						v_output.illegal := '0';
						v_output.operand_1_type := TYPE_IMMEDIATE;
						v_output.operand_1_register := (others => '0');
						v_output.operand_1_immediate := (others => '0');
						v_output.operand_2_type := TYPE_IMMEDIATE;
						v_output.operand_2_immediate := (others => '0');
						v_output.operand_2_3_register := (others => '0');
						v_output.operand_3_type := TYPE_IMMEDIATE;
						v_output.operand_3_immediate := (others => '0');
						v_output.writeback_register := (others => '0');
						v_output.csr_register := (others => '0');
						v_output.alu_function := ALU_FUNCTION_ADD;
						v_output.stamp := v_input.stamp;
						v_output.tag := v_input.tag;
						v_output.pc := v_input.pc;
					else
						v_output := DEFAULT_DECODE_OUTPUT;
						v_output.illegal := '1';
						v_output.tag := v_input.tag;
					end if;
				else
					v_output := DEFAULT_DECODE_OUTPUT;
				end if;
				
				output <= v_output;
			end if;

			if v_input.valid = '1' and stall_in = '1' then
				buffered_input <= v_input;
			else
				buffered_input <= DEFAULT_FETCH_OUTPUT;
			end if;
		end if;
	end process;

end Behavioral;
