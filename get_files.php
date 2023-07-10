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

    // Get the request data
    $data = json_decode(file_get_contents('php://input'), true);
    $folder_id = intval($data['folder_id']);

    if (empty($folder_id)) {
        $response = array('status' => 'error', 'message' => 'Folder ID is required');
        header('Content-Type: application/json');
        echo json_encode($response);
        exit();
    }

    // prepared statements to avoid SQL injection
    $stmt = $conn->prepare("SELECT * FROM files WHERE folder_id = ?");
    $stmt->bind_param("i", $folder_id);

    // Execute the statement
    $stmt->execute();

    $result = $stmt->get_result();
    $files = $result->fetch_all(MYSQLI_ASSOC);

    $response = array('status' => 'success', 'files' => $files);
    $conn->close();
} catch (Exception $e) {
    $response = array('status' => 'error', 'message' => 'Exception: ' . $e->getMessage());
}

header('Content-Type: application/json');
echo json_encode($response);

?>
