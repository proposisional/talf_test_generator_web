<?php

namespace app\components;

use yii\helpers\Html;

class QuestionImageRenderer
{
    public static function render(?string $image, array $options = []): string
    {
        $value = trim((string) $image);
        if ($value === '') {
            return '';
        }

        $escapeText = (bool) ($options['escapeText'] ?? true);
        $wrapperStyle = (string) ($options['wrapperStyle'] ?? 'text-align:center; margin-bottom:10px; width:100%; max-width:100%; box-sizing:border-box;');
        $imgStyle = (string) ($options['imgStyle'] ?? 'max-width:100%; height:auto; width:auto;');
        $svgStyle = (string) ($options['svgStyle'] ?? 'width:70%; height:auto; max-width:100%; max-height:100%;');

        $wrapperTag = strtolower((string) ($options['wrapperTag'] ?? 'div'));
        if (!in_array($wrapperTag, ['div', 'span'], true)) {
            $wrapperTag = 'div';
        }

        $textTag = strtolower((string) ($options['textTag'] ?? ($wrapperTag === 'span' ? 'span' : 'p')));
        if (!in_array($textTag, ['p', 'span', 'div'], true)) {
            $textTag = $wrapperTag === 'span' ? 'span' : 'p';
        }
        $textStyle = (string) ($options['textStyle'] ?? ($textTag === 'p'
            ? 'margin:0; display:inline-block; max-width:100%; overflow-wrap:anywhere; word-break:break-word;'
            : 'display:inline; max-width:100%; overflow-wrap:anywhere; word-break:break-word;'
        ));

        if (self::isInlineSvg($value)) {
            $svg = self::injectSvgStyle($value, $svgStyle);
            return Html::tag($wrapperTag, $svg, ['style' => $wrapperStyle]);
        }

        $src = self::toImageSrc($value);
        if ($src !== null) {
            $img = Html::img($src, [
                'style' => $imgStyle,
                'alt' => 'Imagen',
            ]);
            return Html::tag($wrapperTag, $img, ['style' => $wrapperStyle]);
        }

        $text = $escapeText ? Html::encode($value) : $value;
        $body = Html::tag($textTag, $text, ['style' => $textStyle]);
        return Html::tag($wrapperTag, $body, ['style' => $wrapperStyle]);
    }

    private static function isInlineSvg(string $value): bool
    {
        $clean = ltrim($value);
        $clean = preg_replace('/^<\?xml[^>]*>\s*/i', '', $clean) ?? $clean;
        $clean = preg_replace('/^<!doctype[^>]*>\s*/i', '', $clean) ?? $clean;
        $clean = preg_replace('/^(?:<!--.*?-->\s*)+/is', '', $clean) ?? $clean;
        $clean = ltrim($clean);
        return preg_match('/^<svg\b/i', $clean) === 1;
    }

    private static function injectSvgStyle(string $svg, string $style): string
    {
        if (preg_match('/<svg\b[^>]*>/i', $svg, $m, PREG_OFFSET_CAPTURE)) {
            $open = $m[0][0];
            $offset = (int) $m[0][1];

            $constraints = 'max-width:100%; height:auto; max-height:100%;';
            $desired = trim($style);
            $finalAdd = trim($desired . '; ' . $constraints);

            if (preg_match('/\sstyle\s*=\s*(["\'])(.*?)\1/i', $open, $sm)) {
                $quote = $sm[1];
                $existing = $sm[2];
                $merged = rtrim($existing);
                if ($merged !== '' && !str_ends_with(trim($merged), ';')) {
                    $merged .= ';';
                }
                $merged .= ' ' . $finalAdd;
                $newOpen = preg_replace(
                    '/\sstyle\s*=\s*(["\'])(.*?)\1/i',
                    ' style=' . $quote . Html::encode($merged) . $quote,
                    $open,
                    1
                );
                if (is_string($newOpen)) {
                    return substr($svg, 0, $offset) . $newOpen . substr($svg, $offset + strlen($open));
                }
            }

            $styledOpen = rtrim(substr($open, 0, -1)) . ' style="' . Html::encode($finalAdd) . '">';
            return substr($svg, 0, $offset) . $styledOpen . substr($svg, $offset + strlen($open));
        }

        return $svg;
    }

    private static function toImageSrc(string $value): ?string
    {
        if (preg_match('~^data:image/(?:png|jpe?g|gif|webp|svg\+xml);base64,~i', $value)) {
            return $value;
        }

        if (filter_var($value, FILTER_VALIDATE_URL)) {
            return $value;
        }
        if (preg_match('~^(?:/|\./|\.\./)~', $value)) {
            return $value;
        }

        $clean = preg_replace('/\s+/', '', $value);
        if ($clean === null) {
            return null;
        }
        if (strlen($clean) < 80) {
            return null;
        }
        if (!preg_match('~^[A-Za-z0-9+/=]+$~', $clean)) {
            return null;
        }

        $mime = 'image/png';
        if (strpos($clean, '/9j/') === 0) {
            $mime = 'image/jpeg';
        } elseif (strpos($clean, 'R0lGOD') === 0) {
            $mime = 'image/gif';
        } elseif (strpos($clean, 'PHN2Zy') === 0) {
            $mime = 'image/svg+xml';
        } elseif (strpos($clean, 'iVBORw0KGgo') === 0) {
            $mime = 'image/png';
        }

        return 'data:' . $mime . ';base64,' . $clean;
    }
}
