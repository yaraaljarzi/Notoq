<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");

$servername = "localhost";
$username = "root";
$password = "yara@0186584";
$dbname = "tts_database";

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $folderId = $_POST['folder_id'];

        $stmt = $conn->prepare("SELECT file_id, file_name, extension, file_size, upload_date, file_url FROM files WHERE folder_id = :folder_id");
        $stmt->bindParam(':folder_id', $folderId);

        $stmt->execute();

        $files = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $response = [
            'status' => 'success',
            'files' => $files
        ];

        header('Content-Type: application/json');
        echo json_encode($response);
    }
} catch(PDOException $e) {
    $response = [
        'status' => 'error',
        'message' => $e->getMessage()
    ];
    echo json_encode($response);
}
?>
