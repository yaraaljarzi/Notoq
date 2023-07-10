<?php
header("Access-Control-Allow-Origin: http://192.168.100.10:50987");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tts_database";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$data = json_decode(file_get_contents('php://input'), true);
$user_id = isset($data['user_id']) ? $conn->real_escape_string($data['user_id']) : '';
$user_bio = isset($data['user_bio']) ? $conn->real_escape_string($data['user_bio']) : '';
$user_photo = isset($data['user_photo']) ? $data['user_photo'] : '';
$new_password = isset($data['new_password']) ? $conn->real_escape_string($data['new_password']) : '';
$confirm_new_password = isset($data['confirm_new_password']) ? $conn->real_escape_string($data['confirm_new_password']) : '';

if (empty($user_id)) {
    $response = array('status' => 'error', 'message' => 'Please provide user id');
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}

// Update user_bio
if (!empty($user_bio)) {
    $sql = "UPDATE user_account SET user_bio = '$user_bio' WHERE user_id = '$user_id'";
    $result = $conn->query($sql);

    if (!$result) {
        $response = array('status' => 'error', 'message' => 'Failed to update user bio: ' . $conn->error);
        header('Content-Type: application/json');
        echo json_encode($response);
        exit();
    }
}

// Update user_photo
if (!empty($user_photo)) {
    $uploads_dir = 'uploads/';
    $file_name = uniqid() . '.png';
    $decoded_photo = base64_decode($user_photo);
    file_put_contents($uploads_dir . $file_name, $decoded_photo);

    $sql = "UPDATE user_account SET user_photo = '$file_name' WHERE user_id = '$user_id'";
    $result = $conn->query($sql);

    if (!$result) {
        $response = array('status' => 'error', 'message' => 'Failed to update user photo: ' . $conn->error);
        header('Content-Type: application/json');
        echo json_encode($response);
        exit();
    }
}

// Update user_password
if (!empty($new_password) && !empty($confirm_new_password)) {
    // Check if the two passwords match
    if ($new_password !== $confirm_new_password) {
        $response = array('status' => 'error', 'message' => 'Passwords do not match');
        header('Content-Type: application/json');
        echo json_encode($response);
        exit();
    }

    $hashed_password = password_hash($new_password, PASSWORD_DEFAULT);

    $sql = "UPDATE user_account SET user_password = '$hashed_password' WHERE user_id = '$user_id'";
    $result = $conn->query($sql);

    if (!$result) {
        $response = array('status' => 'error', 'message' => 'Failed to update user password: ' . $conn->error);
        header('Content-Type: application/json');
        echo json_encode($response);
        exit();
    }
}

$response = array('status' => 'success');
header('Content-Type: application/json');
echo json_encode($response);

$conn->close();
?>
