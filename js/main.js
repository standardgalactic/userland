let currentLevel = 0;
let commandBuffer = '';
let score = 0;
let isBubbleMode = false;
let commands = [];

const popSound = new Audio('assets/sounds/pop.wav');
const backgroundSound = new Audio('assets/sounds/background.wav');
const levelCompleteSound = new Audio('assets/sounds/level_complete.wav');
const errorSound = new Audio('assets/sounds/error.wav');
backgroundSound.loop = true;

function unlockAudioOnce() {
    backgroundSound.play().catch(() => {});
    document.removeEventListener('keydown', unlockAudioOnce);
    document.removeEventListener('click', unlockAudioOnce);
}
document.addEventListener('keydown', unlockAudioOnce);
document.addEventListener('click', unlockAudioOnce);

function init() {
    initGalaxyMap();
    fetch('js/commands.json')
        .then(response => response.json())
        .then(data => {
            commands = data;
            levels.forEach((level, i) => {
                level.userData.commands = commands.filter(c => c.level === i);
            });
        })
        .catch(err => console.error("Failed to load commands.json:", err));

    document.addEventListener('keydown', handleKeyDown);
}

function handleKeyDown(event) {
    if (event.key === 'Escape') {
        if (!flightMode) {
            flightMode = true;
            if (isBubbleMode) {
                isBubbleMode = false;
                bubbles.forEach(b => scene.remove(b));
                bubbles = [];
            }
            if (editor) {
                document.getElementById('editor-container').style.display = 'none';
            }
        }
    } else if (flightMode) {
        return; // Let galaxyMap.js handle flight controls
    } else if (event.key.length === 1) {
        commandBuffer += event.key;
        document.getElementById('command-input').textContent = `Command: ${commandBuffer}`;
        checkCommand();
    } else if (event.key === 'Enter') {
        submitCommand();
    } else if (event.key === 'Backspace') {
        commandBuffer = commandBuffer.slice(0, -1);
        document.getElementById('command-input').textContent = `Command: ${commandBuffer}`;
    }
}

function checkCommand() {
    if (isBubbleMode) {
        checkBubblePop(commandBuffer);
    }
}

function submitCommand() {
    commandBuffer = '';
}

function updateScore(points) {
    score += points;
    document.getElementById('score').textContent = `Score: ${score}`;
    updateSkillLevel();
}

function levelComplete() {
    isBubbleMode = false;
    levelCompleteSound.play();
    updateScore(50);
    if (currentLevel + 1 < levels.length) {
        levels[currentLevel + 1].userData.unlocked = true;
    }
    updateLevelColors();
    flightMode = true;
}

init();
