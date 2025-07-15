`timescale 1ns / 1ps

module adc_to_heart_rate_converter_tb;

    // Inputs
    reg clk = 0;
    reg reset;
    reg [9:0] adc_in;
    reg [7:0] max_heart_rate_possible;
    reg [31:0] max_continous_checks;
    reg measuring;
    reg [7:0] min_heart_threshold;
    reg [7:0] max_heart_threshold;

    // Outputs
    wire [7:0] heart_beats_count;
    wire [7:0] heart_beats_without_violations;
    wire [7:0] min_heart_beats_threshold_violations;
    wire [7:0] max_heart_beats_threshold_violations;
    wire [7:0] heart_rate_avg;
    wire [7:0] heart_beat_val_live;
    wire [31:0] heart_rate_sum;

    // Instantiate DUT
    adc_to_heart_rate_converter uut (
        .clk(clk),
        .reset(reset),
        .adc_in(adc_in),
        .max_heart_rate_possible(max_heart_rate_possible),
        .max_continous_checks(max_continous_checks),
        .measuring(measuring),
        .min_heart_threshold(min_heart_threshold),
        .max_heart_threshold(max_heart_threshold),
        .heart_beats_count(heart_beats_count),
        .heart_beats_without_violations(heart_beats_without_violations),
        .min_heart_beats_threshold_violations(min_heart_beats_threshold_violations),
        .max_heart_beats_threshold_violations(max_heart_beats_threshold_violations),
        .heart_rate_avg(heart_rate_avg),
        .heart_beat_val_live(heart_beat_val_live),
        .heart_rate_sum(heart_rate_sum)
    );

    // Clock generation
    always #10 clk = ~clk;  // 50 MHz clock (20ns period)

    integer i;

    initial begin
        $dumpfile("adc_to_heart_rate_converter_tb.vcd");
        $dumpvars(0, adc_to_heart_rate_converter_tb);

        // Initial setup
        reset = 1;
        adc_in = 10'd0;
        max_heart_rate_possible = 8'd220;
        max_continous_checks = 10;
        measuring = 0;
        min_heart_threshold = 8'd60;
        max_heart_threshold = 8'd160;

        // Apply reset
        #30 reset = 0;
        #10 measuring = 1;

        // Feed ADC samples (simulate 10 heartbeats: some below, within, above range)
        for (i = 0; i < 10; i = i + 1) begin
            case (i % 3)
                0: adc_in = 10'd100;  // Low → below threshold
                1: adc_in = 10'd450;  // Normal → within threshold
                2: adc_in = 10'd900;  // High → above threshold
            endcase
            #20;  // One clock
        end

        // Let averaging happen
        measuring = 0;
        #100;

        // Show results
        $display("Heart beats counted:             %d", heart_beats_count);
        $display("Within range (valid):            %d", heart_beats_without_violations);
        $display("Below min threshold violations:  %d", min_heart_beats_threshold_violations);
        $display("Above max threshold violations:  %d", max_heart_beats_threshold_violations);
        $display("Average heart rate:              %d", heart_rate_avg);
        $display("Final heart rate sum:            %d", heart_rate_sum);

        $finish;
    end

endmodule
