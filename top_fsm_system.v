`timescale 1ns / 1ps

module top_fsm_system #(
    parameter SIM_FAST = 0
)(
    input         clk_100m,
    input         rst_fsm_btn,
    input         rst_cpu_btn,
    input  [15:0] sw_input,
    output [15:0] led_output
);
    // Clock Divider (100MHz to 10MHz)
    wire clk_10m;
    clk_div_10mhz #(.RATIO(10), .USE_BUFFER(SIM_FAST ? 0 : 1)) clock_gen (
        .clk_100m(clk_100m),
        .clk_10m (clk_10m)
    );

    // CPU Reset Synchronization
    reg cpu_rst_meta = 1'b0, cpu_rst_sync = 1'b0;
    always @(posedge clk_10m) begin
        cpu_rst_meta <= rst_cpu_btn;
        cpu_rst_sync <= cpu_rst_meta;
    end

    // RISC-V Core Signals
    wire [31:0] p_inst_addr, p_inst_data;
    wire        p_mem_we, p_mem_re;
    wire [31:0] p_data_addr, p_data_din, p_data_dout;

    rv32i_cpu processor (
        .clk          (clk_10m),
        .rst          (cpu_rst_sync),
        .inst_addr    (p_inst_addr),
        .inst_data    (p_inst_data),
        .mem_we       (p_mem_we),
        .mem_re       (p_mem_re),
        .data_addr    (p_data_addr),
        .data_din     (p_data_din),
        .data_dout    (p_data_dout)
    );

    // Instruction Memory
    instructionMemory #(.OPERAND_LENGTH(31), .SIM_FAST(SIM_FAST)) imem (
        .instAddress(p_inst_addr),
        .instruction(p_inst_data)
    );

    // Memory-Mapped I/O Decoding
    wire en_ram, en_led, en_sw, en_rst;
    addr_decode memory_mapper (
        .address_in(p_data_addr),
        .en_ram    (en_ram),
        .en_led    (en_led),
        .en_sw     (en_sw),
        .en_rst    (en_rst)
    );

    // Stack RAM
    wire [31:0] ram_read_val;
    ram_1kb stack_memory (
        .sys_clk(clk_10m),
        .we     (p_mem_we & en_ram),
        .addr   (p_data_addr),
        .din    (p_data_din),
        .dout   (ram_read_val)
    );

    // Peripherals
    wire [15:0] sw_clean, led_state;
    wire        btn_clean;
    io_sync_regs peripherals (
        .sys_clk  (clk_10m),
        .raw_sw   (sw_input),
        .raw_btn  (rst_fsm_btn),
        .we_led   (p_mem_we & en_led),
        .din_led  (p_data_din[15:0]),
        .clean_sw (sw_clean),
        .clean_btn(btn_clean),
        .out_led  (led_state)
    );
    assign led_output = led_state;

    // Read Data Mux
    assign p_data_dout = en_ram ? ram_read_val :
                         en_sw  ? {16'd0, sw_clean} :
                         en_rst ? {31'd0, btn_clean} :
                         en_led ? {16'd0, led_state} : 32'd0;
endmodule