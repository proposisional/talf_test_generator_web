<?php

namespace app\components;

use Yii;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;
use GuzzleHttp\Exception\RequestException;

class AiClient
{
    private Client $http;
    private string $apiKey;
    private string $baseUrl;
    private string $model;
    private ?string $contextFile;

    public function __construct()
    {
        $this->http = new Client([
            'timeout' => 60,
            'connect_timeout' => 15,
            'verify' => false,
        ]);

        $params = Yii::$app->params ?? [];

        $this->apiKey = getenv('GEMINI_API_KEY') ?: ($params['geminiApiKey'] ?? '');
        $this->baseUrl = rtrim($params['geminiBaseUrl'] ?? 'https://generativelanguage.googleapis.com/v1beta', '/');
        $this->model = getenv('GEMINI_MODEL') ?: ($params['geminiModel'] ?? 'gemini-1.5-flash');

        $this->contextFile = isset($params['aiContextFilePath'])
            ? Yii::getAlias($params['aiContextFilePath'])
            : Yii::getAlias('@app/data/ai_context.txt');
    }

    public function ask(string $questionText): array
    {
        if ($this->apiKey === '') {
            Yii::error('AI error: GEMINI_API_KEY ausente', __METHOD__);
            return ['ok' => false, 'error' => 'Falta GEMINI_API_KEY'];
        }

        $systemContext = $this->loadContext();

        $userText = trim(
            ($systemContext ? "Contexto:\n{$systemContext}\n\n" : '') .
            "Pregunta:\n{$questionText}"
        );

        $parts = [['text' => $userText]];

        try {
            Yii::info(
                "AI request provider=gemini model={$this->model} endpoint=:generateContent",
                __METHOD__
            );
            $endpoint = $this->baseUrl . '/models/' . rawurlencode($this->model) . ':generateContent?key=' . rawurlencode($this->apiKey);
            $resp = $this->http->post(
                $endpoint,
                [
                    'headers' => [
                        'Content-Type' => 'application/json',
                    ],
                    'json' => [
                        'contents' => [
                            [
                                'role' => 'user',
                                'parts' => $parts,
                            ],
                        ],
                        'generationConfig' => [
                            'temperature' => 0.2,
                        ],
                    ],
                ]
            );

        } catch (RequestException $e) {
            $resp = $e->getResponse();
            $code = $resp ? $resp->getStatusCode() : null;
            $body = $resp ? (string) $resp->getBody() : null;

            Yii::error(
                'AI RequestException'
                . ($code ? " HTTP {$code}" : '')
                . ' BODY=' . ($body ?? '[no body]'),
                __METHOD__
            );

            return [
                'ok' => false,
                'code' => $code,
                'error' => 'Error HTTP en Gemini API ' . $e->getMessage(),
                'body' => $body,
                'details' => $e->getMessage(),
            ];
        } catch (GuzzleException $e) {

            Yii::error(
                'AI GuzzleException message=' . $e->getMessage(),
                __METHOD__
            );

            return [
                'ok' => false,
                'error' => 'Error de red al contactar con Gemini: ' . $e->getMessage(),
                'details' => $e->getMessage(),
            ];
        }

        $statusCode = $resp->getStatusCode();
        $rawBody = (string) $resp->getBody();

        if ($statusCode < 200 || $statusCode >= 300) {
            Yii::error('AI bad status: ' . $statusCode . ' body=' . substr($rawBody, 0, 2000), __METHOD__);
            return [
                'ok' => false,
                'error' => 'HTTP ' . $statusCode . ': ' . substr($rawBody, 0, 2000),
                'code' => $statusCode,
                'body' => $rawBody,
            ];
        }

        $data = json_decode($rawBody, true);

        $text = null;
        if (isset($data['candidates'][0]['content']['parts']) && is_array($data['candidates'][0]['content']['parts'])) {
            $chunks = [];
            foreach ($data['candidates'][0]['content']['parts'] as $part) {
                if (isset($part['text']) && is_string($part['text']) && $part['text'] !== '') {
                    $chunks[] = $part['text'];
                }
            }
            if ($chunks) {
                $text = implode("\n", $chunks);
            }
        }

        if (!$text) {
            Yii::error(
                'AI empty or unexpected response BODY=' . $rawBody,
                __METHOD__
            );
            return ['ok' => false, 'error' => 'Respuesta vacía o inválida de la IA'];
        }

        return [
            'ok' => true,
            'text' => $text,
            'raw' => $data,
        ];
    }

    private function loadContext(): string
    {
        if ($this->contextFile && is_file($this->contextFile)) {
            $content = file_get_contents($this->contextFile);
            return is_string($content) ? trim($content) : '';
        }
        return '';
    }
}
