<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");

$servername = "localhost";
$username = "root";
$password = " ";
$dbname = "tts_database";

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $userId = $_POST['user_id'];
        $folderName = $_POST['folder_name'];
        $dateCreated = date('Y-m-d H:i:s');

        $stmt = $conn->prepare("INSERT INTO folders (user_id, folder_name, date_created)
                                VALUES (:user_id, :folder_name, :date_created)");
        $stmt->bindParam(':user_id', $userId);
        $stmt->bindParam(':folder_name', $folderName);
        $stmt->bindParam(':date_created', $dateCreated);

        $stmt->execute();

        $folderId = $conn->lastInsertId(); // Retrieve the ID of the inserted folder

        $response = [
            'status' => 'success',
            'folder' => [
                'folder_id' => $folderId, 
                'user_id' => $userId,
                'folder_name' => $folderName,
                'date_created' => $dateCreated
            ]
        ];

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
