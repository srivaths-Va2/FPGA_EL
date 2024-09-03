`timescale 1ns/1ns
`include "KNN.v"

module tb_KNN();
    parameter K = 3;
    parameter NUM_POINTS = 8;
    parameter WIDTH = 8;

    reg [WIDTH-1:0] query_x;
    reg [WIDTH-1:0] query_y;
    reg [NUM_POINTS*WIDTH-1:0] train_x;
    reg [NUM_POINTS*WIDTH-1:0] train_y;
    reg [NUM_POINTS*2-1:0] train_labels;
    wire [1:0] predicted_label;

    // Instantiate the KNN module
    KNN #(.K(K), .NUM_POINTS(NUM_POINTS), .WIDTH(WIDTH)) knn_inst(
        .query_x(query_x),
        .query_y(query_y),
        .train_x(train_x),
        .train_y(train_y),
        .train_labels(train_labels),
        .predicted_label(predicted_label)
    );

    initial begin
        $dumpfile("tb_KNN.vcd");
        $dumpvars(0, tb_KNN);
        // Initialize training data points and labels
        train_x = {8'd2, 8'd4, 8'd6, 8'd8, 8'd1, 8'd3, 8'd5, 8'd7};
        train_y = {8'd1, 8'd3, 8'd5, 8'd7, 8'd2, 8'd4, 8'd6, 8'd8};
        train_labels = {2'b00, 2'b01, 2'b10, 2'b11, 2'b00, 2'b01, 2'b10, 2'b11};

        // First Query point - should predict '00'
        query_x = 8'd2;
        query_y = 8'd1;
        #10;
        $display("Query Point: (%d, %d), Predicted Label: %b", query_x, query_y, predicted_label);

        // Second Query point - should predict '01'
        query_x = 8'd5;
        query_y = 8'd5;
        #10;
        $display("Query Point: (%d, %d), Predicted Label: %b", query_x, query_y, predicted_label);

        // Third Query point - should predict '10'
        query_x = 8'd8;
        query_y = 8'd8;
        #10;
        $display("Query Point: (%d, %d), Predicted Label: %b", query_x, query_y, predicted_label);

        $stop;
    end
endmodule
