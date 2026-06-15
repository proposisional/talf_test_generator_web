<?php

return [
    'adminEmail' => 'admin@example.com',
    'senderEmail' => 'noreply@example.com',
    'senderName' => 'Example.com mailer',
    'geminiApiKey' => getenv('GEMINI_API_KEY') ?: '',
    'geminiModel' => getenv('GEMINI_MODEL') ?: 'gemini-3-flash-preview',
    'geminiBaseUrl' => getenv('GEMINI_BASE_URL') ?: 'https://generativelanguage.googleapis.com/v1beta',

    'aiContextFilePath' => '@app/data/ai_context.txt',
];
