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
    $response = array('status' => 'error', 'message' => 'Connection failed: ' . $conn->connect_error);
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}

$data = json_decode(file_get_contents('php://input'), true);
$user_id = isset($data['user_id']) ? $conn->real_escape_string($data['user_id']) : '';

if(empty($user_id)) {
    $response = array('status' => 'error', 'message' => 'Please provide user id');
    header('Content-Type: application/json');
    echo json_encode($response);
    exit();
}

$sql = "SELECT user_name, user_email, user_photo, user_bio, member_since FROM user_account WHERE user_id = '$user_id'";
$result = $conn->query($sql);

if (!$result) {
    $response = array('status' => 'error', 'message' => 'Query failed: ' . $conn->error);
} else if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    $user_name = $row['user_name'];
    $user_email = $row['user_email'];
    $user_photo = $row['user_photo'];
    $user_bio = $row['user_bio'];
    $member_since = $row['member_since'];
    $response = array('status' => 'success', 'message' => 'User data fetched successfully', 'user_name' => $user_name, 'user_email' => $user_email, 'user_photo' => $user_photo, 'user_bio' => $user_bio, 'member_since' => $member_since);
} else {
    $response = array('status' => 'error', 'message' => 'User does not exist');
}

$conn->close();

header('Content-Type: application/json');
echo json_encode($response);
?>
