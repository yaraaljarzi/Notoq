<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "tts_database";

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $userId = $_POST['user_id'];

        $stmt = $conn->prepare("SELECT folder_id, user_id, folder_name, date_created FROM folders WHERE user_id = :user_id");
        $stmt->bindParam(':user_id', $userId);

        $stmt->execute();

        $folders = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo json_encode($folders);
    }
} catch(PDOException $e) {
    $response = [
        'status' => 'error',
        'message' => $e->getMessage()
    ];
    echo json_encode($response);
}

?>
