<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Credentials: true");
header("Access-Control-Allow-Methods: GET");

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
$name = $_POST['user_name'];
$email = $_POST['user_email'];
$password = $_POST['user_password'];

// Check if the email is already taken
$check_email_sql = "SELECT * FROM user_account WHERE user_email = '$email'";
$result = $conn->query($check_email_sql);
if ($result->num_rows > 0) {
    $response = array('status' => 'error', 'message' => 'Email is already taken');
    echo json_encode($response);
    exit();
}

// Hash the password for security
$hashed_password = password_hash($password, PASSWORD_DEFAULT);

// Insert user data into the database.
$sql = "INSERT INTO user_account (user_name, user_email, user_password) VALUES ('$name', '$email', '$hashed_password')";

// Modify the response to return a JSON object
if ($conn->query($sql) === TRUE) {
    $user_id = $conn->insert_id;
    $response = array('status' => 'success', 'message' => 'User created successfully', 'user_id' => $user_id);
    echo json_encode($response);
} else {
    $response = array('status' => 'error', 'message' => 'Error creating user');
    echo json_encode($response);
}

// Close the database connection
$conn->close();

?>
