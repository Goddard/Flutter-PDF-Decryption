<?php

function encryptFile($fileStream, $key, $password) {
    $pk12 = readP12(base64_decode($key), $password);

    $cipher = "aes-256-cbc";
    if(in_array($cipher, openssl_get_cipher_methods())) {
        return openssl_encrypt($fileStream, $cipher, 12345678901234561234567890123456, $options = 0, "1234567890123456");
    }

    return false;
}

function readP12($file_content, $password) {
    if(openssl_pkcs12_read($file_content, $output, $password)) {
        return $output;
    }
}

$key = "";


$file = encryptFile(file_get_contents("sample.pdf"), $key, "");

echo $file;
