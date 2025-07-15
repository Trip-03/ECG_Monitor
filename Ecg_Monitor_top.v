module heartbeat_monitor_top(
    input wire clk,
    input wire reset,
    input wire on,
    input wire [9:0] adc_in,        // 10-bit ADC input
    input wire [9:0] age,           // Patient age in years

    // 7-Segment Display Outputs
    output wire [6:0] seg_display_heart_rate_avg_0,
    output wire [6:0] seg_display_heart_rate_avg_1,
    output wire [6:0] seg_display_heart_rate_avg_2,
    output wire [6:0] seg_display_heart_beats_count_0,
    output wire [6:0] seg_display_heart_beats_count_1,
    output wire [6:0] seg_display_heart_beats_count_2,
    output wire [6:0] seg_display_heart_beats_without_violations_0,
    output wire [6:0] seg_display_heart_beats_without_violations_1,
    output wire [6:0] seg_display_heart_beats_without_violations_2,
    output wire [6:0] seg_display_min_heart_beats_threshold_violations_0,
    output wire [6:0] seg_display_min_heart_beats_threshold_violations_1,
    output wire [6:0] seg_display_min_heart_beats_threshold_violations_2,
    output wire [6:0] seg_display_max_heart_beats_threshold_violations_0,
    output wire [6:0] seg_display_max_heart_beats_threshold_violations_1,
    output wire [6:0] seg_display_max_heart_beats_threshold_violations_2,

    // Data outputs for debugging or testing
    output wire [7:0] heart_rate_avg,
    output wire [7:0] heart_rate_val_live,
    output wire [7:0] heart_beats_count,
    output wire [7:0] heart_beats_count_without_violations,
    output wire [7:0] min_heart_beats_threshold_violations,
    output wire [7:0] max_heart_beats_threshold_violations,

    output reg [7:0] heart_rate_avg_out,
    output reg [7:0] heart_rate_val_live_out,
    output reg [7:0] heart_beats_count_out,
    output reg [7:0] heart_beats_count_without_violations_out,
    output reg [7:0] min_heart_beats_threshold_violations_out,
    output reg [7:0] max_heart_beats_threshold_violations_out,

    // Control signals
    output wire measuring_control_signal,
    output wire displaying_control_signal,

    // Alerts
    output wire buzzer_high_threshold_violation,
    output wire buzzer_low_threshold_violation,

    // Status LEDs
    output wire green_led,
    output wire led_red,
    output wire led_blue
);

    // FSM States
    parameter [1:0] idle = 2'b00;
    parameter [1:0] measure = 2'b01;
    parameter [1:0] display = 2'b10;

    parameter [31:0] display_duration = 32'h00000006;
    parameter [7:0] max_heart_rate_possible = 8'd220;
    parameter [7:0] max_continous_checks = 8'hFF;

    reg [1:0] state, next_state;
    reg [31:0] timer;

    reg [7:0] min_heart_threshold;
    reg [7:0] max_heart_threshold;

    wire done;

    // Threshold Calculation
    always @(posedge clk) begin
        if (reset) begin
            state <= idle;
            timer <= 0;
            min_heart_threshold <= (220 - age) / 2;
            max_heart_threshold <= ((220 - age) * 85) / 100;
        end else begin
            state <= next_state;
        end
    end

    // FSM Next State Logic
    always @(*) begin
        case (state)
            idle:
                next_state = on ? measure : idle;
            measure:
                next_state = done ? display : measure;
            display:
                next_state = (timer < display_duration) ? display : idle;
            default:
                next_state = idle;
        endcase
    end

    // FSM Timer Logic
    always @(posedge clk) begin
        if (state == display)
            timer <= timer + 1;
        else
            timer <= 0;
    end

    // Register Captures on Done
    always @(posedge clk) begin
        if (state == measure && done) begin
            heart_rate_avg_out <= heart_rate_avg;
            heart_rate_val_live_out <= heart_rate_val_live;
            heart_beats_count_out <= heart_beats_count;
            heart_beats_count_without_violations_out <= heart_beats_count_without_violations;
            min_heart_beats_threshold_violations_out <= min_heart_beats_threshold_violations;
            max_heart_beats_threshold_violations_out <= max_heart_beats_threshold_violations;
        end
    end

    // Instantiate Heart Rate Converter
    adc_to_heart_rate_converter heart_rate_converter (
        .clk(clk),
        .reset(reset),
        .max_continous_checks(max_continous_checks),
        .adc_in(adc_in),
        .max_heart_rate_possible(max_heart_rate_possible),
        .measuring(measuring_control_signal),
        .min_heart_threshold(min_heart_threshold),
        .max_heart_threshold(max_heart_threshold),
        .heart_beats_count(heart_beats_count),
        .heart_beats_without_violations(heart_beats_count_without_violations),
        .min_heart_beats_threshold_violations(min_heart_beats_threshold_violations),
        .max_heart_beats_threshold_violations(max_heart_beats_threshold_violations),
        .heart_rate_avg(heart_rate_avg),
        .heart_beat_val_live(heart_rate_val_live),
        .done(done)
    );

    // Instantiate Display Module
    heart_rate_display display_unit (
        .clk(clk),
        .reset(reset),
        .timer(timer),
        .displaying(displaying_control_signal),
        .heart_rate_avg(heart_rate_avg_out),
        .heart_beats_count(heart_beats_count_out),
        .heart_beats_without_violations(heart_beats_count_without_violations_out),
        .min_heart_beats_threshold_violations(min_heart_beats_threshold_violations_out),
        .max_heart_beats_threshold_violations(max_heart_beats_threshold_violations_out),
        .seg_display_heart_rate_avg_0(seg_display_heart_rate_avg_0),
        .seg_display_heart_rate_avg_1(seg_display_heart_rate_avg_1),
        .seg_display_heart_rate_avg_2(seg_display_heart_rate_avg_2),
        .seg_display_heart_beats_count_0(seg_display_heart_beats_count_0),
        .seg_display_heart_beats_count_1(seg_display_heart_beats_count_1),
        .seg_display_heart_beats_count_2(seg_display_heart_beats_count_2),
        .seg_display_heart_beats_without_violations_0(seg_display_heart_beats_without_violations_0),
        .seg_display_heart_beats_without_violations_1(seg_display_heart_beats_without_violations_1),
        .seg_display_heart_beats_without_violations_2(seg_display_heart_beats_without_violations_2),
        .seg_display_min_heart_beats_threshold_violations_0(seg_display_min_heart_beats_threshold_violations_0),
        .seg_display_min_heart_beats_threshold_violations_1(seg_display_min_heart_beats_threshold_violations_1),
        .seg_display_min_heart_beats_threshold_violations_2(seg_display_min_heart_beats_threshold_violations_2),
        .seg_display_max_heart_beats_threshold_violations_0(seg_display_max_heart_beats_threshold_violations_0),
        .seg_display_max_heart_beats_threshold_violations_1(seg_display_max_heart_beats_threshold_violations_1),
        .seg_display_max_heart_beats_threshold_violations_2(seg_display_max_heart_beats_threshold_violations_2)
    );

    // Control Signals
    assign measuring_control_signal = (state == measure);
    assign displaying_control_signal = (state == display);

    // Buzzer & LED Alarms
    assign buzzer_high_threshold_violation = displaying_control_signal && (heart_rate_avg_out > max_heart_threshold);
    assign buzzer_low_threshold_violation  = displaying_control_signal && (heart_rate_avg_out < min_heart_threshold);

    assign green_led = displaying_control_signal && (heart_rate_avg_out >= min_heart_threshold && heart_rate_avg_out <= max_heart_threshold);
    assign led_red   = displaying_control_signal && (heart_rate_avg_out > max_heart_threshold);
    assign led_blue  = displaying_control_signal && (heart_rate_avg_out < min_heart_threshold);

endmodule
