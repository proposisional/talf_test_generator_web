const questions = document.querySelectorAll('.question');
const prevBtn = document.getElementById('prevBtn');
const nextBtn = document.getElementById('nextBtn');
const indicatorSpans = document.querySelectorAll('#indicator span');
let current = 0;

function getEvaluation() {
    const form = document.getElementById('testForm');
    return (form && form.dataset && form.dataset.evaluation) ? form.dataset.evaluation : 'classic';
}

function getTestId() {
    const form = document.getElementById('testForm');
    if (form && form.dataset && form.dataset.testId) {
        const v = parseInt(form.dataset.testId, 10);
        return isNaN(v) ? 0 : v;
    }
    return 0;
}

function arraysEqual(a, b) {
    if (a.length !== b.length) return false;
    const as = [...a].sort();
    const bs = [...b].sort();
    for (let i = 0; i < as.length; i++) if (as[i] !== bs[i]) return false;
    return true;
}

function computeScore() {
    const total = questions.length;
    if (total === 0) return { score: 0, correct: 0, wrong: 0, blank: 0 };
    const per = 10 / total;
    const evalMethod = getEvaluation();

    let correct = 0, wrong = 0, blank = 0, score = 0;
    questions.forEach((qEl, idx) => {
        const correctStr = qEl.getAttribute('data-correct') || '';
        const isMultiple = qEl.getAttribute('data-multiple') === '1';
        const correctArr = correctStr === '' ? [] : correctStr.split(',').map(s => parseInt(s, 10));

        const inputs = document.querySelectorAll(`input[name="q${idx}[]"]`);
        const chosen = Array.from(inputs).filter(i => i.checked).map(i => parseInt(i.value, 10));

        const isBlank = chosen.length === 0;
        let isCorrect = false;
        if (isMultiple) {
            isCorrect = arraysEqual(chosen, correctArr);
        } else {
            isCorrect = chosen.length === 1 && correctArr.length === 1 && chosen[0] === correctArr[0];
        }

        if (isBlank) {
            blank++;
        } else if (isCorrect) {
            correct++;
            score += per;
        } else {
            wrong++;
            if (evalMethod === 'classic') {
                score -= per * 0.33;
            } else if (evalMethod === 'no_penalty') {
                // No-op
            } else if (evalMethod === 'partial_credit') {
                if (isMultiple && correctArr.length > 0) {
                    const hits = chosen.filter(v => correctArr.includes(v)).length;
                    const frac = Math.max(0, Math.min(1, hits / correctArr.length));
                    score += per * frac;
                }
            }
        }
    });

    if (score < 0) score = 0;
    if (score > 10) score = 10;
    return { score: parseFloat(score.toFixed(2)), correct, wrong, blank };
}

function showQuestion(index) {
    if (index < 0 || index >= questions.length) return;
    questions[current].classList.remove('active');
    indicatorSpans[current].classList.remove('active');
    current = index;
    questions[current].classList.add('active');
    indicatorSpans[current].classList.add('active');
    prevBtn.disabled = current === 0;
    nextBtn.textContent = current === questions.length - 1 ? 'Finalizar' : '→';
}

prevBtn.addEventListener('click', () => {
    showQuestion(current - 1);
});

nextBtn.addEventListener('click', () => {
    if (current === questions.length - 1) {
        const result = computeScore();
        const total = questions.length;
        const evalMethod = getEvaluation();
        const testId = getTestId();

        const answersPayload = [];
        questions.forEach((qEl, idx) => {
            const inputs = document.querySelectorAll(`input[name="q${idx}[]"]`);
            const chosen = Array.from(inputs).filter(i => i.checked).map(i => parseInt(i.value, 10));
            answersPayload.push(chosen);
        });

        const sendAnswers = () => {
            if (!testId) return Promise.resolve(null);
            const meta = document.querySelector('meta[name="csrf-token"]');
            const csrf = meta ? meta.getAttribute('content') : null;
            const form = document.getElementById('testForm');
            const endpoint = form ? (form.getAttribute('data-save-url') || 'index.php?r=test/save-answers') : 'index.php?r=test/save-answers';
            return fetch(endpoint, {
                method: 'POST',
                credentials: 'same-origin',
                headers: {
                    'Content-Type': 'application/json',
                    ...(csrf ? { 'X-CSRF-Token': csrf } : {}),
                },
                body: JSON.stringify({ testId, answers: answersPayload })
            }).then(r => r.ok ? r.json() : null).catch(() => null);
        };

        sendAnswers().then((serverResp) => {
            if (!serverResp) {
                console.warn('No server response (save-answers). Reintentando una vez...');
                return sendAnswers();
            }
            return serverResp;
        }).then((serverResp) => {
            let params;
            if (serverResp && serverResp.ok) {
                params = new URLSearchParams({
                    testId: String(testId || 0),
                    score: String(serverResp.score),
                    correct: String(serverResp.correct),
                    wrong: String(serverResp.wrong),
                    blank: String(serverResp.blank),
                    total: String(serverResp.total),
                    evaluation: String(serverResp.evaluation || evalMethod),
                });
            } else {
                params = new URLSearchParams({
                    testId: String(testId || 0),
                    score: String(result.score),
                    correct: String(result.correct),
                    wrong: String(result.wrong),
                    blank: String(result.blank),
                    total: String(total),
                    evaluation: evalMethod,
                });
            }
            const url = `results?${params.toString()}`;
            window.location.href = url;
        });
        return;
    }
    showQuestion(current + 1);
});

indicatorSpans.forEach(span => {
    span.addEventListener('click', e => {
        const idx = parseInt(e.target.getAttribute('data-index'));
        showQuestion(idx);
    });
});

showQuestion(0); 