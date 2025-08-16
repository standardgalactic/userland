let bubbles = [];
let isBubbleMode = false;

function initBubbleShooter(levelId) {
    flightMode = false;
    isBubbleMode = true;
    bubbles.forEach(b => scene.remove(b));
    bubbles = [];

    const levelCommands = levels[levelId].userData.commands || [];
    levelCommands.forEach(cmd => {
        const loader = new THREE.TextureLoader();
        const bubbleTexture = loader.load(
            'assets/textures/bubble.png',
            () => console.log("Bubble texture loaded"),
            undefined,
            (err) => console.error("Bubble texture load error:", err)
        );
        const material = new THREE.MeshBasicMaterial({ map: bubbleTexture, transparent: true });
        const geometry = new THREE.SphereGeometry(0.3, 32, 32);
        const bubble = new THREE.Mesh(geometry, material);
        const pos = levels[levelId].position.clone();
        bubble.position.set(pos.x + Math.random() * 2 - 1, pos.y + Math.random() * 2 - 1, pos.z);
        bubble.userData = { command: cmd.command, description: cmd.description };
        scene.add(bubble);
        bubbles.push(bubble);
    });

    console.log('Bubbles created for level ' + levelId);
}

function checkBubblePop(input) {
    bubbles.forEach((bubble, index) => {
        if (input === bubble.userData.command) {
            scene.remove(bubble);
            bubbles.splice(index, 1);
            popSound.play();
            updateScore(10);
            commandBuffer = '';
            document.getElementById('command-input').textContent = `Command: `;
            if (bubbles.length === 0) {
                levelComplete();
            }
        }
    });
    if (!bubbles.some(b => input === b.userData.command)) {
        errorSound.play();
    }
}
