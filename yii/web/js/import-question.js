(function () {
    function normalizeQuestion(raw) {
        const q = raw && typeof raw === 'object' ? raw : {};

        const title = typeof q.title === 'string' ? q.title : '';
        const stem = typeof q.stem === 'string' ? q.stem : '';
        const image = typeof q.image === 'string' ? q.image : '';

        const choices = Array.isArray(q.choices)
            ? q.choices.map(v => (typeof v === 'string' ? v : ''))
            : [];

        const correct_choices = Array.isArray(q.correct_choices)
            ? q.correct_choices
                .map(v => Number(v))
                .filter(n => Number.isFinite(n) && Number.isInteger(n) && n >= 0)
            : [];

        let subject = null;
        if (typeof q.subject === 'number' && Number.isFinite(q.subject)) {
            subject = q.subject;
        } else if (typeof q.subject === 'string' && q.subject.trim() !== '' && Number.isFinite(Number(q.subject))) {
            subject = Number(q.subject);
        }

        // Filtrar correct_choices fuera de rango
        const boundedCorrect = correct_choices.filter(n => n < choices.length);

        return {
            title,
            stem,
            image,
            choices,
            correct_choices: boundedCorrect,
            subject,
        };
    }

    function parseQuestionText(text) {
        const cleaned = (text || '').replace(/^\uFEFF/, '').trim();
        if (!cleaned) {
            throw new Error('Archivo vacío');
        }

        let parsed;
        try {
            parsed = JSON.parse(cleaned);
        } catch (e) {
            throw new Error('el archivo no contiene JSON válido');
        }

        // Aceptar tanto { ... } como { Question: { ... } }
        const rawQuestion = (parsed && typeof parsed === 'object' && parsed.Question && typeof parsed.Question === 'object')
            ? parsed.Question
            : parsed;

        return normalizeQuestion(rawQuestion);
    }

    function readFileAsText(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onerror = () => reject(new Error('no se pudo leer el archivo'));
            reader.onload = () => resolve(String(reader.result || ''));
            reader.readAsText(file);
        });
    }

    window.pickAndParseQuestionFile = async function () {
        return new Promise((resolve, reject) => {
            const input = document.createElement('input');
            input.type = 'file';
            input.accept = '.txt,.json,application/json,text/plain';
            input.style.display = 'none';

            input.addEventListener('change', async () => {
                try {
                    const file = input.files && input.files[0];
                    if (!file) {
                        reject(new Error('No se seleccionó ningún archivo'));
                        return;
                    }
                    const text = await readFileAsText(file);
                    const q = parseQuestionText(text);
                    resolve(q);
                } catch (e) {
                    reject(e);
                } finally {
                    input.remove();
                }
            });

            document.body.appendChild(input);
            input.click();
        });
    };
})();
