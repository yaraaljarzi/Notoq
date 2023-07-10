<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");

// Establish a database connection
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tts_database";

$conn = new mysqli($servername, $username, $password, $dbname);

// Check for connection errors
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Retrieve user data from the POST request
$data = json_decode(file_get_contents('php://input'), true);
$email = isset($data['email']) ? $conn->real_escape_string($data['email']) : '';
$password = isset($data['password']) ? $conn->real_escape_string($data['password']) : '';

// Check if email and password are provided
if (empty($email) || empty($password)) {
    $response = array('status' => 'error', 'message' => 'Please provide both email and password');
    // Return the response as a JSON object
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}

// Check if user exists in the database
$sql = "SELECT user_id, user_password FROM user_account WHERE user_email = '$email'";
$result = $conn->query($sql);

if (!$result) {
    // Query failed, display an error message
    $response = array('status' => 'error', 'message' => 'Query failed: ' . $conn->error);
} else if ($result->num_rows > 0) {
    // User exists, check if the password is correct
    $row = $result->fetch_assoc();
    $hashed_password = $row['user_password'];
    if (password_verify($password, $hashed_password)) {
        // Password is correct, login the user
        $user_id = $row['user_id'];
        $response = array('status' => 'success', 'message' => 'User logged in successfully', 'user_id' => $user_id);
    } else {
        // Password is incorrect, display an error message
        $response = array('status' => 'error', 'message' => 'Incorrect password');
    }
} else {
    // User does not exist, display an error message
    $response = array('status' => 'error', 'message' => 'User does not exist');
}

// Close the database connection
$conn->close();


header('Content-Type: application/json');
echo json_encode($response);

?>
