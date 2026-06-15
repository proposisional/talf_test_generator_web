
$(document).ready(function () {
    const $input = $('#command-input');
    const $output = $('#output');
    const $preview = $('#preview-content');
    const $importBtn = $('#import-question-btn');
    let commandHistory = [];
    let historyIndex = -1;

    function getDocumentationUrl(command) {
        const base = (window.talfDocumentationUrl && typeof window.talfDocumentationUrl === 'string')
            ? window.talfDocumentationUrl
            : '/documentation';

        const trimmed = (command || '').trim();
        const parts = trimmed.split(/\s+/, 2);
        const arg = (parts[1] || '').toLowerCase();

        let anchor = '#consola-talf';
        if (arg.includes('test')) anchor = '#tests';
        else if (arg.includes('hist')) anchor = '#historial';
        else if (arg.includes('guard')) anchor = '#guardar-pregunta';
        else if (arg.includes('octave')) anchor = '#comandos-octave';

        return base + anchor;
    }

    function openDocumentation(command) {
        const url = getDocumentationUrl(command);
        const popup = window.open(url, '_blank', 'noopener');

        if (!popup) {
            $output.append(
                `<div class="cmd-output">No se pudo abrir una nueva pestaña (posible bloqueo de popups). ` +
                `<a href="${url}" target="_blank" rel="noopener">Abrir documentación</a></div>`
            );
        } else {
            $output.append(
                `<div class="cmd-output">Abriendo documentación: ` +
                `<a href="${url}" target="_blank" rel="noopener">${url}</a></div>`
            );
        }
        $output.scrollTop($output[0].scrollHeight);
    }

    function executeCommand(command) {
        const trimmed = (command || '').trim();
        if (!trimmed) return;

        $output.append(`<div class="cmd-line">talf:\\> ${trimmed}</div>`);

        const cmdName = trimmed.split(/\s+/, 1)[0].toLowerCase();
        if (cmdName === 'help') {
            openDocumentation(trimmed);
            commandHistory.push(trimmed);
            historyIndex = commandHistory.length;
            $input.val('');
            return;
        }

        $.ajax({
            url: 'talf-execute',
            method: 'POST',
            data: { command: trimmed, _csrf: yii.getCsrfToken() },
            dataType: 'json',
            success: function (res) {

                if (res.output === '__CLEAR__') {
                    $output.html('');
                    return;
                }

                if (res && res.question && typeof res.question === 'object') {
                    window.currentQuestion = { Question: res.question };
                }

                $output.append(`<div class="cmd-output">${res.output}</div>`);
                if (res.questionHtml) {
                    $preview.html(res.questionHtml);
                    if (window.MathJax && MathJax.typesetPromise) {
                        MathJax.typesetPromise([$preview[0]]);
                    }
                }
                $output.scrollTop($output[0].scrollHeight);
            },
            error: function (xhr, status) {
                $output.append(`<div class="cmd-error">Error: ${status}</div>`);
            }
        });
        commandHistory.push(trimmed);
        historyIndex = commandHistory.length;
        $input.val('');
    }

    async function importQuestionFromFile() {
        if (typeof window.pickAndParseQuestionFile !== 'function') {
            $output.append('<div class="cmd-error">Error: importador no disponible.</div>');
            return;
        }

        try {
            const q = await window.pickAndParseQuestionFile();
            const url = (window.talfImportQuestionUrl && typeof window.talfImportQuestionUrl === 'string')
                ? window.talfImportQuestionUrl
                : 'import-question';

            const resp = await fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': yii.getCsrfToken(),
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ question: q })
            });

            const data = await resp.json().catch(() => null);
            if (!resp.ok || !data || !data.ok) {
                const msg = data && data.error ? data.error : ('HTTP ' + resp.status);
                $output.append(`<div class="cmd-error">Error importando: ${msg}</div>`);
                return;
            }

            if (data.question && typeof data.question === 'object') {
                window.currentQuestion = { Question: data.question };
            }
            if (data.questionHtml) {
                $preview.html(data.questionHtml);
                if (window.MathJax && MathJax.typesetPromise) {
                    MathJax.typesetPromise([$preview[0]]);
                }
            }
            $output.append('<div class="cmd-output">Pregunta importada correctamente.</div>');
            $output.scrollTop($output[0].scrollHeight);
        } catch (e) {
            $output.append(`<div class="cmd-error">Error importando: ${e.message}</div>`);
        }
    }

    $input.on('keydown', function (e) {
        if (e.key === 'Enter') {
            executeCommand($input.val());
        } else if (e.key === 'ArrowUp') {
            if (commandHistory.length === 0) return;
            historyIndex = Math.max(0, historyIndex - 1);
            $input.val(commandHistory[historyIndex]);
            e.preventDefault();
        } else if (e.key === 'ArrowDown') {
            if (commandHistory.length === 0) return;
            historyIndex = Math.min(commandHistory.length, historyIndex + 1);
            if (historyIndex === commandHistory.length) {
                $input.val('');
            } else {
                $input.val(commandHistory[historyIndex]);
            }
            e.preventDefault();
        }
    });

    if ($importBtn.length) {
        $importBtn.on('click', function () {
            importQuestionFromFile();
        });
    }
});

