<?php

ini_set('display_errors', 1);
error_reporting(E_ALL);

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tts_database";

try {
    $conn = new mysqli($servername, $username, $password, $dbname);

    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }

    $data = json_decode(file_get_contents('php://input'), true);
    $user_id = intval($data['user_id']); // Retrieve user_id 

    // Use prepared statements to avoid SQL injection
    $stmt = $conn->prepare("SELECT * FROM folders WHERE user_id = ?");
    $stmt->bind_param("i", $user_id);

    // Execute the statement
    $stmt->execute();

    // Get the result
    $result = $stmt->get_result();

    if (!$result) {
        throw new Exception("Query failed: " . $conn->error);
    }

    $folders = [];
    while ($row = $result->fetch_assoc()) {
        $folders[] = $row;
    }

    $conn->close();
} catch (Exception $e) {
    $folders = array('status' => 'error', 'message' => 'Exception: ' . $e->getMessage());
}

echo json_encode($folders);
?>
