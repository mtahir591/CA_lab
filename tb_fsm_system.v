`timescale 1ns / 1ps

module tb_fsm_system;
    reg         clk_sys = 1'b0;
    reg         btn_fsm = 1'b0; 
    reg         btn_cpu = 1'b0;  
    reg  [15:0] sw_val  = 16'd0;
    wire [15:0] led_val;

    top_fsm_system #(.SIM_FAST(1)) uut (
        .clk_100m   (clk_sys),
        .rst_fsm_btn(btn_fsm),
        .rst_cpu_btn(btn_cpu),
        .sw_input   (sw_val),
        .led_output (led_val)
    );

    always #5 clk_sys = ~clk_sys; 

    integer err_count = 0;

    always @(led_val) $display("[%0t ns] Output LED updated: %0d", $time, led_val);

    task await_led_val(input [15:0] target_val);
        integer wait_cycles;
        begin
            wait_cycles = 0;
            while ((led_val !== target_val) && (wait_cycles < 100000)) begin
                @(posedge clk_sys);
                wait_cycles = wait_cycles + 1;
            end
            if (led_val !== target_val) begin
                $display("ERROR: Timeout waiting for LED = %0d", target_val);
                err_count = err_count + 1;
            end
        end
    endtask

    task assert_led(input [15:0] expected_val, input [511:0] info_msg);
        begin
            if (led_val !== expected_val) begin
                $display("FAIL: %0s (Expected: %0d, Actual: %0d)", info_msg, expected_val, led_val);
                err_count = err_count + 1;
            end else begin
                $display("PASS: %0s", info_msg);
            end
        end
    endtask

    reg watch_ignore = 1'b0;
    always @(led_val) if (watch_ignore && led_val === 16'd9) begin
        $display("FAIL: Switch input not ignored during FSM countdown");
        err_count = err_count + 1;
    end

    initial begin
        $display("=== STARTING FSM VERIFICATION ===");
        repeat (200) @(posedge clk_sys);

        $display("-> Test 1: Idle state (switches = 0)");
        repeat (2000) @(posedge clk_sys);
        assert_led(16'd0, "LEDs stay off when no input provided");

        $display("-> Test 2: Basic Countdown (switches = 5)");
        sw_val = 16'd5;
        await_led_val(16'd5);
        assert_led(16'd5, "LEDs latched input value");
        watch_ignore = 1'b1;
        sw_val = 16'd9; // Change input, should be ignored
        await_led_val(16'd4);
        await_led_val(16'd3);
        sw_val = 16'd0;
        await_led_val(16'd2);
        await_led_val(16'd1);
        await_led_val(16'd0);
        watch_ignore = 1'b0;
        repeat (3000) @(posedge clk_sys);
        assert_led(16'd0, "System returned to idle state");

        $display("-> Test 3: Hardware Reset Interrupt");
        sw_val = 16'd7;
        await_led_val(16'd7);
        await_led_val(16'd6);
        await_led_val(16'd5);
        btn_fsm = 1'b1; 
        repeat (400) @(posedge clk_sys); 
        assert_led(16'd0, "LEDs cleared via hardware reset");
        sw_val = 16'd0;
        btn_fsm = 1'b0; 
        repeat (10000) @(posedge clk_sys);
        assert_led(16'd0, "System remained idle after interrupt");

        $display("-> Test 4: Re-arming FSM");
        sw_val = 16'd3;
        await_led_val(16'd3);
        sw_val = 16'd0;
        await_led_val(16'd2);
        await_led_val(16'd1);
        await_led_val(16'd0);
        repeat (3000) @(posedge clk_sys);
        assert_led(16'd0, "Second countdown completed successfully");

        $display("-> Test 5: CPU Core Reset");
        sw_val = 16'd6;
        await_led_val(16'd6);
        await_led_val(16'd5);
        sw_val = 16'd0;
        btn_cpu = 1'b1;
        repeat (100) @(posedge clk_sys);
        btn_cpu = 1'b0;
        repeat (3000) @(posedge clk_sys);
        assert_led(16'd0, "CPU hard reset caught and FSM returned to 0");

        if (err_count == 0) $display("=== ALL VERIFICATION TESTS PASSED ===");
        else                $display("=== FINISHED WITH %0d ERRORS ===", err_count);
        $finish;
    end
endmodule