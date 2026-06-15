(function () {
    function pad2(n) {
        return String(n).padStart(2, '0');
    }

    function timestampForFilename(d) {
        return (
            d.getFullYear() +
            pad2(d.getMonth() + 1) +
            pad2(d.getDate()) +
            '-' +
            pad2(d.getHours()) +
            pad2(d.getMinutes()) +
            pad2(d.getSeconds())
        );
    }

    function normalizeQuestion(question) {
        const q = question && typeof question === 'object' ? question : {};
        const choices = Array.isArray(q.choices) ? q.choices : [];
        const correct = Array.isArray(q.correct_choices) ? q.correct_choices : [];

        return {
            title: typeof q.title === 'string' ? q.title : '',
            stem: typeof q.stem === 'string' ? q.stem : '',
            image: typeof q.image === 'string' ? q.image : '',
            choices: choices.map(v => (typeof v === 'string' ? v : String(v ?? ''))),
            correct_choices: correct.map(v => {
                const n = Number(v);
                return Number.isFinite(n) ? n : v;
            }),
            subject: (q.subject === '' || q.subject === undefined) ? null : q.subject,
        };
    }

    function guessMimeFromBase64(b64) {
        if (b64.startsWith('/9j/')) return 'image/jpeg';
        if (b64.startsWith('R0lGOD')) return 'image/gif';
        if (b64.startsWith('PHN2Zy')) return 'image/svg+xml';
        if (b64.startsWith('iVBORw0KGgo')) return 'image/png';
        if (b64.startsWith('UklGR')) return 'image/webp';
        return 'image/png';
    }

    function isLikelyRawBase64Image(value) {
        const clean = value.replace(/\s+/g, '');
        if (clean.length < 80) return false;
        return /^[A-Za-z0-9+/=]+$/.test(clean);
    }

    function svgToBase64(svg) {
        const normalized = String(svg || '').trim();
        if (typeof TextEncoder !== 'undefined') {
            const bytes = new TextEncoder().encode(normalized);
            let binary = '';
            bytes.forEach(byte => {
                binary += String.fromCharCode(byte);
            });
            return btoa(binary);
        }

        return btoa(unescape(encodeURIComponent(normalized)));
    }

    function normalizeImageForMoodle(image) {
        const raw = String(image || '').trim();
        if (!raw) return '';

        if (/<svg\b/i.test(raw)) {
            return `data:image/svg+xml;base64,${svgToBase64(raw)}`;
        }

        if (/^(https?:\/\/|\/|\.\/|\.\.\/)/i.test(raw)) {
            return raw;
        }

        if (/^data:image\/[a-z0-9.+-]+;base64,/i.test(raw)) {
            return raw;
        }

        if (isLikelyRawBase64Image(raw)) {
            const clean = raw.replace(/\s+/g, '');
            return `data:${guessMimeFromBase64(clean)};base64,${clean}`;
        }

        return raw;
    }

    function escapeXml(value) {
        return String(value ?? '')
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&apos;');
    }

    function wrapCdata(value) {
        return '<![CDATA[' + String(value ?? '').replace(/]]>/g, ']]]]><![CDATA[>') + ']]>';
    }

    function stemToHtml(stem) {
        const escaped = escapeXml(stem).replace(/\r\n|\r|\n/g, '<br>');
        return `<p>${escaped}</p>`;
    }

    function buildQuestionHtml(question) {
        let html = stemToHtml(question.stem);
        const imageSrc = normalizeImageForMoodle(question.image);

        if (imageSrc) {
            if (/^(https?:\/\/|\/|\.\/|\.\.\/|data:image\/)/i.test(imageSrc)) {
                html += `<p><img src="${escapeXml(imageSrc)}" alt="${escapeXml(question.title || 'imagen de la pregunta')}" /></p>`;
            } else {
                html += `<p>${escapeXml(imageSrc)}</p>`;
            }
        }

        return html;
    }

    function buildTagsXml(question) {
        if (question.subject === null || question.subject === undefined || question.subject === '') {
            return '';
        }

        return [
            '    <tags>',
            '      <tag>',
            `        <text>${escapeXml('subject-' + question.subject)}</text>`,
            '      </tag>',
            '    </tags>'
        ].join('\n');
    }

    function buildAnswersXml(question) {
        const correctSet = new Set(question.correct_choices.map(value => Number(value)));
        const correctCount = correctSet.size;

        return question.choices.map((choice, index) => {
            const isCorrect = correctSet.has(index);
            const fraction = isCorrect && correctCount > 0
                ? String(100 / correctCount)
                : '0';

            return [
                `    <answer fraction="${fraction}" format="html">`,
                `      <text>${escapeXml(choice)}</text>`,
                '      <feedback format="html">',
                '        <text></text>',
                '      </feedback>',
                '    </answer>'
            ].join('\n');
        }).join('\n');
    }

    function buildMoodleXml(question) {
        const single = question.correct_choices.length <= 1 ? 'true' : 'false';
        const tagsXml = buildTagsXml(question);
        const answersXml = buildAnswersXml(question);
        const questionHtml = buildQuestionHtml(question);

        const parts = [
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<quiz>',
            '  <question type="multichoice">',
            '    <name>',
            `      <text>${escapeXml(question.title || 'Pregunta sin título')}</text>`,
            '    </name>',
            '    <questiontext format="html">',
            `      <text>${wrapCdata(questionHtml)}</text>`,
            '    </questiontext>',
            '    <generalfeedback format="html">',
            '      <text></text>',
            '    </generalfeedback>',
            '    <defaultgrade>1.0000000</defaultgrade>',
            '    <penalty>0.3333333</penalty>',
            '    <hidden>0</hidden>',
            `    <single>${single}</single>`,
            '    <shuffleanswers>true</shuffleanswers>',
            '    <answernumbering>abc</answernumbering>'
        ];

        if (tagsXml) {
            parts.push(tagsXml);
        }

        if (answersXml) {
            parts.push(answersXml);
        }

        parts.push('  </question>');
        parts.push('</quiz>');

        return parts.join('\n');
    }

    function downloadText(text, filename, mimeType) {
        const blob = new Blob([text], { type: mimeType || 'text/plain;charset=utf-8' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = filename;
        a.rel = 'noopener';
        document.body.appendChild(a);
        a.click();
        a.remove();
        setTimeout(() => URL.revokeObjectURL(url), 0);
    }

    window.downloadQuestionAsTxt = function (question, filenamePrefix) {
        const normalized = normalizeQuestion(question);
        const ts = timestampForFilename(new Date());
        const prefix = (filenamePrefix && String(filenamePrefix).trim()) ? String(filenamePrefix).trim() : 'question';
        const filename = `${prefix}-${ts}.json`;
        const json = JSON.stringify(normalized, null, 2);
        downloadText(json, filename);
        return normalized;
    };

    window.downloadQuestionAsMoodleXml = function (question, filenamePrefix) {
        const normalized = normalizeQuestion(question);
        const ts = timestampForFilename(new Date());
        const prefix = (filenamePrefix && String(filenamePrefix).trim()) ? String(filenamePrefix).trim() : 'question';
        const filename = `${prefix}-${ts}.xml`;
        const xml = buildMoodleXml(normalized);
        downloadText(xml, filename, 'application/xml;charset=utf-8');
        return normalized;
    };
})();
