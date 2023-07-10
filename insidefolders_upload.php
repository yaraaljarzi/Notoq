<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");

require_once __DIR__ . '/vendor/autoload.php';
// Include the Google API client library

use Google\Cloud\Storage\StorageClient;

$servername = "localhost";
$username = "root";
$password = "yara@0186584";
$dbname = "tts_database";

// Set up the Google Cloud Storage client
$storage = new StorageClient([
    'projectId' => 'groovy-student-381718',
    'keyFilePath' => 'C:\xampp\htdocs\TTS\groovy-student-381718-7eae8eefa0c9.json'
]);


$bucketName = 'images_ocr_tts';

try {
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        $folderId = $_POST['folder_id'];
        $userId = $_POST['user_id'];

        // Get the image file
        $imageFile = $_FILES['image']['tmp_name'];
        $imageName = $_FILES['image']['name'];

        // Read the image file content
        $imageContent = file_get_contents($imageFile);

        // Upload the image file to Google Cloud Storage
        $bucket = $storage->bucket($bucketName);
        $object = $bucket->upload($imageContent, [
            'name' => $imageName
        ]);

        $fileUrl = $object->signedUrl(
            strtotime('+10 years') // Set the expiration time 
        );

        // Store the image details in the database
        $stmt = $conn->prepare("INSERT INTO files (folder_id, file_name, extension, file_size, upload_date, file_url) VALUES (:folder_id, :file_name, :extension, :file_size, NOW(), :file_url)");
        $stmt->bindValue(':folder_id', $folderId, PDO::PARAM_INT);
        $stmt->bindValue(':file_name', $imageName, PDO::PARAM_STR);
        $stmt->bindValue(':extension', pathinfo($imageName, PATHINFO_EXTENSION), PDO::PARAM_STR);
        $stmt->bindValue(':file_size', filesize($imageFile), PDO::PARAM_INT);
        $stmt->bindValue(':file_url', $fileUrl, PDO::PARAM_STR);
        $stmt->execute();

        $fileId = $conn->lastInsertId();

        // Return the file details as a response
        $file = [
            'id' => $fileId,
            'name' => $imageName,
            'url' => $fileUrl
        ];

        $response = [
            'status' => 'success',
            'file' => $file
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
