let editor;

function initVimPuzzle(levelId) {
    flightMode = false;
    const container = document.getElementById('editor-container');
    container.style.display = 'block';

    const puzzleText = 'Edit this text using Vim commands.\nDelete this line with dd.';
    editor = CodeMirror(container, {
        value: puzzleText,
        mode: 'text',
        keyMap: 'vim',
        lineNumbers: true,
        theme: 'default'
    });

    editor.on('change', validatePuzzle);
}

function validatePuzzle() {
    if (editor.getValue() === 'Edit this text using Vim commands.') {
        document.getElementById('editor-container').style.display = 'none';
        levelCompleteSound.play();
        updateScore(50);
        flightMode = true;
    }
}
