let scene, camera, renderer;
let levels = [];
let stars;
let dustParticles;
let flightMode = true;
let pressedKeys = new Set();
let movementSpeed = 5;
let rotationSpeed = Math.PI / 180 * 2;
let currentLevel = 0;

function initScene() {
    console.log("Initializing scene");
    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 10000);
    renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setClearColor(0x000033); // Dark blue background
    document.body.appendChild(renderer.domElement);
    console.log("Renderer initialized");

    // Star field (white points)
    const starMaterial = new THREE.PointsMaterial({ color: 0xFFFFFF, size: 0.05 });
    const starVertices = [];
    for (let i = 0; i < 10000; i++) {
        const x = (Math.random() - 0.5) * 500;
        const y = (Math.random() - 0.5) * 500;
        const z = (Math.random() - 0.5) * 500;
        starVertices.push(x, y, z);
    }
    const starGeometry = new THREE.BufferGeometry().setAttribute('position', new THREE.Float32BufferAttribute(starVertices, 3));
    stars = new THREE.Points(starGeometry, starMaterial);
    scene.add(stars);
    console.log("Star field added");

    // Levels (3 spheres)
    const numLevels = 3;
    levels = [];
    for (let i = 0; i < numLevels; i++) {
        const x = (Math.random() - 0.5) * 100;
        const y = (Math.random() - 0.5) * 100;
        const z = (Math.random() - 0.5) * 100;
        const color = getLevelColor(i);
        const material = new THREE.MeshBasicMaterial({ color: color });
        const geometry = new THREE.SphereGeometry(5, 32, 32);
        const level = new THREE.Mesh(geometry, material);
        level.position.set(x, y, z);
        level.userData = { id: i, difficulty: i === 0 ? 'beginner' : i === 1 ? 'intermediate' : 'advanced', unlocked: i === 0 };
        scene.add(level);
        levels.push(level);
        console.log(`Level ${i} added at position (${x.toFixed(2)}, ${y.toFixed(2)}, ${z.toFixed(2)})`);
    }

    // Dust particles (gray points)
    const dustMaterial = new THREE.PointsMaterial({ color: 0xAAAAAA, size: 0.02, opacity: 0.5, transparent: true });
    const dustVertices = [];
    for (let i = 0; i < 2000; i++) {
        const x = (Math.random() - 0.5) * 200;
        const y = (Math.random() - 0.5) * 200;
        const z = -Math.random() * 200 - 10;
        dustVertices.push(x, y, z);
    }
    const dustGeometry = new THREE.BufferGeometry().setAttribute('position', new THREE.Float32BufferAttribute(dustVertices, 3));
    dustParticles = new THREE.Points(dustGeometry, dustMaterial);
    scene.add(dustParticles);
    console.log("Dust particles added");

    camera.position.set(0, 0, 50);
    console.log("Camera positioned at (0, 0, 50)");

    document.addEventListener('keydown', (e) => {
        pressedKeys.add(e.key.toLowerCase());
        if (flightMode && e.key === ' ') {
            selectLevel();
        }
        console.log("Key pressed:", e.key, "Pressed keys:", Array.from(pressedKeys));
    });
    document.addEventListener('keyup', (e) => {
        pressedKeys.delete(e.key.toLowerCase());
        console.log("Key released:", e.key);
    });

    window.addEventListener('resize', () => {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
        console.log("Window resized");
    });

    animate();
}

function getLevelColor(levelId) {
    if (levelId === currentLevel) return 0x00FF00; // Green
    if (levelId > currentLevel) return 0xFF4500; // Orange
    return 0xFFFFFF; // White
}

function updateLevelColors() {
    levels.forEach(level => {
        level.material.color.setHex(getLevelColor(level.userData.id));
    });
}

function selectLevel() {
    console.log("Attempting to select level");
    const raycaster = new THREE.Raycaster();
    raycaster.setFromCamera(new THREE.Vector2(0, 0), camera);
    const intersects = raycaster.intersectObjects(levels);
    if (intersects.length > 0) {
        const selected = intersects[0].object;
        console.log(`Selected level ${selected.userData.id} (${selected.userData.difficulty})`);
        if (selected.userData.unlocked) {
            flightMode = false;
            currentLevel = selected.userData.id;
            // Placeholder for level start (no bubble shooter or vim puzzle)
            console.log(`Starting level ${currentLevel}`);
            setTimeout(() => {
                flightMode = true;
                if (currentLevel + 1 < levels.length) {
                    levels[currentLevel + 1].userData.unlocked = true;
                    updateLevelColors();
                }
                console.log("Level completed, returned to flight mode");
            }, 2000); // Simulate level completion
        } else {
            console.log("Level locked");
        }
    } else {
        console.log("No level intersected");
    }
}

function animate() {
    requestAnimationFrame(animate);
    console.log("Rendering frame");

    if (flightMode) {
        const delta = 1 / 60;
        const forward = new THREE.Vector3(0, 0, -1).applyQuaternion(camera.quaternion);
        const right = new THREE.Vector3(1, 0, 0).applyQuaternion(camera.quaternion);
        const up = new THREE.Vector3(0, 1, 0);

        if (pressedKeys.has('w')) camera.position.add(forward.clone().multiplyScalar(movementSpeed * delta));
        if (pressedKeys.has('s')) camera.position.add(forward.clone().multiplyScalar(-movementSpeed * delta));
        if (pressedKeys.has('a')) camera.position.add(right.clone().multiplyScalar(-movementSpeed * delta));
        if (pressedKeys.has('d')) camera.position.add(right.clone().multiplyScalar(movementSpeed * delta));
        if (pressedKeys.has('r')) camera.position.add(up.clone().multiplyScalar(movementSpeed * delta));
        if (pressedKeys.has('f')) camera.position.add(up.clone().multiplyScalar(-movementSpeed * delta));
        if (pressedKeys.has('q')) camera.rotateOnWorldAxis(up, rotationSpeed);
        if (pressedKeys.has('e')) camera.rotateOnWorldAxis(up, -rotationSpeed);
        if (pressedKeys.has('j')) camera.rotateOnAxis(new THREE.Vector3(0, 0, 1).applyQuaternion(camera.quaternion), rotationSpeed);
        if (pressedKeys.has('l')) camera.rotateOnAxis(new THREE.Vector3(1, 0, 0).applyQuaternion(camera.quaternion), -rotationSpeed);
        if (pressedKeys.has('k')) camera.rotateOnAxis(new THREE.Vector3(1, 0, 0).applyQuaternion(camera.quaternion), rotationSpeed);
        if (pressedKeys.has(';')) camera.rotateOnAxis(new THREE.Vector3(0, 0, 1).applyQuaternion(camera.quaternion), -rotationSpeed);
    }

    const positions = dustParticles.geometry.attributes.position.array;
    for (let i = 2; i < positions.length; i += 3) {
        positions[i] += 1;
        if (positions[i] > 0) {
            positions[i] = -Math.random() * 200 - 10;
        }
    }
    dustParticles.geometry.attributes.position.needsUpdate = true;

    renderer.render(scene, camera);
}

initScene();
