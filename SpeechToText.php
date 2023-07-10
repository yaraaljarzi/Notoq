<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");

require_once __DIR__ . '/vendor/autoload.php';
// Include the Google API client library

use Google\Cloud\Storage\StorageClient;
use Google\Cloud\Speech\V1\RecognitionAudio;
use Google\Cloud\Speech\V1\RecognitionConfig;
use Google\Cloud\Speech\V1\SpeechClient;
use Google\Cloud\Speech\V1\SpeechRecognitionAlternative;
use Google\Cloud\Speech\V1\SpeechRecognitionResult;
use Google\Cloud\Speech\V1\RecognitionConfig_AudioEncoding;

putenv('GOOGLE_APPLICATION_CREDENTIALS=C:\xampp\htdocs\TTS\groovy-student-381718-7eae8eefa0c9.json');


$projectId = 'groovy-student-381718';

$bucketName = 'audiosavephp';


$audioFile = $_FILES['audio'];

// Generate a unique filename for the audio file
$filename = uniqid('audio_') . '.' . pathinfo($audioFile['name'], PATHINFO_EXTENSION);

// Move the uploaded file to the Google Cloud Storage bucket
$storage = new StorageClient([
    'projectId' => $projectId,
]);
$bucket = $storage->bucket($bucketName);
$bucket->upload(
    fopen($audioFile['tmp_name'], 'r'),
    [
        'name' => $filename,
    ]
);

// Create the Speech-to-Text client
$speech = new SpeechClient([
    'projectId' => $projectId,
]);

// Configure the audio settings for speech recognition
$audio = (new RecognitionAudio())
    ->setUri('gs://' . $bucketName . '/' . $filename);
$config = (new RecognitionConfig())
    ->setLanguageCode('ar-JO');

// Perform speech recognition
$response = $speech->recognize($config, $audio);

// Process the speech recognition response
$transcripts = [];
foreach ($response->getResults() as $result) {
    /** @var SpeechRecognitionResult $result */
    foreach ($result->getAlternatives() as $alternative) {
        /** @var SpeechRecognitionAlternative $alternative */
        $transcript = $alternative->getTranscript();
        $transcripts[] = $transcript;
    }
}


header('Content-Type: application/json; charset=utf-8');
echo json_encode($transcripts, JSON_UNESCAPED_UNICODE);
