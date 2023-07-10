<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");

require_once __DIR__ . '/vendor/autoload.php';
// Include the Google API client library

use Google\Cloud\Storage\StorageClient;
use Google\Cloud\Vision\VisionClient;
use Google\Cloud\TextToSpeech\V1\Input;
use Google\Cloud\TextToSpeech\V1\AudioConfig;
use Google\Cloud\TextToSpeech\V1\AudioEncoding;
use Google\Cloud\TextToSpeech\V1\SynthesisInput;
use Google\Cloud\TextToSpeech\V1\TextToSpeechClient;
use Google\Cloud\TextToSpeech\V1\VoiceSelectionParams;
use Google\Cloud\TextToSpeech\V1\SsmlVoiceGender;
use Google\Auth\CredentialsLoader;

putenv('GOOGLE_APPLICATION_CREDENTIALS=C:\xampp\htdocs\TTS\groovy-student-381718-7eae8eefa0c9.json');


$projectId = 'groovy-student-381718';
$bucketName = 'images_ocr_tts';
$credentialsPath = 'C:\xampp\htdocs\TTS\groovy-student-381718-7eae8eefa0c9.json';

// Initialize the Google Cloud Storage client.
$storage = new StorageClient([
    'projectId' => $projectId,
    'keyFilePath' => $credentialsPath,
]);

// Initialize the Google Cloud Vision client.
$vision = new VisionClient([
    'projectId' => $projectId,
    'keyFilePath' => $credentialsPath,
]);

// Initialize the Google Cloud Text-to-Speech client.
$textToSpeech = new TextToSpeechClient([
    'credentials' => $credentialsPath,
]);

$bucket = $storage->bucket($bucketName);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!empty($_FILES['image']['tmp_name'])) {
        // Generate a unique file name and upload the image to Google Cloud Storage.
        $fileName = uniqid() . '.jpg';
        $file = fopen($_FILES['image']['tmp_name'], 'r');
        $bucket->upload($file, [
            'name' => $fileName,
        ]);

        // Create the image URL.
        $imageUrl = "https://storage.googleapis.com/$bucketName/$fileName";

        // Send the image URL to Google Vision API for OCR text detection.
        $image = $vision->image(file_get_contents($imageUrl), ['TEXT_DETECTION']);
        $annotation = $vision->annotate($image);
        $text = $annotation->text();


// Concatenate the detected text blocks.
$detectedText = "";
foreach ($text as $t) {
    $currentText = $t->description();
    if (strpos($detectedText, $currentText) === false) {
        $detectedText .= $currentText . " ";
    }
}



        //echo "Detected text: " . $detectedText . "\n";

        // Generate audio for the detected text using Google Cloud Text-to-Speech API.

      
       //  the voice parameters
$voice = (new VoiceSelectionParams())
    ->setLanguageCode('ar-XA') // The language code for Arabic (Saudi Arabia)
    ->setName('ar-XA-Standard-C') // The voice name
    ->setSsmlGender(SsmlVoiceGender::MALE); // The gender of the voice


    //  the audio output parameters (replace with your own values)
         $audioConfig = (new AudioConfig())
        ->setAudioEncoding(AudioEncoding::MP3); // The audio format

        //  the input text
        $synthesisInputText = new SynthesisInput();
        $synthesisInputText->setText($detectedText);


        // Call the Text-to-Speech API to generate the audio file
        $response = $textToSpeech->synthesizeSpeech($synthesisInputText, $voice, $audioConfig);

        // Save the audio file to the Cloud Storage bucket
        $storage = new StorageClient([
        'projectId' => $projectId,
        'credentials' => $credentialsPath
            ]);
        $bucket = $storage->bucket($bucketName, ['iamConfiguration' => ['uniformBucketLevelAccess' => ['enabled' => true]]]);
        $objectName = uniqid('audio_', true) . '.mp3';
        $object = $bucket->upload($response->getAudioContent(), [
       'name' => $objectName,
        ]);

        // Create the audio URL.
        $audioUrl = "https://storage.googleapis.com/$bucketName/$objectName";

        // Return the audio URL as a JSON response.
        header('Content-Type: application/json');
        echo json_encode(['audioUrl' => $audioUrl]);
    } else {
        echo "No image file was provided.";
    }
}
else {
    echo "Invalid request method.";
}
?>
