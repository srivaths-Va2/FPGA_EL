module KNN #(parameter K = 3, parameter NUM_POINTS = 8, parameter WIDTH = 8)(
    input [WIDTH-1:0] query_x,
    input [WIDTH-1:0] query_y,
    input [NUM_POINTS*WIDTH-1:0] train_x,  // Flattened 2D array to 1D vector
    input [NUM_POINTS*WIDTH-1:0] train_y,  // Flattened 2D array to 1D vector
    input [NUM_POINTS*2-1:0] train_labels, // Flattened 2D array to 1D vector for 2-bit labels
    output reg [1:0] predicted_label
);
    integer i, j;
    reg [WIDTH*2-1:0] distances [NUM_POINTS-1:0];
    reg [WIDTH*2-1:0] sorted_distances [NUM_POINTS-1:0];
    reg [1:0] sorted_labels [NUM_POINTS-1:0];
    reg [1:0] labels [NUM_POINTS-1:0]; // Separate array for labels after extraction
    reg [WIDTH-1:0] train_x_arr [NUM_POINTS-1:0];
    reg [WIDTH-1:0] train_y_arr [NUM_POINTS-1:0];
    reg [3:0] label_count [0:3];  // Array to count labels using `reg` instead of `integer`
    reg [3:0] max_count;          // Maximum count of labels
    reg [WIDTH*2-1:0] temp_distance; // Temporary variables for swapping
    reg [1:0] temp_label;

    always @(*) begin
        // Initialize label counts to 0
        for (i = 0; i < 4; i = i + 1) begin
            label_count[i] = 0;
        end

        // Flattened arrays to 1D vectors
        for (i = 0; i < NUM_POINTS; i = i + 1) begin
            train_x_arr[i] = train_x[(i+1)*WIDTH-1 -: WIDTH];
            train_y_arr[i] = train_y[(i+1)*WIDTH-1 -: WIDTH];
            labels[i] = train_labels[(i+1)*2-1 -: 2];
        end

        // Compute the square of the Euclidean distance
        for (i = 0; i < NUM_POINTS; i = i + 1) begin
            distances[i] = (train_x_arr[i] - query_x) * (train_x_arr[i] - query_x) + 
                           (train_y_arr[i] - query_y) * (train_y_arr[i] - query_y);
        end
        
        // Copy distances and labels for sorting
        for (i = 0; i < NUM_POINTS; i = i + 1) begin
            sorted_distances[i] = distances[i];
            sorted_labels[i] = labels[i];
        end

        // Bubble Sort to sort distances and labels together
        for (i = 0; i < NUM_POINTS-1; i = i + 1) begin
            for (j = 0; j < NUM_POINTS-i-1; j = j + 1) begin
                if (sorted_distances[j] > sorted_distances[j+1]) begin
                    // Swap distances
                    temp_distance = sorted_distances[j];
                    sorted_distances[j] = sorted_distances[j+1];
                    sorted_distances[j+1] = temp_distance;

                    // Swap corresponding labels
                    temp_label = sorted_labels[j];
                    sorted_labels[j] = sorted_labels[j+1];
                    sorted_labels[j+1] = temp_label;
                end
            end
        end

        // Majority voting for the K nearest neighbors
        for (i = 0; i < K; i = i + 1) begin
            label_count[sorted_labels[i]] = label_count[sorted_labels[i]] + 1;
        end

        // Find the label with the maximum count
        predicted_label = 2'b00;
        max_count = 0;
        for (i = 0; i < 4; i = i + 1) begin
            if (label_count[i] > max_count) begin
                max_count = label_count[i];
                predicted_label = i[1:0];
            end
        end
    end
endmodule
