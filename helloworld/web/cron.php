<?php
use Google\Cloud\SecretManager\V1\SecretManagerServiceClient;
$projectId = 'gcp101588-educoeppyly';
$secretId = 'gibberish';
$versionId = 'latest';
$client = new SecretManagerServiceClient();
$name = $client->secretVersionName($projectId, $secretId, $versionId);
$response = $client->accessSecretVersion($name);
$pass = $response->getPayload()->getData();
$maxquerytime = 10;
$user = 'user';
$db = 'db';
$host = '34.118.86.8';
$link = mysqli_connect($host, $user, $pass);
if ($link) echo '<b>OK.</b> - successfully connected to SQL server.';
else die('<b>Error</b>');
mysqli_select_db($link, $db);
mysqli_query($link, "SET NAMES 'utf8'");
mysqli_query($link, "SET CHARACTER SET 'utf8'");
mysqli_query($link, "SET SESSION collation_connection = 'utf8_general_ci'");
 
$result = mysqli_query($link, "SHOW FULL PROCESSLIST");

if(!$result){
	mysqli_close($link);
  echo "<br>No processes found";
}
if (mysqli_num_rows($result) > 0) {
  echo "<br>Found some processes";
  for ($x = 1; $x <= 10; $x++){
    $row=mysqli_fetch_array($result);
    $process_id=$row["Id"];
    if ( $row["Time"] > $maxquerytime ) {
      $sql="KILL $process_id";
      echo "<br>Killed process ".$row["Info"]." - ".$sql;
      mysqli_query($link, $sql);
    }
    if ( $x !=10 ){
      sleep(1);
    }
  }
  mysqli_close($link);
  echo "<br>finished killing processes";
}