<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST, OPTIONS");

require_once __DIR__ . '/vendor/autoload.php';
// Include the Google API client library

use Google\Cloud\TextToSpeech\V1\AudioConfig;
use Google\Cloud\TextToSpeech\V1\AudioEncoding;
use Google\Cloud\TextToSpeech\V1\SynthesisInput;
use Google\Cloud\TextToSpeech\V1\TextToSpeechClient;
use Google\Cloud\TextToSpeech\V1\VoiceSelectionParams;
use Google\Cloud\TextToSpeech\V1\SsmlVoiceGender;
use Google\Cloud\Storage\StorageClient;
use Google\Auth\CredentialsLoader;

putenv('GOOGLE_APPLICATION_CREDENTIALS=C:\xampp\htdocs\TTS\groovy-student-381718-7eae8eefa0c9.json');


$projectId = 'groovy-student-381718';
$credentialsPath = 'C:\xampp\htdocs\TTS\groovy-student-381718-7eae8eefa0c9.json';
$bucketName = 'audiosavephp'; 

$inputText = $_POST['text']; 

// Determine the language code based on the input text
$languageCode = detectLanguage($inputText);

// Create the Text-to-Speech client and get the location of the API
$client = new TextToSpeechClient([
    'credentials' => $credentialsPath
]);
$location = 'global';

// the voice parameters based on the detected language
$voice = determineVoice($languageCode);

// the audio output parameters 
$audioConfig = (new AudioConfig())
    ->setAudioEncoding(AudioEncoding::MP3); // The audio format

// the input text
$synthesisInputText = new SynthesisInput();
$synthesisInputText->setText($inputText);

// Call the Text-to-Speech API to generate the audio file
$response = $client->synthesizeSpeech($synthesisInputText, $voice, $audioConfig);

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

// Generate the URL for the audio file
$mp3Url = sprintf('https://storage.googleapis.com/%s/%s', $bucketName, $objectName);

// Return the URL of the audio file
$response = array('mp3Url' => $mp3Url);
header('Content-Type: application/json');
echo json_encode($response);


$client->close();

/**
 * Detects the language of the input text.
 *
 * @param string $text The input text.
 * @return string The detected language code.
 */
function detectLanguage($text)
{
 
    $englishCharacters = preg_match('/[A-Za-z]/', $text);
    $arabicCharacters = preg_match('/[\x{0600}-\x{06FF}]/u', $text);

    if ($englishCharacters && !$arabicCharacters) {
        return 'en-US'; // English language code (United States)
    } elseif (!$englishCharacters && $arabicCharacters) {
        return 'ar-XA'; // Arabic language code (Saudi Arabia)
    } else {
        return 'en-US'; // Default to English if the language cannot be reliably detected
    }
}

/**
 * Determines the voice parameters based on the language code.
 *
 * @param string $languageCode The language code.
 * @return VoiceSelectionParams The configured voice parameters.
 */
function determineVoice($languageCode)
{
    if ($languageCode === 'ar-XA') {
        return (new VoiceSelectionParams())
            ->setLanguageCode($languageCode)
            ->setName('ar-XA-Standard-D')
            ->setSsmlGender(SsmlVoiceGender::FEMALE);
    } else {
        return (new VoiceSelectionParams())
            ->setLanguageCode($languageCode)
            ->setName('en-US-Standard-C')
            ->setSsmlGender(SsmlVoiceGender::FEMALE);
    }
}
?>
