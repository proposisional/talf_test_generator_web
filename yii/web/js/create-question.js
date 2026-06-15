(function () {
    const container = document.getElementById('choices-container');
    const addBtn = document.getElementById('add-choice');
    const titleInput = document.getElementById('question-title');
    const stemInput = document.getElementById('latex-input');
    const preview = document.getElementById('preview-content');
    const downloadBtn = document.getElementById('download-question-btn');
    const downloadMoodleBtn = document.getElementById('download-question-moodle-btn');
    const importBtn = document.getElementById('import-question-btn');

    function collectQuestionFromForm() {
        const title = (document.getElementById('question-title')?.value ?? '').toString();
        const stem = (document.getElementById('latex-input')?.value ?? '').toString();
        const imageVal = (document.getElementById('image-input')?.value ?? '').toString();

        const subjectEl = document.querySelector('select[name="Question[subject]"]');
        const subjectRaw = subjectEl ? subjectEl.value : '';
        const subject = subjectRaw === '' ? null : Number(subjectRaw);

        const choiceItems = Array.from(document.querySelectorAll('#choices-container .choice-item'));
        const choices = choiceItems.map(item => {
            const input = item.querySelector('input[type="text"]');
            return (input?.value ?? '').toString();
        });
        const correct_choices = choiceItems
            .map((item, idx) => ({
                idx,
                checked: !!item.querySelector('input[type="checkbox"]')?.checked,
            }))
            .filter(x => x.checked)
            .map(x => x.idx);

        return {
            title,
            stem,
            image: imageVal,
            choices,
            correct_choices,
            subject,
        };
    }

    function renumberChoices() {
        const items = container.querySelectorAll('.choice-item');
        items.forEach((item, idx) => {
            const text = item.querySelector('input[type="text"]');
            const checkbox = item.querySelector('input[type="checkbox"]');
            const removeBtn = item.querySelector('.remove-choice');

            text.name = 'Question[choices][' + idx + ']';
            text.placeholder = 'Opción ' + (idx + 1);
            checkbox.name = 'Question[correct_choices][]';
            checkbox.value = idx;

            removeBtn.disabled = items.length <= 2;
        });
        updatePreview();
    }

    function addChoice(value = '', checked = false) {
        const div = document.createElement('div');
        div.className = 'choice-item';

        const input = document.createElement('input');
        input.type = 'text';
        input.className = 'form-control';
        input.value = value;

        const label = document.createElement('label');
        label.className = 'correct-checkbox';
        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        if (checked) checkbox.checked = true;
        label.appendChild(checkbox);
        label.appendChild(document.createTextNode(' Correcta'));

        const removeBtn = document.createElement('button');
        removeBtn.type = 'button';
        removeBtn.className = 'btn btn-sm btn-danger remove-choice';
        removeBtn.title = 'Eliminar opción';
        removeBtn.innerHTML = '×';

        div.appendChild(input);
        div.appendChild(label);
        div.appendChild(removeBtn);

        container.appendChild(div);
        renumberChoices();
    }

    function updatePreview() {
        const title = document.getElementById('question-title').value;
        const stem = document.getElementById('latex-input').value;
        const container = document.getElementById('choices-container');
        const preview = document.getElementById('preview-content');
        const imageInputEl = document.getElementById('image-input');
        const imageVal = (imageInputEl ? imageInputEl.value : '').trim();

        const choices = Array.from(container.querySelectorAll('.choice-item')).map(item => {
            return {
                text: item.querySelector('input[type="text"]').value,
                checked: item.querySelector('input[type="checkbox"]').checked
            };
        });

        const isMultiple = choices.filter(c => c.checked).length > 1;

        let html = `<h2>${title}</h2>`;
        html += `<p>${stem}</p>`;
        html += `<div id="img-preview" style="text-align:center; margin:10px 0; min-height:24px;"></div>`;
        html += `<ul style="list-style:none; padding-left:0;">`;

        choices.forEach(c => {
            const type = isMultiple ? 'checkbox' : 'radio';
            html += `<li>
                        <label>
                            <input type="${type}" disabled ${c.checked ? 'checked' : ''} />
                            ${c.text}
                        </label>
                    </li>`;
        });

        html += `</ul>`;
        preview.innerHTML = html;

        const imgContainer = preview.querySelector('#img-preview');
        if (imageVal) {
            const trimmed = imageVal.trim();
            const isUrl = /^(https?:\/\/|\/|\.\/|\.\.\/)/i.test(trimmed);
            const isDataImage = /^data:image\/(png|jpe?g|gif|webp|svg\+xml);base64,/i.test(trimmed);
            const isSvg = trimmed.startsWith('<svg');

            const looksLikeBase64 = (s) => {
                const clean = s.replace(/\s+/g, '');
                if (clean.length < 80) return false;
                return /^[A-Za-z0-9+/=]+$/.test(clean);
            };

            const guessMime = (b64) => {
                if (b64.startsWith('/9j/')) return 'image/jpeg';
                if (b64.startsWith('R0lGOD')) return 'image/gif';
                if (b64.startsWith('PHN2Zy')) return 'image/svg+xml';
                if (b64.startsWith('iVBORw0KGgo')) return 'image/png';
                return 'image/png';
            };

            if (isSvg) {
                try {
                    const temp = document.createElement('div');
                    temp.innerHTML = trimmed;
                    const svg = temp.querySelector('svg');
                    if (svg) {
                        svg.style.width = '70%';
                        svg.style.height = 'auto';
                        svg.style.maxWidth = '100%';
                        svg.style.maxHeight = '100%';
                        imgContainer.innerHTML = '';
                        imgContainer.appendChild(svg);
                    } else {
                        imgContainer.textContent = 'Error: el contenido no parece un SVG válido.';
                    }
                } catch (e) {
                    imgContainer.textContent = 'Error al renderizar el SVG.';
                }
            } else if (isUrl || isDataImage || looksLikeBase64(trimmed)) {
                const img = new Image();
                img.style.maxWidth = '70%';
                img.style.height = 'auto';
                img.loading = 'lazy';
                imgContainer.textContent = 'Cargando imagen...';
                img.onload = () => {
                    imgContainer.innerHTML = '';
                    imgContainer.appendChild(img);
                };
                img.onerror = () => {
                    imgContainer.textContent = 'Error: no se pudo cargar la imagen.';
                };
                if (isDataImage || isUrl) {
                    img.src = trimmed;
                } else {
                    const clean = trimmed.replace(/\s+/g, '');
                    img.src = `data:${guessMime(clean)};base64,${clean}`;
                }
            } else {
                const p = document.createElement('p');
                p.style.margin = '0';
                p.style.display = 'inline-block';
                p.style.maxWidth = '100%';
                p.style.overflowWrap = 'anywhere';
                p.style.wordBreak = 'break-word';
                p.textContent = trimmed;
                imgContainer.innerHTML = '';
                imgContainer.appendChild(p);
            }
        } else {
            imgContainer.textContent = '';
        }

        if (window.MathJax && MathJax.typesetPromise) {
            MathJax.typesetPromise([preview]);
        }
    }

    container.addEventListener('click', function (e) {
        if (e.target.matches('.remove-choice')) {
            const items = container.querySelectorAll('.choice-item');
            if (items.length <= 2) return;
            e.target.closest('.choice-item').remove();
            renumberChoices();
        }
    });

    container.addEventListener('input', updatePreview);
    container.addEventListener('change', updatePreview);
    titleInput.addEventListener('input', updatePreview);
    stemInput.addEventListener('input', updatePreview);

    addBtn.addEventListener('click', function () {
        addChoice('', false);
    });

    document.addEventListener('DOMContentLoaded', function () {
        renumberChoices();
        updatePreview();
    });

    if (downloadBtn) {
        downloadBtn.addEventListener('click', function () {
            const q = collectQuestionFromForm();

            if (typeof window.downloadQuestionAsTxt === 'function') {
                window.downloadQuestionAsTxt(q, 'question');
            }
        });
    }

    if (downloadMoodleBtn) {
        downloadMoodleBtn.addEventListener('click', function () {
            const q = collectQuestionFromForm();

            if (typeof window.downloadQuestionAsMoodleXml === 'function') {
                window.downloadQuestionAsMoodleXml(q, 'question-moodle');
            }
        });
    }

    if (importBtn) {
        importBtn.addEventListener('click', async function () {
            if (typeof window.pickAndParseQuestionFile !== 'function') return;

            try {
                const q = await window.pickAndParseQuestionFile();

                const titleEl = document.getElementById('question-title');
                const stemEl = document.getElementById('latex-input');
                const imageEl = document.getElementById('image-input');

                if (titleEl) titleEl.value = (q.title ?? '').toString();
                if (stemEl) stemEl.value = (q.stem ?? '').toString();
                if (imageEl) imageEl.value = (q.image ?? '').toString();

                const subjectEl = document.querySelector('select[name="Question[subject]"]');
                if (subjectEl) {
                    subjectEl.value = (q.subject === null || q.subject === undefined) ? '' : String(q.subject);
                }

                // Reconstruir choices
                const choicesContainer = document.getElementById('choices-container');
                if (choicesContainer) {
                    choicesContainer.innerHTML = '';

                    const choices = Array.isArray(q.choices) ? q.choices : [];
                    const correct = new Set(Array.isArray(q.correct_choices) ? q.correct_choices.map(Number) : []);

                    const toRender = choices.length >= 2 ? choices : choices.concat(Array(2 - choices.length).fill(''));
                    toRender.forEach((text, idx) => {
                        addChoice((text ?? '').toString(), correct.has(idx));
                    });

                    renumberChoices();
                }

                // Disparar previsualización
                if (titleInput) titleInput.dispatchEvent(new Event('input'));
                if (stemInput) stemInput.dispatchEvent(new Event('input'));
            } catch (e) {
                // Silencioso: el usuario canceló o archivo inválido
                console.error(e);
            }
        });
    }

    window._quizChoices = { addChoice, renumberChoices };
})();
